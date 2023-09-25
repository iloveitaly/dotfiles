#!/bin/bash

cd "$(dirname "$0")/.."

rsync --exclude-from="install/standard-exclude.txt" \
      --exclude-from="install/server-exclude.txt" \
      -av . ~

local homebrew_path="/home/linuxbrew/.linuxbrew/bin/brew"

if [ ! -f "$homebrew_path" ]; then
  echo "No homebrew installation detected"
  exit 1
fi

eval $("$homebrew_path" shellenv)

brew bundle

sudo chsh -s "$(which zsh)" "$(whoami)"

# cleaner output since this will be running inside ansible, or something similar
export ZINIT_COLORIZE=false

# run zinit to install all plugins
zsh -lc "source ~/.zshrc && zinit update --parallel"