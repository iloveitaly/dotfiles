#!/bin/bash

if ! command -v brew >/dev/null; then
	ruby <(curl -fsS https://raw.githubusercontent.com/Homebrew/install/master/install)
	echo "Brew is installed. Make sure bootstrap.bash has been run and then rerun this command"
	exit 0
fi

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew, and upgrade any already-installed formulae
brew update && brew upgrade && brew cleanup

brew install caskroom/cask/brew-cask
brew upgrade brew-cask
brew cask cleanup
brew cask update

brew install bash
brew install bash-completion
brew install rails-completion

# Everything else
brew install ack
brew install git
brew install lynx
brew install node
brew install rename
brew install tree
brew install imagemagick
brew install wget
brew install ngrep
brew install linklint
brew install duti
brew install mongodb
brew install optipng
brew install hub
brew install the_silver_searcher
brew install iftop
brew install webkit2png
brew install jq
brew install ngrok
brew install lftp
brew install ghi
brew install gist
brew install spoof-mac

# php / WordPress
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew install freetype jpeg libpng gd
brew install php56
brew install wp-cli
brew install composer

# node
if ! command -v bower >/dev/null; then
	# TODO may need to be installed manually
	curl http://npmjs.org/install.sh | sh
	npm install -g grunt
	npm install -g bower
	npm install -g livereloadx
fi

# ruby
brew install qt
brew install icu4c
brew install autoconf
RUBY_VERSION=1.9.3-p551
brew install rbenv
brew install ruby-build

if [[ `rbenv global` != $RUBY_VERSION ]]; then
	# stuck on 1.9.x on an older rails project
	rbenv install $RUBY_VERSION

	# some newer projects are on 2.0
	rbenv install 2.0.0-p451

	rbenv rehash
	rbenv global $RUBY_VERSION
fi

# reload rbenv into bash profile
eval "$(rbenv init -)"

# mysql setup
brew install mysql
mysql.server start
$(brew --prefix mysql)/bin/mysqladmin -u root password root
printf "\n\nIf the mysql install throws an error you may need to follow the steps documented here: http://stackoverflow.com/questions/4788381/getting-cant-connect-through-socket-tmp-mysql-when-installing-mysql-on-m\n\n"

# rails tools
brew install sqlite
brew install vagrant
# vagrant box add ubuntu-12.04 http://files.vagrantup.com/precise64.box
brew install siege
brew install sqlite

# http://xquartz.macosforge.org/landing/
# imagemagick + rmagic issues: https://gist.github.com/3177887

gem install notes
gem install powder
gem install bundle
gem install dokkufy
gem install method_log

rbenv version 2.0.0-p451
gem install cocoapods
rbenv version $RUBY_VERSION

# need to reload the env to get `bundle`
source ~/.bash_profile

powder install

# parallel bundler job processing
# https://gist.github.com/cbrunsdon/f9cfe01d7278e2bbc0d4
bundle config --global jobs 4
bundle config --global path vendor/bundle
bundle config --global disable_shared_gems 1
bundle config --global disable_local_branch_check true

# irb / rails console additions
gem install awesome_print
gem install brice
gem install added_methods

brew cleanup

# setup default extension handlers

duti < ~/.duti
