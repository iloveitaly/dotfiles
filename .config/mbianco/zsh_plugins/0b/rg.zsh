# make sure you execute this *after* asdf or other version managers are loaded

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_rg"

if (( $+commands[rg] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    rg --generate=complete-zsh > "$cache_file"
  fi
  
  # rg completion script cannot be executed directly
  fpath+=$plugin_dir
fi