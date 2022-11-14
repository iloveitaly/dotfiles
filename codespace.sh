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

# https://cs.github.com/justincampbell/.dotfiles/blob/c8a8d72f49c6e66dc1dded2ada283aa50e35537f/install-codespaces.sh
git config --global credential.helper /.codespaces/bin/gitcredential_github.sh
git config --global gpg.program /.codespaces/bin/gh-gpgsign

git config --global diff.tool vscode

# in a codespace, GPG is signed using some sort of HTTP service via github, not your local
# machine's GPG key
git config --global --unset user.signingkey

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# TODO this does not seem to work properly unless run as root?
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

# set zsh as the default shell, the vscode setting does not seem to work on first run
sudo chsh -s "$(which zsh)" "$(whoami)"

# run zinit to install all plugins
zsh -lc "source ~/.zshrc && zinit update --parallel"