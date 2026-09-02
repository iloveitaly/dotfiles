# 100 runs of `fd --gen-completions zsh`: ~1.7 ms/run.
# Note: This may conflict with a system-installed completion.
#
# fpath + #compdef cache — must load in 0b/ before the compinit pivot.

if (( $+commands[fd] )); then
  local plugin_dir="${0:A:h}"
  local cache_file="$plugin_dir/_fd"

  fd --gen-completions zsh >| "$cache_file"
  fpath+=$plugin_dir
fi
