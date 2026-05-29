if (( $+commands[az] )); then
  autoload -U +X bashcompinit && bashcompinit
  source $(brew --prefix)/etc/bash_completion.d/az
fi
