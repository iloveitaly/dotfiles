#!/bin/bash

if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "Brew is installed. Make sure bootstrap.bash has been run and then rerun this command"
	exit 0
fi

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew, and upgrade any already-installed formulae
brew update && brew upgrade

brew bundle -v || (echo "Brewfile failed, exiting early" && exit 1)
brew cleanup

# for 1password integration with raycast
# all service data localed in ~/.config/op/bookmarks
brew services start opbookmarks

# shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
(cd ~/.config/ && curl -LO https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/master/Snazzy.itermcolors) && open ~/.config/Snazzy.itermcolors

# run after nanorc is copied, this modifies nanorc
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

# iTerm copy mode conflicted with a previous shortcut that I have seared into my memory
# however, I can remap this via macos config. TODO would be great to move this over to `osx.sh`
# https://www.intego.com/mac-security-blog/how-to-make-custom-keyboard-shortcuts-for-any-macos-menu-items-and-to-launch-your-favorite-apps/

# set zsh as default shell
# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
sudo dscl . -create $HOME UserShell /opt/homebrew/bin/zsh

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
source ~/.asdf/asdf.sh

# install all plugins in tool-versions
cat ~/.tool-versions | cut -d' ' -f1 | grep "^[^\#]" | xargs -I{} asdf plugin add {}

# fail on subshell error when installing language versions
set -e
asdf install
asdf reshim
set +e

# php / WordPress
# https://github.com/asdf-community/asdf-php/blob/248e9c6e2a7824510788f05e8cee848a62200b65/bin/install#L22

# common php extensions
# check if pecl extension redis is installed as a shell script
# https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script

echo "Installing PHP pecl extensions..."
pecl install redis </dev/null
# imagick is not supported on php8 yet
# https://github.com/Imagick/imagick/issues/358
pecl install imagick </dev/null
pecl install ast </dev/null
pecl install xdebug </dev/null
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

# node
# remember to use `npx npkill` to remove unneeded `node_modules` folders
npm install -g npm
npm install -g hostile
npm install -g yarn

# python
# note: for each python version installed, you'll need to do this
# for the breakpoint() magic to work properly
pip install --upgrade pip
pip install ipython ipdb pdbr ipython-autoimport rich

# mysql setup
# brew services start mysql
# make sure you run `mysql_secure_installation` and set password to root

# ruby configuration
gem install notes
gem install bundle
gem install method_log
gem install bundler-patch
gem install bundler-audit

# irb / rails console additions
gem install awesome_print
gem install brice
gem install added_methods
gem install looksee
gem install solargraph

# parallel bundler job processing
# https://gist.github.com/cbrunsdon/f9cfe01d7278e2bbc0d4
bundle config --global jobs 4
bundle config --global path vendor/bundle
bundle config --global disable_shared_gems 1
bundle config --global disable_local_branch_check true

# allow touch id for sudo
sudo-touchid

# let programs that don't properly source the shell know where gpg is
# https://github.com/denolehov/obsidian-git/issues/21
git config --global gpg.program $(which gpg)

# easily create new codespaces for a repo
gh alias set cs-create --shell 'gh cs create --repo $(gh repo view --json nameWithOwner | jq -r .nameWithOwner)'

