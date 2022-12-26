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

# speed https://coderwall.com/p/9fksra/speed-up-your-zsh-completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# don't show fzf unless there are more than 4 items
zstyle ':fzf-tab:*' ignore false 4

# =============
# Shell Options
# =============

setopt interactive_comments
setopt prompt_subst
setopt extended_glob            # Allow extended matchers like ^file, etc
setopt long_list_jobs
setopt auto_cd
setopt menu_complete            # Auto pick a menu match

# Set history behavior
setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_space        # Ignore items that start with a space
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.

# =============
# Evals
# =============

export PATH="/opt/homebrew/bin:$PATH"
eval $(brew shellenv)

# in some environments, the package may not be available in brew
local possible_zinit_home=${HOME}/.local/share/zinit/zinit.git
if [ -f $possible_zinit_home/zinit.zsh ]; then
  ZINIT_HOME=$possible_zinit_home
  source "${ZINIT_HOME}/zinit.zsh"
else
  source `brew --prefix zinit`/zinit.zsh
fi

# TODO https://github.com/zdharma/zinit/issues/173#issuecomment-537325714
# Load ~/.exports, ~/.aliases, ~/.functions and ~/.extra
# ~/.extra can be used for settings you don’t want to commit
for file in exports aliases functions extra; do
  local file="$HOME/.$file"
  [ -e "$file" ] && source "$file"
done

source ~/.zsh_plugins

# ===========
# Keybindings
# ===========

bindkey "^[[A" history-substring-search-up # Up
bindkey "^[[B" history-substring-search-down # Down

# match vscode's ^k functionality
bindkey "^K" kill-line

# open up current command in EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# save current command in buffer & restore after next command is run
# https://unix.stackexchange.com/a/74381
# TODO what is the binding here? ctrl+s isn't working for me
bindkey "^s" push-input

# ===========
# Misc Config
# ===========

# https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path
typeset -aU path

# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/misc.zsh
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# stop autosuggesting after ^w or ^k is pressed
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(backward-kill-word kill-line)

# =======================================
# zsh-autosuggest & bracketed-paste-magic
# =======================================

# copied from https://github.com/zsh-users/zsh-autosuggestions/issues/351#issuecomment-588235793
# hopefully this is fixed in zsh-autosuggest in the future

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# https://github.com/zsh-users/zsh-autosuggestions/issues/351
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'