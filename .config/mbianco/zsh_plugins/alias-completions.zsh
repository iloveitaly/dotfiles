# Functions/aliases don't inherit completions by default; map them to the
# underlying command's completer. Sourced by the compinit pivot after
# zicompinit and before zicdreplay, so the copies see $_comps.

if (( $+commands[fd] )); then
  zicompdef fdd=fd
  zicompdef fdu=fd
fi

if (( $+commands[rg] )); then
  zicompdef rgg=rg
  zicompdef rgu=rg
  zicompdef rgc=rg
fi

if (( $+commands[dokku] )); then
  zicompdef dk=dokku
fi
