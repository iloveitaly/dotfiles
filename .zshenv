# - Always executed in all shell types
# - Initialize agent command environments here or any configuration you always want to load

# interactive shells use .zshrc too, so short-circuit early
if [[ -o interactive ]]; then
  return 0
fi

# from here on out, we're in a non-interactive shell

# load common utilities for checking if we're in an agent terminal
# shellcheck source=./.config/mbianco/agent-bootstrap
source "${HOME}/.config/mbianco/agent-bootstrap"

# even in a non-agent and non-interactive shell (like a rex popup), we want to load the path
# shellcheck source=./.path
source "${HOME}/.config/mbianco/path"

# If an agent is running the terminal, load agent config and exit early
if ai_is_agent_terminal; then
  ai_load_agent_configuration

  # simple prompt with pwd and $
  PS1='%~ $ '
  return 0
fi

# In this case, we know we're not in an agent terminal, and we probably at least need access to mise shims
eval "$(mise activate zsh --shims)"
