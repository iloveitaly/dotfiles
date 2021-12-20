#!/bin/bash

# os x application install
# make sure brew.sh is run first

brew tap caskroom/versions
brew tap caskroom/fonts

brew install --cask google-chrome
brew install --cask alfred
brew install --cask dropbox
brew install --cask dozer
brew install --cask 1password
brew install --cask google-backup-and-sync
brew install --cask istat-menus
brew install --cask iterm2
brew install --cask slack
brew install --cask amazon-music
brew install --cask atom
brew install --cask github
brew install --cask soulver
brew install --cask stay
brew install --cask kaleidoscope
brew install --cask skype
brew install --cask postgres
brew install --cask rectangle
brew install --cask valentina-studio
brew install --cask insync
brew install --cask libreoffice
brew install --cask rescuetime
brew install --cask onyx
brew install --cask cyberduck
brew install --cask dash
brew install --cask skyfonts
brew install --cask macdown
brew install --cask base
brew install --cask colorpicker-skalacolor
brew install --cask https://raw.githubusercontent.com/Homebrew/homebrew-cask/5b112c6a968113fb37d147f854451fb0988bd4db/Casks/arq.rb
brew install --cask fantastical
brew install --cask lunchy
brew install --cask psequel
brew install --cask paparazzi
brew install --cask messenger
brew install --cask scrivener
brew install --cask postico
brew install --cask kindle
brew install --cask wordpresscom
brew install --cask gpg-suite
brew install --cask grammarly
brew install --cask launchcontrol
brew install --cask hyper
brew install --cask typora
brew install --cask gitscout
brew install --cask sublime-text
brew install --cask google-chrome-canary
brew install --cask rdm
brew install --cask zoomus
brew install --cask amazon-drive
brew install --cask harvest
brew install --cask the-unarchiver
brew install --cask sketch
brew install --cask disk-sensei
brew install --cask flux
brew install --cask paw
brew install --cask epichrome
brew install --cask safari-technology-preview
brew install --cask openrefine-dev
brew install --cask ngrok
brew install --cask lepton
brew install --cask muzzle
brew install --cask https://raw.githubusercontent.com/Homebrew/homebrew-cask/00a37cb6ea00ca2820652b75ebd1f57ba160c3e5/Casks/screenflow.rb
brew install --cask visual-studio-code
brew install --cask cloudapp
brew install --cask mongodb-compass-community
brew install --cask pock
brew install --cask youtube-dl
brew install --cask contexts
brew install --cask chromedriver
brew install --cask docker
brew install --cask monitorcontrol
brew install --cask activitywatch
brew install --cask discord
brew install --cask keybase
brew install --cask telegram
brew install --cask sequel-ace
brew install --cask --no-quarantine alacritty
# helpful for phone-only applications that you want to run your mac without apple silicon
brew install --cask bluestacks
brew install --cask tip
brew install --cask kite

# quicklook plugins https://github.com/sindresorhus/quick-look-plugins
brew install --cask qlmarkdown \
		  qlimagesize \
			syntax-highlight \
		  webpquicklook

# fonts
brew install --cask font-source-code-pro
brew install --cask font-hack
brew install --cask font-roboto-mono-nerd-font