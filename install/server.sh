#!/bin/bash
# Minimal bootstrap for Debian, Ubuntu, Arch, and Omarchy hosts that mostly run Docker.
#
# Usage:
#   run from a clone: ./install/server.sh
# GitHub-backed mise tools need a resolvable token (not stored on disk), e.g.:
#   MISE_GITHUB_TOKEN=... ./install/server.sh

set -euo pipefail

if [[ ! -f /etc/os-release ]]; then
  echo "Cannot detect the distribution: /etc/os-release is missing." >&2
  exit 1
fi
# shellcheck source=/dev/null
. /etc/os-release

case "${ID:-}" in
  arch|omarchy)
    package_manager=pacman
    # Arch does not support partial upgrades; update the system with its packages.
    echo -e "\033[0;33mSudo: upgrade system packages and install bootstrap dependencies with pacman.\033[0m"
    sudo pacman -Syu --needed --noconfirm zsh curl ca-certificates git rsync
    ;;
  debian|ubuntu)
    package_manager=apt
    export DEBIAN_FRONTEND=noninteractive
    echo -e "\033[0;33mSudo: refresh apt package lists and install bootstrap dependencies.\033[0m"
    sudo apt-get update
    sudo apt-get install -y zsh curl ca-certificates git rsync
    ;;
  *)
    echo "Unsupported distribution: ${ID:-unknown}. Expected debian, ubuntu, arch, or omarchy." >&2
    exit 1
    ;;
esac

cd "$(dirname "$0")/.." || exit 1

rsync --exclude-from="install/standard-exclude.txt" \
  --exclude-from="install/server-exclude.txt" \
  -av . ~

# Headless fragment is install-time only — not part of the cross-platform rsync.
install -Dm 0644 install/mise/linux.toml \
  "${HOME}/.config/mise/conf.d/linux.toml"

install -Dm 0644 install/mise/server.toml \
  "${HOME}/.config/mise/conf.d/server.toml"

# forgit expects macOS-style pbcopy/pbpaste. Headless hosts have no display
# server, so relay clipboard data over OSC52 via osc. Executables (not aliases)
# so forgit works outside zsh too.
install -Dm 0755 install/linux/bin/pbcopy "${HOME}/.local/bin/pbcopy"
install -Dm 0755 install/linux/bin/pbpaste "${HOME}/.local/bin/pbpaste"

# Use official git-core PPA for modern git on Ubuntu hosts (e.g. 22.04 on Orange Pi).
# Skips non-Ubuntu systems where PPAs are incompatible.
if [[ "${ID:-}" == "ubuntu" ]]; then
  echo -e "\033[0;33mSudo: add the git-core PPA and install an up-to-date Git.\033[0m"
  if ! command -v add-apt-repository &>/dev/null; then
    sudo apt-get install -y software-properties-common
  fi
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get install -y git
fi

# Docker Engine (system daemon — not available via mise)
if ! command -v docker &>/dev/null; then
  if [[ "$package_manager" == "pacman" ]]; then
    echo -e "\033[0;33mSudo: install Docker Engine, Compose, and Buildx with pacman.\033[0m"
    sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx
  else
    echo -e "\033[0;33mSudo: run Docker's installer to configure its repository and install Docker Engine.\033[0m"
    curl -fsSL https://get.docker.com | sudo sh
  fi
fi
if [[ "$package_manager" == "pacman" ]]; then
  echo -e "\033[0;33mSudo: enable Docker at boot and start its system service.\033[0m"
  sudo systemctl enable --now docker
fi

# mise → ~/.local/bin/mise (musl to avoid glibc issues on some servers/pis)
if [[ ! -x "${HOME}/.local/bin/mise" ]]; then
  curl https://mise.run | MISE_INSTALL_MUSL=1 sh
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
mise prune -y

# yazi's git.yazi plugin is only declared in ~/.config/yazi/package.toml (rsynced
# above) — it isn't fetched until `ya pkg install` runs
mise exec -- ya pkg install

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
  echo -e "\033[0;33mSudo: register zsh in /etc/shells as an allowed login shell.\033[0m"
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi
echo -e "\033[0;33mSudo: change the current user's login shell to zsh.\033[0m"
sudo chsh -s "$(command -v zsh)" "$(whoami)"

git config --global commit.gpgsign false
git config --global --replace-all credential.helper store

# cleaner output since this will be running inside ansible, or something similar
export ZINIT_COLORIZE=false

# zinit's --no-pager path calls `cat`, but ~/.aliases maps that to bat. Give
# zsh non-TTY stdout so bat also disables its pager instead of spawning $PAGER
# (ov), which stops when zinit runs its parallel update job in the background.
zsh -lc "source ~/.zshrc && zinit update --parallel --no-pager" | /usr/bin/cat

echo "Done."
