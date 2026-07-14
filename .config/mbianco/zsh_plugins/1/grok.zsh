# gtime grok completions zsh > /dev/null
# ~0.02s — fast enough that we don't cache on disk (same as railway).

# clap-style script (`#compdef` + trailing `compdef _grok grok`). Must be sourced
# when loaded in wait'1' (after zicompinit); fpath-only would miss registration.

if (( $+commands[grok] )); then
  source <(grok completions zsh)
fi
