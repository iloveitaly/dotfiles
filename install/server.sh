#!/bin/bash
# Minimal bootstrap for cloud hosts that mostly run Docker.
#
# Usage:
#   run from a clone: ./install/server.sh
# GitHub-backed mise tools need a resolvable token (not stored on disk), e.g.:
#   MISE_GITHUB_TOKEN=... ./install/server.sh

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

cd "$(dirname "$0")/.." || exit 1

rsync --exclude-from="install/standard-exclude.txt" \
  --exclude-from="install/server-exclude.txt" \
  -av . ~

# Headless fragment is install-time only — not part of the cross-platform rsync.
install -Dm 0644 install/mise/linux.toml \
  "${HOME}/.config/mise/conf.d/linux.toml"

# forgit expects macOS-style pbcopy/pbpaste. Headless hosts have no display
# server, so relay clipboard data over OSC52 via osc. Executables (not aliases)
# so forgit works outside zsh too.
install -Dm 0755 install/linux/bin/pbcopy "${HOME}/.local/bin/pbcopy"
install -Dm 0755 install/linux/bin/pbpaste "${HOME}/.local/bin/pbpaste"

sudo apt-get update
sudo apt-get install -y zsh curl ca-certificates git

# Docker Engine (system daemon — not available via mise)
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$(whoami)"
# TODO: sudo systemctl enable --now docker

# mise → ~/.local/bin/mise
if [[ ! -x "${HOME}/.local/bin/mise" ]]; then
  curl https://mise.run | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
eval "$(mise activate bash)"

# GitHub-backed mise tools require an already-resolvable token. `mise token`
# checks its configured sources (environment, OAuth cache, gh CLI, etc.)
# without exposing the token in installer output.
if [[ -z "$(mise token github --raw 2>/dev/null)" ]]; then
  echo -e "\033[0;31mA GitHub token resolvable by mise is required (for example, MISE_GITHUB_TOKEN).\033[0m" >&2
  exit 1
fi
mise self-update -y

# leave the clone: mise treats a `.config/mise/config.toml` relative to cwd as
# a local project config layered on top of the global one
cd "${HOME}" || exit 1

mise install -y
mise upgrade

# yazi's git.yazi plugin is only declared in ~/.config/yazi/package.toml (rsynced
# above) — it isn't fetched until `ya pkg install` runs
ya pkg install

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

cat <<EOF >>~/.extra
alias dokku="docker exec -it dokku dokku"
alias dokku-shell="docker exec -it dokku bash -l"
EOF

# delete some zsh_plugins that are macos specific
sed -i '/zicompdef/d' ~/.zsh_plugins # assumes rg, etc which is not the same on servers :/
sed -i '/zsh-auto-notify/d' ~/.zsh_plugins

# make zsh the login shell
if ! grep -qxF "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi
sudo chsh -s "$(command -v zsh)" "$(whoami)"

git config --global commit.gpgsign false
git config --global credential.helper store

# cleaner output since this will be running inside ansible, or something similar
export ZINIT_COLORIZE=false

# zinit's --no-pager path calls `cat`, but ~/.aliases maps that to bat. Give
# zsh non-TTY stdout so bat also disables its pager instead of spawning $PAGER
# (ov), which stops when zinit runs its parallel update job in the background.
zsh -lc "source ~/.zshrc && zinit update --parallel --no-pager" | /usr/bin/cat

echo "Done."
