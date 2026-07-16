# Native zsh completion for dokku (including plugin goals: redis, postgres, …).
#
# Same source of truth as the official bash completer:
#   https://github.com/dokku/dokku/blob/master/contrib/bash-completion
#   dokku --quiet help --all | awk '/^    /{ print $1 }'
#
# Goals are dynamic (core + plugins): postgres:create, redis:info, etc.
#
# Requires a working dokku client context (DOKKU_HOST or a git remote named
# dokku). Without that, help prints an error and we refuse to cache it —
# otherwise you get junk matches like "i.e." from the setup hint.
#
# Cache: ${XDG_CACHE_HOME:-$HOME/.cache}/dokku/completion
# Force refresh: rm that file
#
# Slot: 0c/ (post-compinit).

(( $+commands[dokku] || $+aliases[dokku] )) || return

typeset -g _DOKKU_COMPLETION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dokku/completion"

# Dokku goals look like `apps:create` or bare `version` — never `i.e.`
_dokku_goal_pattern='^[a-z][a-z0-9_-]*(:[a-z0-9_-]+)*$'

_dokku_refresh_completion_cache() {
  mkdir -p "${_DOKKU_COMPLETION_CACHE:h}"

  local out tmp
  tmp="${_DOKKU_COMPLETION_CACHE}.tmp.$$"

  # Capture stdout only; non-zero or empty → fail without clobbering a good cache.
  if ! out=$(dokku --quiet help --all 2>/dev/null); then
    return 1
  fi

  # Remote client emits this when no host/app context is configured.
  if [[ -z $out || $out == *DOKKU_HOST* || $out == *'git remote add dokku'* ]]; then
    return 1
  fi

  print -r -- "$out" \
    | awk '/^    /{ print $1 }' \
    | awk -v p="$_dokku_goal_pattern" '$0 ~ p' \
    | sort -u >| "$tmp"

  if [[ ! -s $tmp ]]; then
    rm -f "$tmp"
    return 1
  fi

  mv -f "$tmp" "$_DOKKU_COMPLETION_CACHE"
}

_dokku_load_goals() {
  local -a raw
  # reply is used by caller via nameref-style: we set global _dokku_goals
  _dokku_goals=()
  [[ -s $_DOKKU_COMPLETION_CACHE ]] || return 1
  raw=(${(f)"$(<$_DOKKU_COMPLETION_CACHE)"})
  # Drop any junk left over from older cache generations (e.g. i.e.)
  _dokku_goals=(${(M)raw:#(#i)[a-z][a-z0-9_-]#(:[a-z0-9_-]#)#})
  (( $#_dokku_goals ))
}

_dokku() {
  local expl
  local -a _dokku_goals

  if [[ ! -s $_DOKKU_COMPLETION_CACHE || ! $(/usr/bin/find "$_DOKKU_COMPLETION_CACHE" -mtime -7 2>/dev/null) ]]; then
    _dokku_refresh_completion_cache
  fi

  if ! _dokku_load_goals; then
    # Bad/empty cache (e.g. previous "i.e." pollution): wipe and retry once.
    rm -f "$_DOKKU_COMPLETION_CACHE"
    _dokku_refresh_completion_cache || return 1
    _dokku_load_goals || return 1
  fi

  # compadd, not _describe: goals contain colons (apps:create).
  _wanted commands expl 'dokku command' compadd -a _dokku_goals
}

compdef _dokku dokku
_comps[dokku]=_dokku
