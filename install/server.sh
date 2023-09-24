#!/bin/bash

cd "$(dirname "$0")/.."

rsync --exclude-from="install/standard-exclude.txt" \
      --exclude-from="install/server-exclude.txt" \
      -av . ~

# for homebrew to actually work
# sudo apt-get install build-essential procps curl file git gobjc++ glibc-source

eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

brew bundle