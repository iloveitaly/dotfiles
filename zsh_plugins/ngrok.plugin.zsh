plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_ngrok"

if (( $+commands[ngrok] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    ngrok completion zsh > "$cache_file"
  fi

  source "$cache_file"
fi