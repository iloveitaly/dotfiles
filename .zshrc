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

# force completion generation for more obscure commands
# TODO unsure if vitest + eslint will really work here automatically given it's installed via pnpm
# TODO look at mise usage tool here, could be a bit better
zstyle :plugin:zsh-completion-generator programs ncdu tre vitest eslint fastmod ipython fzf

# =============
# fzf-tab config
# =============

# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# don't show fzf unless there are more than 4 items
# zstyle ':fzf-tab:*' ignore false 4

# =============
# Shell Options
# man: zshoptions
# =============

setopt interactive_comments
setopt prompt_subst
setopt extended_glob            # Allow extended matchers like ^file, etc
setopt long_list_jobs
setopt auto_cd
setopt menu_complete            # Auto pick a menu match

# Set history behavior
setopt share_history            # Share history across session
setopt inc_append_history       # Dont overwrite history, add new entries immediately
setopt extended_history         # Also record time and duration of commands.
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.

# Evals
# =============

# we tried linux homebrew, but it's terrible :/
brew_path="/opt/homebrew/bin/brew"
if [[ -x "$brew_path" ]]; then
  eval "$($brew_path shellenv)"
fi

# postgres utilities
export PATH="/Applications/Postgres.app/Contents/Versions/16/bin:$PATH"

# poetry, orb, etc
export PATH="$HOME/.local/bin:$PATH"

# TODO really? shouldn't we do this in the bun plugin? Or can we redirect installs?
export PATH="$HOME/.bun/bin:$PATH"

# for latest gnu make
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# TODO I don't understand where this comes from, but it seems to be used by some completion libraries
fpath+=~/.zfunc

# avoid installation via brew, this is not a supported installation method and breaks
# some directory structure assumptions that exist across the plugin ecosystem.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load ~/.exports, ~/.aliases, ~/.functions and ~/.extra
# ~/.extra can be used for settings you don’t want to commit
for file in exports aliases functions extra; do
  file="$HOME/.$file"
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

# cmd+shift+k is not possible in the terminal without remapping cmd, which is not a good idea given it's lack of support
# opt+shift+k deletes backward, ctrl+U defaults to kill-whole-line
bindkey "^[K" backward-kill-line

# open up current command in EDITOR, ctrl+x then ctrl+e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# save current command in buffer & restore after next command is run
# https://unix.stackexchange.com/a/74381
autoload -U push-input
# not sure why, but ^S is not getting passed to the terminal
bindkey '^X^P' push-input

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

# since we can't use the default kill detached in tmux, we need to do it ourselves
setopt localoptions nomonitor
(tmux-kill-detached-sessions &> /dev/null &) & disown
setopt localoptions monitor

# ===============
# Word Definition
# ===============

# http://mikebian.co/fixing-word-navigation-in-zsh/
WORDCHARS='@*?_-.[]~=&;!#$%^(){}<>/ '$'\n'$'\u00A0'
autoload -Uz select-word-style
select-word-style normal
zstyle ':zle:*' word-style unspecified

# TODO couldn't get the async piece of this working
# async_start_worker kill_detached_sessions -n
# async_job kill_detached_sessions tmux list-sessions \| grep -v attached \| grep -E '^\d{1,3}' \| awk -F: '{print $1}' \| xargs -I {} tmux kill-session -t {}

# ======================
# Custom Word Navigation
# ======================

custom-backward-word() {
  local delimiters=' ,'  # Customize delimiters here
  while (( CURSOR > 0 )) && [[ $delimiters = *${BUFFER[$CURSOR]}* ]]; do
    (( CURSOR-- ))
  done
  while (( CURSOR > 0 )) && [[ $delimiters != *${BUFFER[$CURSOR]}* ]]; do
    (( CURSOR-- ))
  done
}

custom-forward-word() {
  local delimiters=' ,'  # Same delimiters
  local len=${#BUFFER}
  while (( CURSOR < len )) && [[ $delimiters != *${BUFFER[$CURSOR+1]}* ]]; do
    (( CURSOR++ ))
  done
  while (( CURSOR < len )) && [[ $delimiters = *${BUFFER[$CURSOR+1]}* ]]; do
    (( CURSOR++ ))
  done
}

zle -N custom-backward-word
zle -N custom-forward-word

bindkey '^[[1;7D' custom-backward-word  # Opt+Ctrl+Left
bindkey '^[[1;7C' custom-forward-word   # Opt+Ctrl+Right

# ======================
# Custom Backward Kill Word
# Enables a different set of stop characters for backward-kill-word
# ======================

custom-backward-kill-word() {
  # Define stop characters
  local MY_STOP_CHARS=' '

  # Exit if LBUFFER is empty
  [[ -z $LBUFFER ]] && return 0

  # Split LBUFFER into an array of characters
  local -a buffer_array
  buffer_array=(${(s::)LBUFFER})

  # Start from the end
  local pos=$#buffer_array

  # Skip trailing stop characters
  while (( pos > 0 )) && [[ $MY_STOP_CHARS == *$buffer_array[$pos]* ]]; do
    (( pos-- ))
  done

  # Find the next stop character backward
  while (( pos > 0 )); do
    local char=$buffer_array[$pos]
    if [[ $MY_STOP_CHARS == *$char* ]]; then
      break
    fi
    (( pos-- ))
  done

  # Adjust LBUFFER
  if (( pos > 0 )); then
    LBUFFER="${LBUFFER:0:$pos}"
  else
    LBUFFER=""
  fi
}

zle -N custom-backward-kill-word
bindkey '\e^W' custom-backward-kill-word

# ===============================
# Directory-aware Autocomplete History
# https://github.com/atuinsh/atuin/issues/1618
# ===============================

# Add --cwd flag to have auto-workspace-detection active
_zsh_autosuggest_strategy_atuin_auto() {
    suggestion=$(atuin search --cwd . --cmd-only --limit 1 --search-mode prefix -- "$1")
}

_zsh_autosuggest_strategy_atuin_global() {
    suggestion=$(atuin search --cmd-only --limit 1 --search-mode prefix -- "$1")
}

export ZSH_AUTOSUGGEST_STRATEGY=(atuin_auto atuin_global)
# autocomplete on completions as well
# export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
