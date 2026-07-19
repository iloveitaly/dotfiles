# gtime codex completion zsh > /dev/null: ~0.04s — cache the generated script.
# Loaded post-compinit; `compdef` is explicit because zinit multisrc can skip
# the generated script's trailing registration.

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_codex"

if (( $+commands[codex] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    codex completion zsh >| "$cache_file"
  fi

  source "$cache_file"
  compdef _codex codex
fi
