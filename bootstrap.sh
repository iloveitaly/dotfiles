#!/bin/bash
cd "$(dirname "$0")"
git pull
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync --exclude ".git/" \
  	--exclude "osx.sh" \
  	--exclude "brew.sh" \
        --exclude "pow.conf" \
  	--exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" -av . ~
fi

cp -f ./ssh_config ~/.ssh/config
sudo cp -f pow.conf /etc/apache2/other/pow.conf

# TODO customize MySQL config

source "$HOME/.bash_profile"

sudo apachectl start
mysql.server restart || sudo killall mysqld
