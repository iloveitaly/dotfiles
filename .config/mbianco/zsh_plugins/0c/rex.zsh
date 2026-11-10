# gtime rex completion zsh > /dev/null: ~0.01s (bundled Rex Beta CLI); cache for 15 days.

if (( $+commands[rex] )); then
  plugin_dir="${0:A:h}"
  cache_file="$plugin_dir/_rex"

  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    rex completion zsh >| "$cache_file"
  fi

  source "$cache_file"
  compdef _rex rex
fi
