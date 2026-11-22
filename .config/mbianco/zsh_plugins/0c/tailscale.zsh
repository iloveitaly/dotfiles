# gtime tailscale completion zsh > /dev/null: ~0.03s (2026-11-18); cache for 15 days.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_tailscale"

if (( $+commands[tailscale] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    tailscale completion zsh >| "$cache_file"
  fi
  source "$cache_file"
  compdef _tailscale tailscale
fi
