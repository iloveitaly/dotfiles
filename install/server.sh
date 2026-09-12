#!/bin/bash
# Minimal bootstrap for cloud hosts that mostly run Docker.
#
# Usage:
#   run from a clone: ./install/server.sh

set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

sudo apt-get update
sudo apt-get install -y zsh curl ca-certificates git

# Docker Engine (system daemon — not available via mise)
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$(whoami)"

# mise → ~/.local/bin/mise
if [[ ! -x "${HOME}/.local/bin/mise" ]]; then
  curl https://mise.run | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
eval "$(mise activate bash)"

mkdir -p "${HOME}/.local/bin" "${HOME}/.config/mise"
cp .config/mise/config.toml "${HOME}/.config/mise/config.toml"

# micro editor config from this repo
MICRO_CFG="${HOME}/.config/micro"
mkdir -p "${MICRO_CFG}"
cp -R .config/micro/* "${MICRO_CFG}/"

# leave the clone before running mise commands
cd "${HOME}" || exit 1

# erlang/ruby compile from source and are slow/unneeded on cloud servers;
# elixir depends on erlang, so it must go too
mise settings set disable_tools '["erlang", "elixir", "ruby"]'

mise install -y
mise upgrade

# fzf-tab: Tab completions via fzf (must load after compinit)
FZF_TAB="${HOME}/.local/share/fzf-tab"
if [[ ! -d "${FZF_TAB}/.git" ]]; then
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "${FZF_TAB}"
fi

# user completion dir (dokku, etc.) — prepended to fpath before compinit
ZFUNC="${HOME}/.zfunc"
mkdir -p "${ZFUNC}"
curl -fsSL -o "${ZFUNC}/_dokku" \
  https://raw.githubusercontent.com/iloveitaly/zsh-dokku/master/completions/_dokku

# cloud-server prompt: always show host (no username), keep noise low
STARSHIP_TOML="${HOME}/.config/starship.toml"
cat >"${STARSHIP_TOML}" <<'EOF'
# useful on docker hosts: duration (slow pulls/builds), docker context, root user
format = """
$hostname\
$directory\
$docker_context\
$cmd_duration\
$username\
$character"""

[hostname]
# always show cloud mark — this config only lives on remote hosts
ssh_only = false
format = "[☁️]($style) "
style = "bold cyan"

[directory]
style = "blue"
truncation_length = 3

[docker_context]
format = "[$symbol$context]($style) "
style = "blue"
symbol = "🐳 "
only_with_files = false

[cmd_duration]
min_time = 2_000
format = "[$duration]($style) "
style = "yellow"

# only appears as root (default); useful safety signal on cloud boxes
[username]
format = "[$user]($style) "
style_root = "bold red"
show_always = false

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
EOF

# zshrc: preserve original once; regenerate .zshrc as backup + bootstrap block
ZSHRC="${HOME}/.zshrc"
ZSHRC_BACKUP="${HOME}/.zshrc.pre-bootstrap"
MARKER_BEGIN="# START CUSTOM BOOTSTRAP"
MARKER_END="# END CUSTOM BOOTSTRAP"

if [[ -f "${ZSHRC}" && ! -f "${ZSHRC_BACKUP}" ]] && ! grep -qxF "${MARKER_BEGIN}" "${ZSHRC}" 2>/dev/null; then
  cp -a "${ZSHRC}" "${ZSHRC_BACKUP}"
fi

{
  [[ -f "${ZSHRC_BACKUP}" ]] && cat "${ZSHRC_BACKUP}"
  cat <<EOF

${MARKER_BEGIN}
export PATH="\${HOME}/.local/bin:\${PATH}"
eval "\$(mise activate zsh)"
eval "\$(fzf --zsh)"
eval "\$(zoxide init zsh)"
eval "\$(atuin init zsh)"
eval "\$(starship init zsh)"
alias m=micro
alias d=docker
alias dk=dokku
fpath=("\${HOME}/.zfunc" \$fpath)
autoload -Uz compinit && compinit
(( \$+commands[docker] )) && eval "\$(docker completion zsh)" && compdef d=docker
compdef dk=dokku
source "\${HOME}/.local/share/fzf-tab/fzf-tab.plugin.zsh"
${MARKER_END}
EOF
} >"${ZSHRC}"

# make zsh the login shell
if ! grep -qxF "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi
sudo chsh -s "$(command -v zsh)" "$(whoami)"

echo "Done."
