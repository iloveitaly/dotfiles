# gtime opencode completion > /dev/null
# 0.41user 0.05system 0:00.73elapsed 64%CPU (0avgtext+0avgdata 252080maxresident)k
# 0inputs+0outputs (64major+18732minor)pagefaults 0swaps

name="opencode"
plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_$name"

if (( $+commands[opencode] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    opencode completion > "$cache_file"
  fi

  fpath+=$plugin_dir
fi