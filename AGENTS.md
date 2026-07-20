# Creating a zsh completion plugin

Add one `.zsh` file per CLI under the appropriate load directory.

- Use `0b/` only when the generated completion must be discovered by `compinit` through `fpath` (for example, a script with `#compdef` that cannot be sourced directly).
- Use `0c/` when the script can be sourced or evaluated after `compinit`. Most generated completion plugins belong here. Explicitly call `compdef _<command> <command>` after sourcing: zinit multisrc can skip a generator's trailing registration.
- Guard every plugin with `if (( $+commands[<command>] )); then ... fi` so a missing CLI never slows shell startup or emits errors.

Before deciding whether to cache, benchmark the real generator:

```zsh
gtime <command> completion zsh > /dev/null
```

Only generate at shell startup when it is faster than 10 ms. Otherwise cache the generated output beside the plugin as `_<command>` and refresh it periodically (15 days is the local convention):

```zsh
plugin_dir="${0:A:h}"
cache_file="$plugin_dir/_<command>"

if (( $+commands[<command>] )); then
  if [[ ! -f "$cache_file" || ! $(/usr/bin/find "$cache_file" -mtime -15 2>/dev/null) ]]; then
    <command> completion zsh >| "$cache_file"
  fi
  source "$cache_file"
  compdef _<command> <command>
fi
```

Record the benchmark result in a short comment above the implementation. Do not add the generated `_<command>` cache file to Git.

Validate both the wrapper and generated completion:

```zsh
zsh -n .config/mbianco/zsh_plugins/0c/<command>.zsh
<command> completion zsh > /private/tmp/<command>-completion
zsh -n /private/tmp/<command>-completion
zsh -fc 'autoload -Uz compinit; compinit -D; source /private/tmp/<command>-completion; [[ ${_comps[<command>]} == _<command> ]]'
```

Inspect `git status --short` before finishing, because this repository may already contain unrelated user changes.
