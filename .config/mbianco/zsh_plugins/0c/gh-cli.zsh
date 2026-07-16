# make sure you execute this *after* asdf or other version managers are loaded

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_gh"

if (( $+commands[gh] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    gh completion --shell zsh >| "$cache_file"
  fi

  source "$cache_file"
  compdef _gh gh
fi
