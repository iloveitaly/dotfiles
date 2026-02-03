# Only run in non-interactive, non-login shells.

# This file exists only because Cursor runs terminals in this limited mode,
# so we need a minimal early gate here.
if [[ -o interactive || -o login ]]; then
  return 0
fi

# shellcheck source=./.config/mbianco/agent-bootstrap
source "${HOME}/.config/mbianco/agent-bootstrap"

# If an agent is running the terminal, load agent config and exit early
if ai_is_agent_terminal; then
  ai_load_agent_configuration

  # simple prompt with pwd and $
  PS1='%~ $ '
  return 0
fi
