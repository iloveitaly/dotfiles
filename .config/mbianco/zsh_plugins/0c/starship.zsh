# make sure you execute this *after* asdf or other version managers are loaded
# starship is rust based; no need to cache shell completions

if (( $+commands[starship] )); then
  source <(starship completions zsh)
fi