#!/bin/bash
# Minimal bootstrap for cloud hosts that mostly run Docker.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/iloveitaly/dotfiles/master/install/server.sh | bash

set -euo pipefail

sudo apt-get update
sudo apt-get install -y zsh curl ca-certificates

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

# writes ~/.config/mise/config.toml and installs binaries
mise use -g fzf ripgrep lazydocker atuin starship dua

mkdir -p "${HOME}/.local/bin" "${HOME}/.config"

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
only_with_compose_file = false

[cmd_duration]
min_time = 2_000
format = "[$duration]($style) "
style = "yellow"

# only appears as root (default); useful safety signal on cloud boxes
[username]
format = "[$user]($style) "
style = "bold red"
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
eval "\$(atuin init zsh)"
eval "\$(starship init zsh)"
autoload -Uz compinit && compinit
(( \$+commands[docker] )) && eval "\$(docker completion zsh)"
${MARKER_END}
EOF
} >"${ZSHRC}"

# make zsh the login shell
if ! grep -qxF "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi
sudo chsh -s "$(command -v zsh)" "$(whoami)"

echo "Done."
