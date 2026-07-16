# make sure you execute this *after* asdf or other version managers are loaded

# the default docker completion is not as advanced as this one, you'll want to remove it:
#   rm $(brew --prefix)/share/zsh/site-functions/_docker
# https://github.com/docker/compose/issues/8550

if (( $+commands[docker] )); then
  eval "$(docker completion zsh)"
fi