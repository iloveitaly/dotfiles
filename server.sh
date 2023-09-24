#!/bin/bash

rsync --exclude ".git/" \
    --exclude={"osx.sh","Brewfile","Brewfile.lock.json","brew.sh","server.sh","TODO","duti","backup.sh"} \
    --exclude={"distracting_websites.txt","DefaultKeyBinding.dict","aw-categories.json"} \
    --exclude={'bootstrap.sh','codespace.sh','README.md','TODO'} \
    --exclude={'.tmux.conf','.tool-versions','.asdfrc'} \
    --exclude={'.ssh','mackup.cfg','.config/karabiner/','.config/gmailctl/','.config/focus/','.config/extrakto/'} \
    -av . ~

# for homebrew to actually work
# sudo apt-get install build-essential procps curl file git gobjc++ glibc-source

eval $(/home/linuxbrew/bin/brew shellenv)

brew bundle