# gtime ngrok completion zsh > /dev/null
# 0.01user 0.02system 0:00.08elapsed 46%CPU (0avgtext+0avgdata 29088maxresident)k
# 0inputs+0outputs (922major+1973minor)pagefaults 0swaps


plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_ngrok"

if (( $+commands[ngrok] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    ngrok completion zsh > "$cache_file"
  fi

  source "$cache_file"
fi