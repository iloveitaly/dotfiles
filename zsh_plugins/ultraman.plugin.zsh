# make sure you execute this *after* asdf/mise are loaded
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/swiftpm

plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_ultraman"

if (( $+commands[ultraman] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    ultraman completion zsh > "$cache_file"
  fi

  # ultraman completion script cannot be executed directly, path to completion directory must be specified
  fpath+=$plugin_dir
fi