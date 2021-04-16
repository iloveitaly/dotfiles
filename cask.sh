#!/bin/bash

# os x application install
# make sure brew.sh is run first

brew tap caskroom/versions
brew tap caskroom/fonts

brew cask install google-chrome
brew cask install alfred
brew cask install dropbox
brew cask install bartender
brew cask install 1password
brew cask install google-backup-and-sync
brew cask install istat-menus
brew cask install iterm2
brew cask install slack
brew cask install amazon-music
brew cask install atom
brew cask install github
brew cask install soulver
brew cask install stay
brew cask install kaleidoscope
brew cask install skype
brew cask install postgres
brew cask install rectangle
brew cask install valentina-studio
brew cask install insync
brew cask install libreoffice
brew cask install rescuetime
brew cask install onyx
brew cask install cyberduck
brew cask install dash
brew cask install skyfonts
brew cask install macdown
brew cask install base
brew cask install colorpicker-skalacolor
brew cask install https://raw.githubusercontent.com/Homebrew/homebrew-cask/5b112c6a968113fb37d147f854451fb0988bd4db/Casks/arq.rb
brew cask install fantastical
brew cask install lunchy
brew cask install psequel
brew cask install paparazzi
brew cask install messenger
brew cask install scrivener
brew cask install postico
brew cask install kindle
brew cask install wordpresscom
brew cask install gpg-suite
brew cask install grammarly
brew cask install kitematic
brew cask install launchcontrol
brew cask install hyper
brew cask install typora
brew cask install gitscout
brew cask install sublime-text
brew cask install google-chrome-canary
brew cask install rdm
brew cask install zoomus
brew cask install amazon-drive
brew cask install harvest
brew cask install the-unarchiver
brew cask install sketch
brew cask install disk-sensei
brew cask install flux
brew cask install paw
brew cask install epichrome
brew cask install safari-technology-preview
brew cask install qbserve
brew cask install openrefine-dev
brew cask install ngrok
brew cask install lepton
brew cask install muzzle
brew cask install https://raw.githubusercontent.com/Homebrew/homebrew-cask/00a37cb6ea00ca2820652b75ebd1f57ba160c3e5/Casks/screenflow.rb
brew cask install visual-studio-code
brew cask install cloudapp
brew cask install mongodb-compass-community
brew cask install pock
brew cask install youtube-dl
brew cask install contexts
brew cask install chromedriver
brew cask install docker
brew cask install monitorcontrol
brew cask install activitywatch
brew cask install discord
brew cask install keybase
brew cask install telegram
brew cask install sequel-ace
brew cask install --no-quarantine alacritty
# helpful for phone-only applications that you want to run your mac without apple silicon
brew cask install bluestacks

# quicklook plugins https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode \
		  qlstephen \
		  qlmarkdown \
		  quicklook-json \
		  qlimagesize \
		  webpquicklook

# fonts
brew cask install font-source-code-pro
brew cask install font-hack
