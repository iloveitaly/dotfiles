#!/bin/bash

echo "Syncing dotfiles..."
rsync --exclude ".git/" \
      --exclude "osx.sh" \
      --exclude={'brew.sh','Brewfile'} \
      --exclude={'duti','distracting_websites.txt'} \
      --exclude "cask.sh" --exclude "mas.sh" \
      --exclude ipython_config.py \
      --exclude={'vscode-extensions.txt','vscode-keybindings.json','vscode-settings.json'} \
      --exclude "backup.sh" \
      --exclude={'bootstrap.sh','codespace.sh','README.md','ssh_config'} \
      -av . ~

brew bundle

# run zinit
zsh -c "echo 'setup zinit'"

# https://cs.github.com/justincampbell/.dotfiles/blob/c8a8d72f49c6e66dc1dded2ada283aa50e35537f/install-codespaces.sh
git config --global credential.helper /.codespaces/bin/gitcredential_github.sh
git config --global gpg.program /.codespaces/bin/gh-gpgsign
git config --global diff.tool vscode

# continue even if some extensions cannot be installed on codespaces
cat vscode-extensions.txt | xargs -i zsh -c "code --install-extension {} || true"