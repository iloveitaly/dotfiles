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

# os x application install

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew cask install google-chrome
brew cask install alfred
brew cask install dropbox
brew cask install bartender
brew cask install onepassword
brew cask install google-drive
brew cask install sequel-pro
brew cask install soulver
brew cask install istat-menus
brew cask install forklift
brew cask install iterm2
brew cask install todoist
brew cask install slack
brew cask install mactracker
brew cask install omnigraffle
brew cask install firefox
brew cask install amazon-music
brew cask install atom
brew cask install evernote
brew cask install github
brew cask install soulver
brew cask install stay
brew cask install kaleidoscope
brew cask install colorschemer-studio
brew cask install skype
brew cask install taskpaper
brew cask install flux
brew cask install postgres
brew cask install toggldesktop
brew cask install spotify
brew cask install spectacle
brew cask install mou
brew cask install heroku-toolbelt
brew cask install adobe-creative-cloud
brew cask install java7
brew cask install valentina-studio
brew cask install insync
brew cask install libreoffice
brew cask install rescuetime
brew cask install bee

brew cask alfred link

# TODO test if CC is already installed
open “/opt/homebrew-cask/Caskroom/adobe-creative-cloud/latest/Creative Cloud Installer.app”

brew cask install sublime-text3
brew cask install google-chrome-canary

# quicklook plugins https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql webp-quicklook suspicious-package


# App Store / Manual Installations
#   * Billings Pro
#   * Twitter
#   * Air Mail
#   * Dash
#   * Pixemator
#   * Sketch

# Make sure we’re using the latest Homebrew, and upgrade any already-installed formulae
brew update && brew upgrade

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

# php
brew tap josegonzalez/php
brew tap homebrew/dupes
brew install php53
brew install wp-cli

# node
if ! command -v brew >/dev/null; then
	curl http://npmjs.org/install.sh | sh
	npm install -g coffee-script
	npm install -g bower
fi

npm update -g

# ruby
brew install icu4c
brew install autoconf
RUBY_VERSION=1.9.3-p551
brew install rbenv
brew install ruby-build

. ~/.bash_profile

if [[ `rbenv global` != $RUBY_VERSION ]]; then
	rbenv install $RUBY_VERSION
	rbenv rehash
	rbenv global $RUBY_VERSION
	. ~/.bash_profile
fi

# rails tools
brew install mysql
$(brew --prefix mysql)/bin/mysqladmin -u root password root
brew install sqlite
brew install vagrant
# vagrant box add ubuntu-12.04 http://files.vagrantup.com/precise64.box
brew install siege
brew install sqlite

# http://xquartz.macosforge.org/landing/
# imagemagick + rmagic issues: https://gist.github.com/3177887

gem install notes
gem install powder
gem install cocoapods
gem install bundle
gem install papertrail

powder install

# parallel bundler job processing
# https://gist.github.com/cbrunsdon/f9cfe01d7278e2bbc0d4
source ~/.bash_profile
bundle config --global jobs 4
bundle config --global path vendor/bundle
bundle config --global disable-shared-gems 1
bundle config --global disable-local-branch-check true

# irb / rails console additions
gem install awesome_print
gem install brice
gem install added_methods

brew cleanup

# setup default extension handlers

duti < ~/.duti

# symlink application preferences to Dropbox

if [ ! -d ~/Dropbox ]; then
	echo “Dropbox is not installed. Install DropBox to symlink preferences”
	exit 1
fi

# symlink preference files

function preference_link {
	rm ~/Library/Preferences/*$1*
	ln -s $HOME/Dropbox/ApplicationSupport/Preferences/$1 ~/Library/Preferences/$1
}

# sublime
rm -R "$HOME/Library/Application Support/Sublime Text 3/Packages/"* "$HOME/Library/Application Support/Sublime Text 3/Installed Packages/"*
ln -s $HOME/Dropbox/ApplicationSupport/SublimeText3/Packages/* "$HOME/Library/Application Support/Sublime Text 3/Packages"
ln -s $HOME/Dropbox/ApplicationSupport/SublimeText3/InstalledPackages/* "$HOME/Library/Application Support/Sublime Text 3/Installed Packages"

# forklift
preference_link "com.binarynights.ForkLift2.plist"

# istatmenus
preference_link "com.bjango.istatmenus.plist"

# sequel pro
preference_link "com.google.code.sequel-pro.plist"

# soulver
preference_link "com.acqualia.soulver.plist"

# sequel pro
mkdir -p "$HOME/Library/Application Support/Sequel Pro/"
rm -Rf "$HOME/Library/Application Support/Sequel Pro/"*
ln -s $HOME/Dropbox/ApplicationSupport/SequelPro/* "$HOME/Library/Application Support/Sequel Pro/"
