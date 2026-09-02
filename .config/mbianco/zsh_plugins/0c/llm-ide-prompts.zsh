# gtime llm-ide-rules --show-completion > /dev/null
# ~0.3s (Python/Typer) — cache (slower than find ~2ms)
#
# Post-compinit: source the cached script so registration runs (fpath-only
# would miss the current session after zicompinit).

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_llm-ide-rules"

if (( $+commands[llm-ide-rules] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    llm-ide-rules --show-completion >| "$cache_file"
  fi
  source "$cache_file"
  # zinit multisrc may skip trailing compdef inside the generated script
  compdef _llm_ide_rules_completion llm-ide-rules
fi
