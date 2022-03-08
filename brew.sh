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

# systems
brew install node

# Everything else
brew install mackup
brew install mas
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
brew install iftop
brew install webkit2png
brew install jq
brew install ngrok
brew install lftp
brew install gist
brew install spoof-mac
brew install httpie
brew install awscli
brew install ansible
brew install heroku/brew/heroku
brew install cloc
brew install ffmpeg gifsicle
brew install github/gh/gh
brew install q # sql on csv
brew install dsq # sql over json and other formats
brew install yq # yq for yaml and others
brew install dasel # consistent language for extracting data from XML, CSV, and others
brew install free-ruler
brew install saulpw/vd/visidata
brew install hey
brew install gh
brew install htmlq
brew install rga
brew install xsv
brew install dust
brew install pandoc
# helpful dependencies for rga
brew install pandoc poppler tesseract ffmpeg

# shell
brew install zsh
brew install ripgrep
brew install entr
brew install prettyping
brew install less
brew install nano
brew install fd # find
brew install tldr
brew install fasd
brew install fzf
brew install diff-so-fancy
brew install bat # cat
brew install exa # ls
brew install tmux
brew install tre-command
brew install terminal-notifier # for `zsh-notify`
brew install cod
brew install zinit
brew install procs # ps
brew install sd # sed
brew install svn # for `zinit ice svn`
brew install fig
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
(cd ~ && curl -LO https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/master/Snazzy.itermcolors) && open ~/Snazzy.itermcolors

# run after nanorc is copied, this modifies nanorc
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

# iTerm copy mode conflicted with a previous shortcut that I have seared into my memory
# however, I can remap this via macos config. TODO would be great to move this over to `osx.sh`
# https://www.intego.com/mac-security-blog/how-to-make-custom-keyboard-shortcuts-for-any-macos-menu-items-and-to-launch-your-favorite-apps/

# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
sudo dscl . -create $HOME UserShell /usr/local/bin/zsh

# php / WordPress
# https://github.com/asdf-community/asdf-php/blob/248e9c6e2a7824510788f05e8cee848a62200b65/bin/install#L22
brew install bison bzip2 freetype gettext libiconv icu4c jpeg libedit libpng libxml2 libzip openssl readline webp zlib
brew install gmp libsodium imagemagick
asdf plugin-add php
asdf install php 7.4.16
asdf global php 7.4.16
asdf reshim

# common php extensions
pecl install redis
# imagick is not supported on php8 yet
# https://github.com/Imagick/imagick/issues/358
pecl install imagick
pecl install ast
pecl install xdebug
echo "extension=redis.so
extension=ast.so
extension=imagick.so
zend_extension=$(asdf where php)/lib/php/extensions/no-debug-non-zts-20200930/xdebug.so

display_errors=1
error_reporting=E_ALL
memory_limit=1024M

# xdebug.mode = debug
# xdebug.start_with_request = yes
# xdebug.client_port = 9000
" > $(asdf where php)/conf.d/php.ini

brew install wp-cli

# node
# remember to use `npx npkill` to remove unneeded `node_modules` folders
# TODO use `asdf` to install node
curl http://npmjs.org/install.sh | sh
npm install -g grunt
npm install -g livereloadx
npm install -g hostile
npm install -g yarn

# elixir
brew install asdf
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git

# python
asdf plugin-add python
pip install bpython

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
brew services start mysql
# make sure you run `mysql_secure_installation` and set password to root

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

# mongodb
brew tap mongodb/brew
brew install mongodb-compass
brew install mongodb-community

# need to reload the env to get `bundle`
source ~/.bash_profile

brew cleanup

# setup default extension handlers
duti < ~/.duti
