#!/bin/zsh

# If executed by root (e.g. hyper-focus daemon), re-run as mike
if [[ $(id -u) -eq 0 ]]; then
  exec su - mike -c "$0"
fi

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# Start 5hr session timer for AI tools
codex exec "what day is it?" </dev/null
claude -p "what day is it?" </dev/null
agy -p "what day is it?" </dev/null
