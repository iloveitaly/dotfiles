# D venv ❯ gtime llm-ide-rules --show-completion > /dev/null
# 0.56user 0.29system 0:00.87elapsed 98%CPU (0avgtext+0avgdata 64096maxresident)k
# 0inputs+0outputs (2major+8793minor)pagefaults 0swaps

name="llm-ide-prompts"
plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_$name"

if (( $+commands[$name] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    opencode completion > "$cache_file"
  fi

  fpath+=$plugin_dir
fi