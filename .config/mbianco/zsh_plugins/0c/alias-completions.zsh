# Functions/aliases don't inherit completions by default; map them to the
# underlying command's completer. Loaded from 0c/ (wait'0c'); zicdreplay
# runs after this directory is sourced.

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
