#!/bin/bash
cd "$(dirname "$0")"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	echo "Detected linux environment, using codespace install"
	./codespace.sh
	exit 0
fi

git pull
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync --exclude ".git/" \
  	--exclude "osx.sh" \
  	--exclude "brew.sh" \
    --exclude "duti" \
    --exclude "cask.sh" --exclude "mas.sh" \
    --exclude ipython_config.py \
    --exclude "vscode-extensions.txt" --exclude "vscode-settings.json" --exclude "vscode-keybindings.json" \
    --exclude "backup.sh" \
    --exclude "distracting_websites.txt" \
  	--exclude ".DS_Store" --exclude "codespace.sh" --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" \
    -av . ~
fi

mackup restore

cat ./vscode-extensions.txt | xargs -L 1 echo code --install-extension
cp ./vscode-settings.json "$HOME/Library/Application Support/Code/User/settings.json"

cp -f ./ssh_config ~/.ssh/config
cp ipython_config.py ~/.ipython/profile_default/

# https://apple.stackexchange.com/questions/92710/why-is-safari-ignoring-my-etc-hosts-file
# block distracting websites. More info: http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/
sed '/^$/d' ./distracting_websites.txt | sed -E $'s/\(.*\)/127.0.0.1  \\1\\\n127.0.0.1  www.\\1/' > ~/distracting_sites.txt
sudo -E `asdf which node` `asdf which hostile` load ~/distracting_sites.txt
