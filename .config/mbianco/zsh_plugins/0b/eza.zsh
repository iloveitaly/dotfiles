# eza has no completion generator; upstream maintains completions/zsh/_eza.
# Note: This may conflict with a system-installed completion.
#
# fpath + #compdef cache — must load in 0b/ before the compinit pivot.

if (( $+commands[eza] )); then
  local plugin_dir="${0:A:h}"
  local cache_file="$plugin_dir/_eza"

  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    local temporary_file="$cache_file.$$.tmp"

    if curl -fsSL \
      "https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza" \
      -o "$temporary_file"; then
      mv -f "$temporary_file" "$cache_file"
    else
      command rm -f "$temporary_file"
    fi
  fi

  [[ -r "$cache_file" ]] && fpath+=$plugin_dir
fi
