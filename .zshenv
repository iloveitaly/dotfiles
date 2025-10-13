# Set AGENT_DEBUG=1 to enable debug mode

# this is loaded when `TERM=dumb` is set, which is the case in the cursor agent terminal (and any non-interactive terminal)
# however, it's also loaded when running `zsh` in tmux, so we need to be careful about what we put here.

# VS Code does not operate the same as Cursor: terminals are interactive, not dumb, and no ENV var is set to indicate
# it's being managed by an agent. We manually set a variable in our VCS config to indicate this.
if [[ "${TERM_PROGRAM:-}" == "vscode" && "${VSCODE_AGENT:-}" == "1" ]]; then
  # mise first, since it manages/install direnv
  source <(mise activate)
  source <(direnv hook zsh)
  # https://code.visualstudio.com/docs/terminal/shell-integration
  source "$(code --locate-shell-integration-path zsh)"
  return 0
fi

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
  # mise first, since it manages/install direnv
  source <(mise activate)
  source <(direnv hook zsh)
  source "$(code --locate-shell-integration-path zsh)"
else
  echo -e "\033[33mNot in agent, and not interactive. We may be missing a new agent type?\033[0m"
fi
