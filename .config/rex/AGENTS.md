# Rex Multiplexer — Agent Guidelines & Conventions

## Shell Execution for Plugins and Blocks

Always execute subcommands and plugin processes using a **non-interactive login shell** (`zsh -l -c`) rather than raw `/bin/sh` or an interactive shell (`zsh -i`).

### Why: Fast Startup and Clean Environment
- **Performance:** A non-interactive login zsh (`zsh -l -c`) starts in **~10 ms**, compared to **~75–95 ms** for an interactive shell (`zsh -i`).
- **Short-circuiting:** In `~/.zshenv`, the shell checks `[[ -o login ]]` and exits early, avoiding the heavy startup overhead of `~/.zshrc` (which takes ~70+ ms loading completions and themes) and bypassing non-interactive agent-bootstrap hooks.
- **POSIX isolation:** Spawning via `/bin/sh` on macOS invokes legacy Apple Bash 3.2 in compatibility mode, which causes process monitors and the Rex process API to report `bash` instead of `zsh`.

### Idiomatic Block & Floating Layer Template

When defining floating layers or split panes with `com.superlogical.terminal.shell` in Rex Lua actions:

```lua
local layer, err = rex.session.new_layer{
  bounds = bounds,
  focus = true,
  layout = rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    options = {
      shell = "zsh",
      login = true,
      command = {
        "zsh", "-l", "-c",
        [[exec <command> "$@"]],
        "<process-name>", <args...>
      },
      theme = {
        background = bg_color, -- solid background for floating panes
      },
    },
  },
}
```

### PATH & Tool Resolution

The Rex server runs as a daemon under launchd with an allowlisted base system environment. To avoid managing manual PATH strings inside individual plugins:

1. **Non-interactive login execution:** Use `zsh -l -c` so standard login profile semantics apply.
2. **Server-level environment:** If tools (e.g. `mise`, Homebrew, `fzf`) are missing from the base daemon environment, pass them when starting the server:
   ```zsh
   rex server start --env PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:/opt/homebrew/bin:$PATH"
   ```
3. **Block-level prepend:** When a plugin must guarantee external tool discovery independent of the host server launch flags, specify `options.path_prepend` in the block layout.

### Floating Pane Styling
- Floating layers in Rex default to a transparent backdrop.
- Always configure `options.theme = { background = "<hex>" }` and pass explicit color flags to TUI tools (e.g. `fzf --color=bg:<hex>,bg+:<hex>,gutter:<hex>`) to prevent transparency and visual bleed-through from underlying panes.

### Validation
Always validate Rex configuration before and after making changes:
```zsh
rex config check
rex config reload
```
