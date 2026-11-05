-- ~/.config/rex/plugins/copy_pwd.lua
-- Rex plugin to copy the working directory (pwd) of the active pane to the clipboard

local M = {}

local function show_toast(title, msg)
  local safe_msg = msg:gsub("\\", "\\\\"):gsub('"', '\\"')
  local safe_title = title:gsub("\\", "\\\\"):gsub('"', '\\"')
  rex.exec({
    "osascript", "-e",
    string.format('display notification "%s" with title "%s"', safe_msg, safe_title),
  })
end

local function get_block_pwd(block_id)
  -- 1. Check reported PWD (e.g. from OSC 7)
  local pwd_res = rex.block.call("com.superlogical.terminal", "pwd", { block_id = block_id })
  if pwd_res and pwd_res.pwd and pwd_res.pwd ~= "" then
    local path = pwd_res.pwd:gsub("^file://[^/]*", "")
    if path ~= "" then return path end
  end

  -- 2. Inspect active foreground or ancestor process cwd
  local proc_res = rex.block.call("com.superlogical.terminal", "process", { block_id = block_id })
  if proc_res then
    if proc_res.foreground and proc_res.foreground.cwd and proc_res.foreground.cwd ~= "" then
      return proc_res.foreground.cwd
    end
    if proc_res.ancestors then
      for _, a in ipairs(proc_res.ancestors) do
        if a.cwd and a.cwd ~= "" then
          return a.cwd
        end
      end
    end
    if proc_res.child and proc_res.child.cwd and proc_res.child.cwd ~= "" then
      return proc_res.child.cwd
    end
  end

  return nil
end

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "ctrl+h>shift+y"

  rex.action({
    name = "copy_pwd",
    title = "Copy Working Directory",
    description = "Copy the current pane working directory to the clipboard",
    category = "Workflows",
    keywords = "pwd directory path copy clipboard",
    run = function(ctx)
      local block_id = ctx.block_id
      if not block_id then
        error("No active pane found", 0)
      end

      local pwd = get_block_pwd(block_id)
      if not pwd or pwd == "" then
        error("Failed to determine working directory for pane", 0)
      end

      local r, exec_err = rex.exec({ "env", "LC_CTYPE=UTF-8", "pbcopy" }, { stdin = pwd })
      if exec_err or (r and not r.ok) then
        error("pbcopy failed: " .. (r and r.stderr or exec_err), 0)
      end

      show_toast("Rex", string.format("Copied '%s'", pwd))
    end,
  })

  if key and key ~= false then
    rex.bind(key, "copy_pwd")
  end
end

return M
