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
  	--exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" -av . ~
fi

cp -f ./ssh_config ~/.ssh/config

mkdir -p ~/Sites/logs
sudo rm /etc/apache2/other/*
sudo cp -f apache.conf /etc/apache2/other/vhosts.conf

sudo cp -f my.cnf /etc/my.cnf

source "$HOME/.bash_profile"

# http://krypted.com/mac-security/apache2-umasks/
# http://askubuntu.com/questions/230476/when-using-sudo-with-redirection-i-get-permission-denied
echo -e "export RAILS_TEST_SERVER_PORT=$RAILS_TEST_SERVER_PORT\nexport USER=$USER" | sudo tee /usr/sbin/envvars

sudo apachectl -k restart || (sudo killall httpd; killall httpd; sudo apachectl)
mysql.server restart || sudo killall mysqld

powder install
