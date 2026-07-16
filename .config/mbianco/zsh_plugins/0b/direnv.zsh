# make sure you execute this *after* asdf or other version managers are loaded
# direnv is go, really fast, no need to cache

if (( $+commands[direnv] )); then
  source <(direnv hook zsh)
  
  # if you open up a new shell in a directory with direnv, it won't be executed until you
  # execute a command. This executes any .envrc file immediately.
  _direnv_hook
fi