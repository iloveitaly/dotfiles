# bat --completion zsh is ~1.5ms.
# fpath + #compdef cache — must load in 0b/ before the compinit pivot.

if (( $+commands[bat] )); then
  local plugin_dir="${0:A:h}"
  local cache_file="$plugin_dir/_bat"

  bat --completion zsh >| "$cache_file"
  fpath+=$plugin_dir
fi
