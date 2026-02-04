#!/bin/bash

cd "$(dirname "$0")"

rsync --exclude-from=install/standard-exclude.txt -av . ~

if [[ $(uname) == "Linux" ]]; then
  echo "Detecting Linux environment, using server install"
  ./install/server.sh
  exit 0
fi

# if not, then we are on macos
./brew.sh

# https://apple.stackexchange.com/questions/92710/why-is-safari-ignoring-my-etc-hosts-file
# block distracting websites. More info: http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/
cat ./distracting_websites.txt | sed -E 's/(.*)/127.0.0.1  \1\n127.0.0.1  www.\1/' >~/.config/distracting_sites.txt
sudo -E $(mise which hostile) load "$HOME/.config/distracting_sites.txt"

# setup default extension handlers
# User-defined values can be defined here: ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist
# remove this file if you run into strange issues.
infat

# http://mikebian.co/advanced-text-editing-using-karabiner-macos-keybindings/
mkdir -p ~/Library/KeyBindings/
cp ./DefaultKeyBinding.dict ~/Library/KeyBindings/

# TODO link to blog post
cp ./tmux.plist ~/Library/LaunchAgents/mikebianco.tmux.plist
tmux kill-server
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/mikebianco.tmux.plist

cp ./pty.plist ~/Library/LaunchAgents/mikebianco.pty.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/mikebianco.pty.plist

# some tools can setup bashrc and other files that we don't want
# for instance, homebrew will setup a bashrc file. In order to provide a completely clean bash environment, we remove it.
rm ~/.bashrc

# mackup restore

exec zsh
