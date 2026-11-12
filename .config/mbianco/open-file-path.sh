#!/usr/bin/env zsh
# Description: hook for tmux-fastcopy / extrakto / fzf to open files with line & column references in nvim/cursor

source "${0:A:h}/navigation" 2>/dev/null || source "${HOME}/.config/mbianco/navigation" 2>/dev/null

if [[ $1 == "CURSOR" ]]; then
  shift
  [[ -z "$1" ]] && exit 0
  open_in_cursor "$@"
else
  # Default to open_in_nvim; strip optional EDITOR prefix if passed
  [[ $1 == "EDITOR" ]] && shift
  [[ -z "$1" ]] && exit 0
  open_in_nvim "$@"
fi
