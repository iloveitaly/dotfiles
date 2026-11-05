# Rex: Agent Guidelines & Conventions

Rex is the Superlogical terminal multiplexer. This directory holds its Lua config: `init.lua` auto-loads every module in `plugins/`.

## Repository Layout & Deployment

- `init.lua` puts `plugins/` on `package.path` and calls `require(<name>).setup()` for every entry in `plugins/` (either `<name>.lua` or `<name>/init.lua`).
- `~/.config/rex` is a **real directory, not a symlink** to `~/dotfiles/.config/rex`. After editing a file in dotfiles, copy it to `~/.config/rex/` before reloading, or Rex keeps running the old version.
- `plugins/rex-extrakto/` is its own Git repository and exists only in `~/.config/rex/plugins/`, not in dotfiles.

## Writing a Plugin

Each plugin returns a module with `setup(opts)` that defines one named action and binds a key to it:

```lua
local M = {}

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "ctrl+h>x"

  rex.action({
    name = "my_action",          -- lowercase, digits, underscores; no dots
    title = "My Action",         -- shown in the command palette
    category = "Workflows",
    run = function(ctx)
      if not ctx.block_id then error("my_action: no active pane", 0) end
      -- ...
    end,
  })

  if key then rex.bind(key, "my_action") end
end

return M
```

- **Prefix:** Personal bindings live under the `ctrl+h>` sequence, matching the tmux prefix in `~/.tmux.conf`. Run `rex keymap` to see which keys are taken.
- **Uppercase keys:** Write `ctrl+h>shift+y`, not `ctrl+h>Y`. Rex normalizes `Y` to `y`, which silently collides with the lowercase binding.
- **Errors:** `rex.session.*` and `rex.block.call` return `nil, err` on failure instead of raising. Check the result and call `error(msg, 0)` so the message reaches the user.
- **Notifications:** Rex has no native toast API. Use `osascript -e 'display notification ...'` via `rex.exec` (see `copy_last_cmd.lua`).
- **Clipboard:** `rex.exec({ "env", "LC_CTYPE=UTF-8", "pbcopy" }, { stdin = text })`. The `LC_CTYPE` keeps non-ASCII text intact under the daemon's environment.

## Shell Execution for Blocks & Layers

Run subcommands and floating-pane programs with a **non-interactive login zsh** (`zsh -l -c`), never `/bin/sh` or `zsh -i`.

- **Speed:** `zsh -l -c` starts in about 10 ms; `zsh -i` takes 75–95 ms because it loads `~/.zshrc` (completions, prompt, plugins).
- **Correct environment:** `~/.zshenv` returns early only for interactive shells. Non-interactive shells continue on to source `~/.config/mbianco/path` and activate `mise` shims.
- **Process identity:** `/bin/sh` on macOS is Bash 3.2, so Rex's process API and activity sidebar report `bash` instead of the real program.

### Floating Layer Template

```lua
local layer, err = rex.session.new_layer({
  bounds = { 0.05, 0.05, 0.9, 0.9 },   -- x, y, w, h as fractions of the window
  focus = true,
  layout = rex.layout.block({
    flavor = "com.superlogical.terminal.shell",
    options = {
      shell = "zsh",
      login = true,
      theme = { background = "#282c34" },
      command = {
        "zsh", "-l", "-c",
        [[<command> "$1" "$2"; rex focus -s "$1" -b "$2" >/dev/null 2>&1]],
        "<process-name>",               -- becomes $0
        ctx.session_id, ctx.block_id,   -- become $1, $2
      },
    },
  }),
})
if not layer then error("my_action: " .. tostring(err), 0) end
```

- **Pass values as positional arguments** (`$1`, `$2`, …), not by splicing them into the script string. That avoids quoting bugs with paths and IDs.
- **Return focus:** Closing a layer doesn't refocus the originating pane. End the script with `rex focus -s "$1" -b "$2"` (session and block IDs passed in).
- **Clean up temp files** with `trap 'rm -f "$tmp"' EXIT INT TERM`.

### PATH & Tool Resolution

Because blocks run through `zsh -l -c`, the full user `PATH` (Homebrew, `~/.local/bin`, `mise` shims for `fzf`, `nvim`, etc.) resolves automatically.

- Do not hardcode, prepend, or pass custom `PATH` strings inside plugins.
- Do not set `options.path_prepend` in block layouts.
- `rex server start` does not need `--env PATH=...` overrides.

To check that a tool resolves the way Rex will see it:

```zsh
env -i HOME="$HOME" USER="$USER" TERM=xterm-256color zsh -l -c 'which fzf mise nvim'
```

### Floating Pane Styling

Floating layers have a transparent backdrop by default. Always set `options.theme = { background = "<hex>" }`, and give TUI tools matching colors (e.g. `fzf --color=bg:<hex>,bg+:<hex>,gutter:<hex>`) so the pane underneath doesn't show through.

## Reading Terminal Content

- **Large scrollback:** In a shell script inside the layer, prefer `rex capture -s "$1" -b "$2" --trim > "$tmp"`. Calling `rex.block.call(terminal, "format", ...)` from Lua fails with `too_large` once output passes about 960 KiB unless you page it with `max_bytes` and `blob_read`.
- **Small reads in Lua** (last command, title) are fine with `rex.block.call("com.superlogical.terminal", "format", { format = "text", trim = true })`.
- **Formats:** `text` is plain, `html` keeps styling and `<a href>` links, and `vt` keeps raw escape sequences (including OSC 8 hyperlinks).
- **Alternate screen:** Full-screen programs (nvim, Claude Code, lazygit) have no scrollback, so capture returns only the visible screen.
- **Working directory:** `pwd` is empty unless the shell emits OSC 7. Fall back to `process` → `foreground.cwd` (see `copy_pwd.lua`).

## Finding API Details

- **Superlogical MCP** (`search_docs`, `read_doc`, `search_feedback`, `search_changelog`): docs and community threads. Check feedback before building a workaround; someone may have already posted one.
- `rex api describe <method> --json`: exact arguments for a server method such as `session.new_layer`.
- `rex block types --json`: terminal block methods and the full `options_schema` for `com.superlogical.terminal.shell`.
- Docs also accept `.md` URLs, e.g. `curl -s https://www.superlogical.com/rex/docs/reference/lua.md`.

## Validation

After every change:

```zsh
cp ~/dotfiles/.config/rex/<file> ~/.config/rex/<file>   # sync first
rex config check                                       # parse errors, binding count
rex config reload                                      # apply
rex keymap                                             # confirm the binding and its source line
```

Try an action against a specific pane without pressing keys:

```zsh
rex do -s <session> -b <block> <action_name>
rex do -s <session> -b <block> -e 'return rex.block.call("com.superlogical.terminal", "pwd", {})' --json
```

Find session and block IDs with `rex ls --json` and `rex block ls -s <session> --json`.
