# `atuin gen-completions --shell zsh`: 10 ms (2026-07-20); generate at startup.
# Load after fzf's key-bindings so Atuin owns Ctrl-R.

if (( $+commands[atuin] )); then
  # Atuin has no configuration option for disabling the up-arrow binding.
  source <(atuin init zsh --disable-up-arrow)
  source <(atuin gen-completions --shell zsh)
fi
