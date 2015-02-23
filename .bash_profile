# https://discussions.apple.com/thread/2173922
[[ ${-#*i} != ${-} ]] || return

# brew
export PATH="/usr/local/sbin:$PATH"

# load in rbenv
if [[ ! -z `which rbenv` ]]; then
	eval "$(rbenv init -)"
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
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults
