# make sure you execute this *after* asdf or other version managers are loaded
# just is rust, so we don't need to cache

if (( $+commands[just] )); then
  source <(just --completions zsh)
fi