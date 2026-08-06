# gtime uv generate-shell-completion zsh > /dev/null
# ~0.02s — cache the generated script (large: ~553KB for uv).
# Clap scripts self-register via trailing `compdef` on source; zicdreplay
# (local-0c) applies the stubbed call after this dir is loaded.

plugin_dir="${0:A:h}"
uv_cache_file="$plugin_dir/_uv"
uvx_cache_file="$plugin_dir/_uvx"

if (( $+commands[uv] )); then
  if [[ ! -f "$uv_cache_file" || ! $(/usr/bin/find "$uv_cache_file" -mtime -15 2>/dev/null) ]]; then
    uv generate-shell-completion zsh >| "$uv_cache_file"
    uvx --generate-shell-completion zsh >| "$uvx_cache_file"
  fi

  source "$uv_cache_file"
  source "$uvx_cache_file"
fi
