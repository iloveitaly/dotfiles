#!/bin/bash

cd "$(dirname "$0")/.."

rsync --exclude-from="install/standard-exclude.txt" \
      --exclude-from="install/server-exclude.txt" \
      -av . ~

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