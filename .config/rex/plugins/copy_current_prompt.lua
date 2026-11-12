-- ~/.config/rex/plugins/copy_current_prompt.lua
-- Rex plugin to copy the currently typed (unexecuted) shell command to macOS clipboard.
--
-- Approach:
-- Rex does not currently expose native semantic prompt/input zones (OSC 133) or
-- in-progress input line APIs to Lua. We parse the captured terminal content ('format'
-- with format = "text", trim = true). We find the newest prompt line (detecting Starship
-- '❯' / '❮' prompt symbols with optional module prefixes such as mise/direnv and trailing
-- NBSP \194\160 or whitespace), extract the in-progress command line, and include any
-- continuation lines (multi-line commands, zsh PS2 / Starship '∙').
--
-- Limitation:
-- In plain text capture (format = "text"), zsh-autosuggestions (grey ghost text) appear
-- as normal text in the terminal buffer and cannot be distinguished from typed text without
-- risking mangling arbitrary commands or relying on fragile VT/HTML color heuristics.
-- When an autosuggestion is actively displayed on the prompt line, it will be captured.

local M = {}

-- Lua patterns are byte-based: match each UTF-8 prompt symbol literally.
local function prompt_command(line)
  for _, symbol in ipairs({ "❯", "❮" }) do
    -- Case 1: symbol at start of line (standard Pure / simple Starship prompt)
    local rest = line:match("^%s*" .. symbol .. "(.*)$")
    if rest and (rest == "" or rest:match("^%s") or rest:sub(1, 2) == "\194\160") then
      if rest:sub(1, 2) == "\194\160" then rest = rest:sub(3) end
      return rest:match("^%s*(.-)%s*$")
    end

    -- Case 2: symbol preceded by prompt elements (e.g. mise, direnv, git branch)
    local prefix, after = line:match("^(.-)" .. symbol .. "(.*)$")
    if after and (after:sub(1, 2) == "\194\160" or after == "" or after:match("^%s")) then
      if after:sub(1, 2) == "\194\160" then after = after:sub(3) end
      return after:match("^%s*(.-)%s*$")
    end
  end
  return nil
end

local function clean_continuation_line(line)
  -- Starship continuation prompt: '∙' (BULLET OPERATOR, \226\136\153)
  for _, bullet in ipairs({ "∙", "\226\136\153" }) do
    local rest = line:match("^%s*" .. bullet .. "%s?(.*)$")
    if rest then return rest end
  end
  -- Standard zsh continuation prompts (e.g. '> ', 'dquote> ', 'for> ')
  local rest = line:match("^%s*[%a_]*>%s?(.*)$")
  if rest then return rest end
  -- Otherwise preserve indentation and trim trailing whitespace
  return (line:gsub("%s+$", ""))
end

local function get_current_prompt(content)
  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\r?\n") do
    lines[#lines + 1] = line
  end

  -- The newest prompt line in the captured content is the one currently being edited.
  local prompt_idx
  local prompt_text
  for i = #lines, 1, -1 do
    local cmd = prompt_command(lines[i])
    if cmd ~= nil then
      prompt_idx = i
      prompt_text = cmd
      break
    end
  end

  if not prompt_idx then
    error("No shell prompt found in this pane", 0)
  end

  local cmd_parts = { prompt_text }
  for i = prompt_idx + 1, #lines do
    local line = lines[i]
    if line:match("%S") then
      cmd_parts[#cmd_parts + 1] = clean_continuation_line(line)
    end
  end

  while #cmd_parts > 1 and cmd_parts[#cmd_parts]:match("^%s*$") do
    cmd_parts[#cmd_parts] = nil
  end

  local full_cmd = table.concat(cmd_parts, "\n")
  full_cmd = full_cmd:gsub("%s+$", "")

  if full_cmd == "" then
    error("Prompt line is empty", 0)
  end

  return full_cmd
end

local function show_toast(title, msg)
  local safe_msg = msg:gsub("\\", "\\\\"):gsub('"', '\\"')
  local safe_title = title:gsub("\\", "\\\\"):gsub('"', '\\"')
  rex.exec({
    "osascript", "-e",
    string.format('display notification "%s" with title "%s"', safe_msg, safe_title)
  })
end

function M.setup(opts)
  opts = opts or {}
  -- Keybinding: ctrl+h>p matches tmux prefix+p convention in ~/.tmux.conf
  local key = opts.key or "ctrl+h>p"

  rex.action({
    name = "copy_current_prompt",
    title = "Copy Current Prompt",
    category = "Workflows",
    description = "Copy the currently typed shell command to the macOS clipboard",
    run = function(ctx)
      if not ctx.block_id then error("No active pane found", 0) end
      local res, err = rex.block.call("com.superlogical.terminal", "format", {
        block_id = ctx.block_id,
        format = "text",
        trim = true,
      })
      if not res or not res.content then
        error(err or "Failed to read terminal content", 0)
      end

      local text_to_copy = get_current_prompt(res.content)
      local r, exec_err = rex.exec({ "env", "LC_CTYPE=UTF-8", "pbcopy" }, { stdin = text_to_copy })
      if exec_err or not r or not r.ok then
        error("pbcopy failed: " .. tostring(exec_err or (r and r.stderr) or "no result"), 0)
      end

      local preview = text_to_copy:match("^[^\n]*") or text_to_copy
      if #preview > 40 then
        preview = preview:sub(1, 37) .. "..."
      end
      show_toast("Rex", string.format("Copied prompt: '%s'", preview))
    end,
  })

  if key and key ~= false then
    rex.bind(key, "copy_current_prompt")
  end
end

return M
