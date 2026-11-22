#!/bin/zsh

# If executed by root (e.g. hyper-focus daemon), re-run as mike
if [[ $(id -u) -eq 0 ]]; then
  exec su - mike -c "$0"
fi

export USER=mike
export HOME=/Users/$USER
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

if (( $+commands[mise] )); then
  eval "$(mise activate zsh --shims 2>/dev/null)"
fi

cd "$HOME" || exit 1

PROMPT="what day is it?"

# OpenAI Codex (rolling 5hr usage window)
if (( $+commands[codex] )); then
  codex exec --ephemeral --skip-git-repo-check "$PROMPT" </dev/null || true
fi

# # Claude Code (rolling 5hr usage window)
# if (( $+commands[claude] )); then
#   claude -p --no-session-persistence "$PROMPT" </dev/null || true
# fi

# agy is skipped: no ephemeral / no-session-persistence mode
