# gtime gitleaks completion zsh > /dev/null
# ~0.18–0.22s — cache (slower than find ~2ms)
#
# Cache the script, then source it (post-compinit). fpath-only is wrong after
# zicompinit — #compdef is only honored at compinit time.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_gitleaks"

if (( $+commands[gitleaks] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    gitleaks completion zsh >| "$cache_file"
  fi
  source "$cache_file"
fi
