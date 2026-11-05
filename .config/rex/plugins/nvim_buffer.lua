-- ~/.config/rex/plugins/nvim_buffer.lua
-- Rex plugin to open the current terminal buffer in Neovim in a popup
-- Reference: https://gist.github.com/catsby/0fd3d65ae905ee645a5e7de89b17b5df

local M = {}

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "ctrl+h>v"
  local bounds = opts.bounds or { 0.05, 0.05, 0.9, 0.9 }
  local bg_color = opts.bg_color or "#282c34"
  local home = os.getenv("HOME") or ""
  local path_prepend = opts.path_prepend or {
    home .. "/.local/share/mise/shims",
    home .. "/.local/bin",
    "/opt/homebrew/bin",
  }
  local unwrap_flag = opts.unwrap and "--unwrap" or ""

  rex.action({
    name = "open_buffer_in_nvim",
    title = "Open Buffer in Neovim Popup",
    description = "Open the current terminal pane's scrollback buffer in Neovim in a popup layer",
    category = "Workflows",
    keywords = "nvim neovim buffer scrollback popup editor",
    run = function(ctx)
      if not ctx.block_id then
        error("open_buffer_in_nvim: no active pane", 0)
      end
      if not ctx.session_id then
        error("open_buffer_in_nvim: no active session", 0)
      end

      local vim_cmds = table.concat({
        "set clipboard=unnamedplus",
        "setlocal buftype=nofile bufhidden=wipe nomodifiable readonly signcolumn=no nonumber norelativenumber",
        "nnoremap <silent><buffer> q <Cmd>qa!<CR>",
        "vnoremap <silent><buffer> <CR> y",
        "execute 'normal! Gzb'",
        "autocmd TextYankPost <buffer> call timer_start(0, {-> execute('qa!')})",
      }, " | ")

      local shell_script = string.format(
        [=[
tmp=$(mktemp -t rex-buffer.XXXXXX) || exit 1
trap 'rm -f "$tmp"' EXIT INT TERM
rex capture -s "$1" -b "$2" --trim %s > "$tmp" || exit 1
nvim -n -i NONE -c "%s" "$tmp"
rex focus -s "$1" -b "$2" >/dev/null 2>&1
]=],
        unwrap_flag,
        vim_cmds
      )

      local layer, err = rex.session.new_layer({
        bounds = bounds,
        focus = true,
        layout = rex.layout.block({
          flavor = "com.superlogical.terminal.shell",
          options = {
            shell = "zsh",
            login = true,
            path_prepend = path_prepend,
            theme = {
              background = bg_color,
            },
            command = {
              "zsh",
              "-l",
              "-c",
              shell_script,
              "rex-buffer-nvim",
              ctx.session_id,
              ctx.block_id,
            },
          },
        }),
      })

      if not layer then
        error("open_buffer_in_nvim: failed to create floating layer: " .. tostring(err), 0)
      end

      return layer
    end,
  })

  if key and key ~= false then
    rex.bind(key, "open_buffer_in_nvim")
  end
end

return M
