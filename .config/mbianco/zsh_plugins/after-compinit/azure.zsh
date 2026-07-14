if (( ! $+commands[az] )); then
  return
fi

# Argcomplete-based completions bundled with the mise azure-cli install.
# Prefer the real binary directory (symlink-resolved); mise shims resolve to
# the mise binary itself, so fall back to `mise which` in that case.
local az_bin="${commands[az]:A}"
local register="${az_bin:h}/register-python-argcomplete"
if [[ ! -x "$register" ]] && (( $+commands[mise] )); then
  az_bin="$(mise which az 2>/dev/null)" || return
  register="${az_bin:A:h}/register-python-argcomplete"
fi
[[ -x "$register" ]] || return

autoload -Uz bashcompinit is-at-least
bashcompinit

# Eval defines `_python_argcomplete` (and friends). The generated script also
# tries to `compdef _python_argcomplete az`, but that is unreliable here:
# 1. This file is loaded via zinit `multisrc` on fzf-tab (wait'0b').
# 2. While multisrc runs, zinit stubs `compdef` into a replay queue.
# 3. `zicdreplay` already ran in the npm-completion `atinit` *before* this file.
# So queued `compdef` calls are never applied. Register directly instead.
eval "$("$register" az)"

typeset -g -A _comps
_comps[az]=_python_argcomplete
