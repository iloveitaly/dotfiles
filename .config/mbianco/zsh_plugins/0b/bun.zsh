# make sure you execute this *after* asdf or other version managers are loaded

# bun completions are strange: running `bun completions` installs ~/.bun/_bun and does not output the completion source code
# this is a hack until bun fixes their completion setup https://github.com/oven-sh/bun/issues/1272
# this will mutate your zshrc: https://github.com/oven-sh/bun/issues/10897

if (( ! $+commands[bun] )); then
  return
fi

# Match bun's global bin resolution:
# https://github.com/oven-sh/bun/blob/main/src/install/PackageManager/PackageManagerOptions.zig
local bun_bin_dir
if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
  bun_bin_dir="$XDG_CACHE_HOME/.bun/bin"
else
  bun_bin_dir="$HOME/.bun/bin"
fi

export PATH="$bun_bin_dir:$PATH"

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_bun"

if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
  bun completions $plugin_dir
fi

# rg completion script cannot be executed directly
fpath+=$plugin_dir
