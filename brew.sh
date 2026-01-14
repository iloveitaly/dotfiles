#!/bin/bash

if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Brew is installed. Make sure bootstrap.bash has been run and then rerun this command"
  exit 0
fi

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Make sure we’re using the latest Homebrew, and upgrade any already-installed formulae
brew update && brew upgrade

brew bundle -v || (echo "Brewfile failed, exiting early" && exit 1)
brew cleanup

# shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
(cd ~/.config/ && curl -LO https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/master/Snazzy.itermcolors) && open ~/.config/Snazzy.itermcolors

# run after nanorc is copied, this modifies nanorc
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | bash -s -- --lite

# iTerm copy mode conflicted with a previous shortcut that I have seared into my memory
# however, I can remap this via macos config. TODO would be great to move this over to `osx.sh`
# https://www.intego.com/mac-security-blog/how-to-make-custom-keyboard-shortcuts-for-any-macos-menu-items-and-to-launch-your-favorite-apps/

# set zsh as default shell
# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
sudo dscl . -create $HOME UserShell /opt/homebrew/bin/zsh

curl https://mise.run | sh
eval "$(mise activate zsh)"
mise install -y

# TODO is this the best place? Maybe in zsh plugins or something?
ya pkg add yazi-rs/plugins:git

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
" >$(asdf where php)/conf.d/php.ini

# node
# remember to use `npx npkill` to remove unneeded `node_modules` folders
# tried bun + pnpm, but they do not have as good support by mise, it's easier to use npm for tooling
pnpm install -g hostile
pnpm install -g wrangler@latest
pnpm install -g yalc

# all of the cli coding tools
pnpm install -g @sourcegraph/amp
pnpm install -g @google/gemini-cli
pnpm install -g @anthropic-ai/claude-code
pnpm install -g @openai/codex
pnpm approve-builds -g

# let programs that don't properly source the shell know where gpg is
# https://github.com/denolehov/obsidian-git/issues/21
git config --global gpg.program $(which gpg)

# easily create new codespaces for a repo
gh alias set cs-create --shell 'gh cs create --repo $(gh repo view --json nameWithOwner | jq -r .nameWithOwner)'
# create a new public repo from the current directory and enable github actions
gh alias set repo-create --clobber --shell 'repo=$(basename $PWD) && gh repo create --public --source $PWD $repo && owner=$(gh repo view --json owner -q .owner.login) && gh api -X PUT repos/$owner/$repo/actions/permissions -F enabled=true'
gh alias set repo-create-private --clobber --shell 'repo=$(basename $PWD) && gh repo create --private --source $PWD $repo && owner=$(gh repo view --json owner -q .owner.login) && gh api -X PUT repos/$owner/$repo/actions/permissions -F enabled=true'
gh alias set repo-url --clobber --shell 'url=$(gh repo view --json url --jq ".url" | tr -d " \n"); echo -n "$url" | pbcopy && echo "$url"'
gh alias set repo-events --clobber --shell 'gh api repos/$(gh repo view --json owner -q ".owner.login")/$(gh repo view --json name -q ".name")/events'
gh alias set myprs --clobber --shell 'id=$(set -e; gh pr list --state=all -L100 --author $(git config github.user) $@ | fzf | cut -f1); [ -n "$id" ] && gh pr view "$id" --web && echo "$id"'
