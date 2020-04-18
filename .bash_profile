# https://discussions.apple.com/thread/2173922
[[ ${-#*i} != ${-} ]] || return

# https://www.iterm2.com/documentation-shell-integration.html
. ~/.iterm2_shell_integration.bash

# brew
export PATH="/usr/local/sbin:$PATH"

# postgres
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# load in rbenv
if [[ ! -z `which rbenv` ]]; then
	eval "$(rbenv init -)"
fi

if [[ ! -z `which asdf` ]]; then
  . `brew --prefix asdf`/asdf.sh
  . `brew --prefix asdf`/etc/bash_completion.d/asdf.bash
fi

# mkdir .git/safe in the root of repositories you trust, for binstubs
export PATH=".git/safe/../../bin:$PATH"

# Load ~/.bash_prompt, ~/.exports, ~/.aliases, ~/.functions and ~/.extra
# ~/.extra can be used for settings you don’t want to commit
for file in bash_prompt exports aliases functions extra; do
  file="$HOME/.$file"
  [ -e "$file" ] && source "$file"
done

# git autocompletion
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Autocomplete for 'g' as well
complete -o default -o nospace -F _git g