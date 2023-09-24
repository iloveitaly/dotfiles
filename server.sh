#!/bin/bash

rsync --exclude ".git/" \
    --exclude={"osx.sh","Brewfile","Brewfile.lock.json","brew.sh","server.sh","TODO","duti","backup.sh"} \
    --exclude={"distracting_websites.txt","DefaultKeyBinding.dict","aw-categories.json"} \
    --exclude={'bootstrap.sh','codespace.sh','README.md','TODO'} \
    -av . ~

# for homebrew to actually work
# sudo apt-get install build-essential procps curl file git gobjc++ glibc-source

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