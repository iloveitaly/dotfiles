# =============
# Completion
# =============

# forces zsh to realize new commands
zstyle ':completion:*' completer _oldlist _expand _complete _match _ignored _approximate

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# rehash if command not found (possibly recently installed)
zstyle ':completion:*' rehash true

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# =============
# Shell Options
# =============

setopt interactive_comments
setopt prompt_subst
setopt extended_glob

# Set history behavior
setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_space        # Ignore items that start with a space
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.

# =============
# Evals
# =============

# https://www.iterm2.com/documentation-shell-integration.html
source ~/.iterm2_shell_integration.zsh

eval $(brew shellenv)

# load in rbenv
if type rbenv > /dev/null; then
	eval "$(rbenv init -)"
fi

if type asdf > /dev/null; then
  source `brew --prefix asdf`/asdf.sh
fi

# Load ~/.exports, ~/.aliases, ~/.functions and ~/.extra
# ~/.extra can be used for settings you don’t want to commit
for file in exports aliases functions extra; do
  file="$HOME/.$file"
  [ -e "$file" ] && source "$file"
done

unset file

# =============
# Antibody Plugins
# =============

# faster antibody loading
# ttps://github.com/ephur/zshrc/blob/41850e3335e718ab9d70f2e6583e6137694e7845/antibody_setup.zsh
function update_zsh_plugins() {
  antibody bundle < ${HOME}/.zsh_plugins > ${ZSH_CACHE_DIR}/antibody_plugins.zsh
  antibody update

  antibody_cache=`antibody home`

  for i in `find $antibody_cache -name '*.zsh' -print`; do
    zcompile ${i} >/dev/null 2>&1
  done

  zcompile ${ZSH_CACHE_DIR}/antibody_plugins.zsh
}

if type antibody > /dev/null; then
  if [ ! -f "${ZSH_CACHE_DIR}/antibody_plugins.zsh" ]; then
    update_zsh_plugins
  fi

  source ${ZSH_CACHE_DIR}/antibody_plugins.zsh
else
  echo "Antibody is not present in path, get it at: https://getantibody.github.io/"
fi

# =============
# Keybindings
# =============

autoload -Uz compinit compaudit
compinit

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down