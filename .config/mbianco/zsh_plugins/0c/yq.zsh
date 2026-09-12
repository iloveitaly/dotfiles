# yq shell-completion zsh is ~10ms.
plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_yq"

if (( $+commands[yq] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    yq shell-completion zsh >| "$cache_file"
  fi
  source "$cache_file"
  compdef _yq yq
fi
