# source/eval style — load in 0c/ so registration runs after zicompinit
# (wait'0c' zicdreplay applies any stubbed compdef).

if (( $+commands[gitleaks] )); then
  eval "$(gitleaks completion zsh)"
fi
