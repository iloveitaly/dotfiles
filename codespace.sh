#!/bin/bash

echo "Syncing dotfiles..."
rsync --exclude ".git/" \
      --exclude "osx.sh" \
      --exclude "brew.sh" \
      --exclude "duti" \
      --exclude "cask.sh" --exclude "mas.sh" \
      --exclude ipython_config.py \
      --exclude "vscode-extensions.txt" --exclude "vscode-settings.json" \
      --exclude "backup.sh" \
      --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" \
      -av . ~

brew bundle