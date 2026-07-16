# gtime railway completion zsh > /dev/null
# 0.11user 0.07system 0:00.45elapsed 43%CPU (0avgtext+0avgdata 27952maxresident)k
# 0inputs+0outputs (378major+3450minor)pagefaults 0swaps
#
# Cache the script, then source it (post-compinit). fpath-only is wrong after
# zicompinit — #compdef is only honored at compinit time.

name="railway"
plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_$name"

if (( $+commands[railway] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    railway completion zsh >| "$cache_file"
  fi
  source "$cache_file"
fi
