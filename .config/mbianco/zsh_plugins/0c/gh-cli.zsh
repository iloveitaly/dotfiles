# make sure you execute this *after* asdf or other version managers are loaded

cache_file="${0:A:h}/alias_cache.zsh"

if (( $+commands[gh] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    gh copilot alias -- zsh > "$cache_file"
    gh completion --shell zsh >> "$cache_file"
  fi
  
  source "$cache_file"
  compdef _gh gh
fi
