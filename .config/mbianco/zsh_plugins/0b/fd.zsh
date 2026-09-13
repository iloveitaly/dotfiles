# 100 runs of `fd --gen-completions zsh`: ~1.7 ms/run.
# Note: This may conflict with a system-installed completion.
#
# fpath + #compdef cache — must load in 0b/ before the compinit pivot.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_fd"

if (( $+commands[fd] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    fd --gen-completions zsh >| "$cache_file"
  fi
  fpath+=$plugin_dir
fi
