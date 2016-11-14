#!/bin/bash

# os x application install
# make sure brew.sh is run first

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew cask install google-chrome
brew cask install alfred
brew cask install dropbox
brew cask install bartender
brew cask install 1password
brew cask install google-drive
brew cask install sequel-pro
brew cask install soulver
brew cask install istat-menus
brew cask install forklift
brew cask install iterm2
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
brew cask install flash
brew cask install microsoft-intellitype
brew cask install xtrafinder
brew cask install coteditor
brew cask install onyx
brew cask install cyberduck
brew cask install dash
brew cask install monotype-skyfonts
brew cask install chromecast
brew cask install macdown
brew cask install base
brew cask install mailplane
brew cask install openrefine
brew cask install launchrocket
brew cask install undercover
brew cask install colorpicker-skalacolor
brew cask install recordit
brew cask install screenhero
brew cask install arq
brew cask install fantastical
brew cask install lunchy
brew cask install psequel
brew cask install paparazzi
brew cask install rightfont
brew cask install messenger
brew cask install gitter
brew cask install scrivener
brew cask install postico
brew cask install focus
brew cask install kindlepreviewer
brew cask install appcleaner
brew cask install wordpresscom
brew cask install gpgtools
brew cask install safari-technology-preview
brew cask install grammarly
brew cask install kitematic
brew cask install launchcontrol
brew cask install hyperterm
brew cask install soundflowerbed
brew cask install soundflower
brew cask install typora
brew cask install tripmode
brew cask install calendly-click
brew cask install quickbooks

# TODO test if CC is already installed
open "/opt/homebrew-cask/Caskroom/adobe-creative-cloud/latest/Creative Cloud Installer.app"

brew cask install sublime-text3
brew cask install google-chrome-canary
brew cask install rdm

# quicklook plugins https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode \
		  qlstephen \
		  qlmarkdown \
		  quicklook-json \
		  qlprettypatch \
		  quicklook-csv \
		  webp-quicklook

# App Store / Manual Installations
#
#   * Twitter
#   * Pixemator
#   * Sketch
#   * Glui
#   * Todoist
#   * Icon Slate
#   * Textual
