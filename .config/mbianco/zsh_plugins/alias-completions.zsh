# Functions/aliases don't inherit completions by default. Register their
# completers explicitly so a stale compinit cache cannot break registration.
# Sourced by the compinit pivot after zicompinit and before zicdreplay.

if (( $+commands[fd] )); then
  autoload -Uz _fd
  zicompdef _fd fd fdd fdu
fi

if (( $+commands[rg] )); then
  autoload -Uz _rg
  zicompdef _rg rg rgg rgu rgc
fi

if (( $+commands[dokku] )); then
  zicompdef dk=dokku
fi
