#!/bin/bash
# Description: devbox installation entrypoint for Amazon Linux 2023 hosts.
#   - dnf/AL2023 counterpart to install/linux-devbox.sh
#   - run from a clone: ./install/amazon-linux-devbox.sh
#   - No GitHub tokens should be stored on server
#

set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

rsync --exclude-from="install/standard-exclude.txt" \
  --exclude-from="install/server-exclude.txt" \
  -av . ~

# This fragment is Amazon-specific, so install it explicitly rather than
# including it in the cross-platform dotfiles rsync above.
install -Dm 0644 install/mise/amazon-linux.toml \
  "${HOME}/.config/mise/conf.d/amazon-linux.toml"

# leave the clone: mise treats a `.config/mise/config.toml` relative to cwd as
# a local project config layered on top of the global one, and the repo's own
# copy is separate from the Amazon-specific global fragment installed above
cd "${HOME}" || exit 1

sudo dnf install -y \
  zsh ca-certificates git util-linux-user gcc gcc-c++ make \
  tree htop sqlite jq git-lfs nmap cronie tmux bubblewrap \
  clang

# build headers: mise installs precompiled python by default, but these are
# needed for MISE_PYTHON_COMPILE=1 and for native wheels built at pip-install time
sudo dnf install -y \
  readline-devel libffi-devel openssl-devel bzip2-devel zlib-devel xz-devel sqlite-devel

# Docker Engine (system daemon — not available via mise; AL2023 ships it in its own repo)
if ! command -v docker &>/dev/null; then
  sudo dnf install -y docker
fi
sudo systemctl enable --now docker
sudo usermod -aG docker "$(whoami)"

# mise → ~/.local/bin/mise
if [[ ! -x "${HOME}/.local/bin/mise" ]]; then
  curl https://mise.run | sh
fi
mkdir -p "${HOME}/.local/bin" "${HOME}/.config"
export PATH="${HOME}/.local/bin:${PATH}"
eval "$(mise activate bash)"

# GitHub-backed mise tools require an already-resolvable token. `mise token`
# checks its configured sources (environment, OAuth cache, gh CLI, etc.)
# without exposing the token in installer output.
if [[ -z "$(mise token github --raw 2>/dev/null)" ]]; then
  echo "A GitHub token resolvable by mise is required (for example, MISE_GITHUB_TOKEN)." >&2
  exit 1
fi
mise self-update -y

# installs/upgrades everything in the base config and Amazon-specific fragment
mise install -y
mise upgrade

# yazi's git.yazi plugin is only declared in ~/.config/yazi/package.toml (rsynced
# above) — it isn't fetched until `ya pkg install` runs
ya pkg install

# forgit expects macOS-style pbcopy/pbpaste commands. There is no display server
# on this headless devbox, so use osc to relay clipboard data to the local
# terminal over OSC52. Keep them as executables so forgit works outside zsh too.
install -m 0755 /dev/stdin "${HOME}/.local/bin/pbcopy" <<'EOF'
#!/bin/bash
exec "${HOME}/.local/bin/mise" exec -- osc copy "$@"
EOF
install -m 0755 /dev/stdin "${HOME}/.local/bin/pbpaste" <<'EOF'
#!/bin/bash
exec "${HOME}/.local/bin/mise" exec -- osc paste "$@"
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
