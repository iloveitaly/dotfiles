# NOTE if you have multiple uv versions installed, the completion used will be random

plugin_dir="${0:A:h}"

uv_cache_file="$plugin_dir/_uv"
uvx_cache_file="$plugin_dir/_uvx"

if (( $+commands[uv] )); then
  if [[ ! -f "$uv_cache_file" || ! $(/usr/bin/find "$uv_cache_file" -mtime -15 2>/dev/null) ]]; then
    uv generate-shell-completion zsh > "$uv_cache_file"
    uvx --generate-shell-completion zsh > "$uvx_cache_file"
    
  fi
  
  fpath+="$plugin_dir"
fi