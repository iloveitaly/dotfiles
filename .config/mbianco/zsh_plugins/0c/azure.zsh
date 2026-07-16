# gtime register-python-argcomplete az > /dev/null
# ~0.04–0.09s cold — cache (slower than find ~2ms)
#
# Azure CLI via argcomplete (mise install). bashcompinit runs in wait'0c'.
# Cache the script, then source it (post-compinit).

(( $+commands[az] )) || return

local register="${commands[az]:A:h}/register-python-argcomplete"
[[ -x $register ]] || return

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_az"

if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
  "$register" az >| "$cache_file"
fi

# Defines `_python_argcomplete`. Under zinit multisrc, source/eval runs in a
# function so the script's trailing `compdef` is skipped (*func branch) — set
# _comps ourselves.
source "$cache_file"
_comps[az]=_python_argcomplete
