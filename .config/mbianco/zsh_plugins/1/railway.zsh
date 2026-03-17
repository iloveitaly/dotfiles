if (( $+commands[railway] )); then
  # railway completion generation is so fast that we don't need to cache it on the filesystem
  source <(railway completion zsh)
fi