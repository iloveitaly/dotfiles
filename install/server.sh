#!/bin/bash

cd "$(dirname "$0")/.."

rsync --exclude-from="install/standard-exclude.txt" \
      --exclude-from="install/server-exclude.txt" \
      -av . ~

# TODO should support more linuxbrew locations
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

brew bundle

sudo chsh -s "$(which zsh)" "$(whoami)"

# run zinit to install all plugins
zsh -lc "source ~/.zshrc && zinit update --parallel"