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

brew bundle

# macos
# some of these tools are strictly terminal related, but do not play well with linux/codespaces
brew install ffmpeg gifsicle
brew install mackup
brew install duti
brew install spoof-mac
brew install free-ruler
brew install keith/formulae/zap
brew install mas
brew install webkit2png
brew install rga
# helpful dependencies for rga
brew install pandoc poppler tesseract ffmpeg
brew install saulpw/vd/visidata # had trouble installing on linux
brew install fig
brew install ngrok

# shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
(cd ~ && curl -LO https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/master/Snazzy.itermcolors) && open ~/Snazzy.itermcolors

# run after nanorc is copied, this modifies nanorc
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

# iTerm copy mode conflicted with a previous shortcut that I have seared into my memory
# however, I can remap this via macos config. TODO would be great to move this over to `osx.sh`
# https://www.intego.com/mac-security-blog/how-to-make-custom-keyboard-shortcuts-for-any-macos-menu-items-and-to-launch-your-favorite-apps/

# set zsh as default shell
# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
sudo dscl . -create $HOME UserShell /opt/homebrew/bin/zsh

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

# TODO use `asdf` to install node

# node
# remember to use `npx npkill` to remove unneeded `node_modules` folders
asdf plugin-add deno
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
asdf install python 3.10.4
# note: for each python version installed, you'll need to do this
# for the breakpoint() magic to work properly
pip install ipython
pip install ipdb
pip install pdbr

# ruby
# 5.5 must be installed https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
brew install qt55
brew install cmake
brew install icu4c
brew install autoconf
brew install rbenv
brew install ruby-build
brew install puma/puma/puma-dev

rbenv install 2.6.10

rbenv rehash
rbenv global 2.6.10

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

brew cleanup

# setup default extension handlers
duti < ./duti
