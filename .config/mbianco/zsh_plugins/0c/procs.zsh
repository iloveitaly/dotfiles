# gtime procs --gen-completion-out zsh > /dev/null
# ~8 ms — under the 10 ms startup threshold, but cache anyway (no need for
# freshness at every shell start).
#
# Cache the script, then source it (post-compinit). fpath-only is wrong after
# zicompinit — #compdef is only honored at compinit time.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_procs"

if (( $+commands[procs] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    procs --gen-completion-out zsh >| "$cache_file"
  fi
  source "$cache_file"
  # zinit multisrc may skip trailing compdef inside the generated script
  compdef _procs procs
fi
