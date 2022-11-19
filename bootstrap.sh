#!/bin/bash
cd "$(dirname "$0")"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	echo "Detected linux environment, using codespace install"
	./codespace.sh
	exit 0
fi

# TODO detect if non-codespace server, run server.sh

git pull

./brew.sh

echo "Syncing dotfiles..."
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync --exclude ".git/" \
        --exclude={"osx.sh","Brewfile","Brewfile.lock.json","brew.sh","server.sh","TODO","duti","backup.sh"} \
        --exclude "distracting_websites.txt" \
        --exclude ".DS_Store" --exclude "codespace.sh" --exclude "bootstrap.sh" --exclude "README.md" \
        -av . ~
fi

# https://apple.stackexchange.com/questions/92710/why-is-safari-ignoring-my-etc-hosts-file
# block distracting websites. More info: http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/
sed '/^$/d' ./distracting_websites.txt | sed -E 's/(.*)/127.0.0.1  \1\n127.0.0.1  www.\1/' > ~/.config/distracting_sites.txt
sudo -E hostile load "$HOME/.config/distracting_sites.txt"

# setup default extension handlers
duti < ./duti

# mackup restore

exec zsh