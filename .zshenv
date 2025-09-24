# Set AGENT_DEBUG=1 to enable debug mode

# this is loaded when `TERM=dumb` is set, which is the case in the cursor agent terminal (and any non-interactive terminal)
# however, it's also loaded when running `zsh` in tmux, so we need to be careful about what we put here.

# Return early if not running in a dumb terminal, this is what cursor specifies
if [[ "${TERM:-}" != "dumb" && -o interactive ]]; then
  [[ ${AGENT_DEBUG:-} -eq 1 ]] && echo "Interactive shell detected"
  return 0
fi

# Return early if not the first shell level
if (( ${SHLVL:-0} != 1 )); then
  [[ ${AGENT_DEBUG:-} -eq 1 ]] && echo "Not first shell level, returning"
  return 0
fi

if [[ -n "${CURSOR_AGENT:-}" || "${CLAUDECODE:-}" == "1" || "${GEMINI_CLI:-}" == "1" ]]; then
  # mise first, since it installs direnv
  source <(mise activate)
  source <(direnv hook zsh)
else
  echo -e "\033[33mNot in agent, and not interactive. We may be missing a new agent type?\033[0m"
fi
