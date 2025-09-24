# this is loaded when `TERM=dumb` is set, which is the case in the cursor agent terminal (and any non-interactive terminal)
# however, it's also loaded when running `zsh` in tmux, so we need to be careful about what we put here.

# Return early if not the first shell level
if (( ${SHLVL:-0} != 1 )); then
  echo "Not first shell level, returning"
  return 0
fi

# Return early if not running in a dumb terminal, this is what cursor specifies
if [[ "${TERM:-}" != "dumb" && -o interactive ]]; then
  echo "Interactive shell detected"
  return 0
fi

# TODO is this any better than the above? It seems like the interactive option is king
# is_interactive() {
#   [ -t 0 ] && [ -t 1 ] && [ -t 2 ] && [ "$TERM" != "dumb" ]; 
# }
# if is_interactive; then
#   echo "Interactive shell detected"
# else
#   echo "Non-interactive shell detected"
# fi

if [[ -n "${CURSOR_AGENT:-}" || "${CLAUDECODE:-}" == "1" || "${GEMINI_CLI:-}" == "1" ]]; then
  # mise first, since it installs direnv
  source <(mise activate)
  source <(direnv hook zsh)
fi