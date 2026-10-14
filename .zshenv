# always executed in all shell types
# however, this is designed to only be executed in non-interactive, non-login shells

# exit early if we are in an interactive or login shell, zshrc will handle the rest
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
