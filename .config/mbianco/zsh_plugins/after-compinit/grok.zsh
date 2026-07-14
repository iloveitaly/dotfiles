# gtime grok completions zsh > /dev/null
# ~0.02s — fast enough that we don't cache on disk (same as railway).
#
# clap-style script (`#compdef` + trailing `compdef _grok grok`).
# Loaded from after-compinit (wait'0c'); zicdreplay runs after this dir is sourced.

if (( $+commands[grok] )); then
  source <(grok completions zsh)
fi
