#!/bin/bash
cd "$(dirname "$0")"
git pull
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync --exclude ".git/" \
  	--exclude "osx.sh" \
  	--exclude "brew.sh" \
    --exclude "apache.conf" \
    --exclude "my.cnf" \
    --exclude "cask.sh" \
    --exclude "backup.sh" \
  	--exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" -av . ~
fi

mackup restore

cat ./vscode-extensions.txt | xargs -L 1 echo code --install-extension
cp ./vscode-settings.json "$HOME/Library/Application Support/Code/User/settings.json"

cp -f ./ssh_config ~/.ssh/config

sudo cp -f my.cnf /etc/my.cnf

# TODO install extensiopns via requirements.txt
# TODO document vscode customizations
code --install-extension

# block distracting websites
# some additional configuration is required here
# http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/
sed '/^$/d' ./distracting_websites.txt | sed $'s/\(.*\)/127.0.0.1  \\1\\\n127.0.0.1  www.\\1/' > ~/distracting_sites.txt
sudo -E `asdf which node` `asdf which hostile` load ~/distracting_sites.txt
