#!/bin/bash

cd "$(dirname "$0")"

# NOTE this isn't perfect: we are trying to detect non-codespace servers
if [[ $(uname) == "Linux" ]]; then
  echo "Detecting Linux environment, using server install"
  ./install/server.sh
  exit 0
fi

# TODO need to determine codespace-specific fingerprint
# if [[ "$OSTYPE" == "linux-gnu" ]]; then
# 	echo "Detected codespace linux environment, using codespace install"
# 	./install/codespace.sh
# 	exit 0
# fi

# if not, then we are on macos

./brew.sh

echo "Syncing dotfiles..."
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync --exclude-from=install/standard-exclude.txt -av . ~
fi

# https://apple.stackexchange.com/questions/92710/why-is-safari-ignoring-my-etc-hosts-file
# block distracting websites. More info: http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/
cat ./distracting_websites.txt | sed -E 's/(.*)/127.0.0.1  \1\n127.0.0.1  www.\1/' >~/.config/distracting_sites.txt
sudo -E $(mise which hostile) load "$HOME/.config/distracting_sites.txt"

# setup default extension handlers
duti <./duti

# http://mikebian.co/advanced-text-editing-using-karabiner-macos-keybindings/
mkdir -p ~/Library/KeyBindings/
cp ./DefaultKeyBinding.dict ~/Library/KeyBindings/

# mackup restore

exec zsh
