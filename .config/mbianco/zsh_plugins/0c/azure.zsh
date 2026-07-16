# Azure CLI via argcomplete (mise install). bashcompinit runs in wait'0c'.
(( $+commands[az] )) || return

local register="${commands[az]:A:h}/register-python-argcomplete"
[[ -x $register ]] || return

# Defines `_python_argcomplete`. Under zinit multisrc, eval runs in a function so
# the script's trailing `compdef` is skipped (*func branch) — set _comps ourselves.
eval "$("$register" az)"
_comps[az]=_python_argcomplete
