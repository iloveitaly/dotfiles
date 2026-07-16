plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_ov"

if (( $+commands[ov] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    ov --completion zsh > "$cache_file"
    
  fi
  
  fpath+=$plugin_dir
fi