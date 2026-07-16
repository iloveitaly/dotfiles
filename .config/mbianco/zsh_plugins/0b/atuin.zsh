# make sure you execute this *after* asdf or other version managers are loaded
# atuin is rust based; no need to cache shell completions

if (( $+commands[atuin] )); then
  # not possible to disable up-arrow via a config
  source <(atuin init zsh --disable-up-arrow)
  source <(atuin gen-completions --shell zsh)
fi