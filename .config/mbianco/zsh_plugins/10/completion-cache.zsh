# Rebuild daily in the background. Existing shells keep their completions.
(
  emulate zsh
  cache_file=${ZINIT[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}

  if [[ -f "$cache_file" && -n $(/usr/bin/find "$cache_file" -mtime -1 -print) ]]; then
    exit 0
  fi

  temp_dir=$(mktemp -d "${cache_file}.refresh.XXXXXX") || exit 1
  trap 'rm -rf -- "$temp_dir"' EXIT

  # Clear inherited registrations so removed completions disappear too.
  unset _comps _services _patcomps _postpatcomps _compautos _lastcomp _comp_secure
  autoload -Uz compinit

  # Audit permissions without prompting; publish only a successful rebuild.
  if compinit -i -d "$temp_dir/dump" && [[ -s "$temp_dir/dump" ]]; then
    mv -f -- "$temp_dir/dump" "$cache_file"
  fi
) </dev/null &!
