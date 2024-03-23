#!/bin/bash

cd "$(dirname "$0")/.."

rsync --exclude-from="install/standard-exclude.txt" \
      --exclude-from="install/server-exclude.txt" \
      -av . ~

# detect if ARM, homebrew does not work...
if [ "$(uname -m)" = "aarch64" ]; then
  echo "ARM detected, installing ARM equivalent packages"

  # this list was generated by chatgpt's ingestion of Brewfile; keep it up to date manually
  sudo apt install -y \
    git vim lynx rename wget ngrep iftop lftp httpie ncdu curl gawk jq gh sqlite3 \
    zsh ripgrep entr prettyping less nano fd-find tldr zoxide bc delta bat exa tree htop dnsutils moreutils qpdf \
    rsync watch iotop

  cat <<EOF > ~/.tool-versions
direnv 2.34.0
rust 1.77.0
EOF

cat <<EOF > ~/.extra
alias cat=batcat
alias fd=fdfind

alias dokku="docker exec dokku dokku"
alias dokku-shell="docker exec -it dokku bash -l"

# fzf is really outdated, must install via git `~/.fzf.zsh`
[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
[ ! -d ~/.asdf ] && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
source ~/.fzf.zsh
EOF

  sudo chsh -s "$(which zsh)" "$(whoami)"

  git config --global --unset commit.gpgsign

  exit 0
fi

homebrew_path="/home/linuxbrew/.linuxbrew/bin/brew"

if [ ! -f "$homebrew_path" ]; then
  echo "No homebrew installation detected"
  # NOTE should really exit 1, but this will fail the ansible test
  exit 0
fi

eval $("$homebrew_path" shellenv)
unset homebrew_path

brew bundle

# if `python` doesn't exist, let's alias python3 to it if it exists
if ! command -v python &> /dev/null && command -v python3 &> /dev/null; then
  sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
fi

sudo chsh -s "$(which zsh)" "$(whoami)"

# cleaner output since this will be running inside ansible, or something similar
export ZINIT_COLORIZE=false

# run zinit to install all plugins
zsh -lc "source ~/.zshrc && zinit update --parallel"
