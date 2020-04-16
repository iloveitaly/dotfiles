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

brew cask cleanup
brew cask update

brew install bash
brew install bash-completion
brew install ruby-completion
brew install mix-completion

# systems
brew install node
brew install mongodb

# Everything else
brew install mackup
brew install mas
brew install ack
brew install git
brew install lynx
brew install rename
brew install tree
brew install imagemagick
brew install wget
brew install ngrep
brew install linklint
brew install duti
brew install optipng
brew install hub
brew install ripgrep
brew install iftop
brew install webkit2png
brew install jq
brew install ngrok
brew install lftp
brew install ghi
brew install gist
brew install spoof-mac
brew install tmux
brew install httpie
brew install awscli
brew install ansible
brew install heroku/brew/heroku
brew install cloc

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
	# TODO use `asdf` to install node
	curl http://npmjs.org/install.sh | sh
	npm install -g grunt
	npm install -g bower
	npm install -g livereloadx
	npm install -g hostile
fi

# elixir
brew install asdf
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

# ruby
# 5.5 must be installed https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
brew install qt55
brew install cmake
brew install icu4c
brew install autoconf
brew install rbenv
brew install ruby-build
brew install puma/puma/puma-dev

rbenv install 2.6.5

rbenv rehash
rbenv global 2.6.5

# reload rbenv into bash profile
eval "$(rbenv init -)"

# mysql setup
brew install mysql
mysql.server start
$(brew --prefix mysql)/bin/mysqladmin -u root password root

# rails tools
brew install sqlite
brew install siege

# http://xquartz.macosforge.org/landing/
# imagemagick + rmagic issues: https://gist.github.com/3177887

gem install notes
gem install bundle
gem install method_log
gem install bundler-patch
gem install bundler-audit

# irb / rails console additions
gem install awesome_print
gem install brice
gem install added_methods

# parallel bundler job processing
# https://gist.github.com/cbrunsdon/f9cfe01d7278e2bbc0d4
bundle config --global jobs 4
bundle config --global path vendor/bundle
bundle config --global disable_shared_gems 1
bundle config --global disable_local_branch_check true

# need to reload the env to get `bundle`
source ~/.bash_profile

brew cleanup

# setup default extension handlers

duti < ~/.duti
