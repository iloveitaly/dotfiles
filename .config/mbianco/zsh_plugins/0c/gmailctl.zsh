# gtime gmailctl completion zsh > /dev/null
# ~14–18 ms — cache (slower than find ~2ms)
#
# Cache the script, then source it (post-compinit). fpath-only is wrong after
# zicompinit — #compdef is only honored at compinit time.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_gmailctl"

if (( $+commands[gmailctl] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    gmailctl completion zsh >| "$cache_file"
  fi
  source "$cache_file"
  # zinit multisrc may skip trailing compdef inside the generated script
  compdef _gmailctl gmailctl
fi
