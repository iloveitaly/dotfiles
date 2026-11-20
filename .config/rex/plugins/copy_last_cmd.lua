-- ~/.config/rex/plugins/copy_last_cmd.lua
-- Rex plugin to copy the last input command + output to clipboard

local M = {}

-- Lua patterns are byte-based: match each UTF-8 prompt symbol literally.
-- Starship prints direnv, mise, python, and no-venv on the same line, before
-- the symbol. The character module ends with a non-breaking space (U+00A0),
-- which distinguishes the prompt from a ❯ that appears in command output.
local function prompt_command(line)
  for _, symbol in ipairs({ "❯", "❮" }) do
    local rest = line:match("^%s*" .. symbol .. "(.*)$")
    if rest and (rest == "" or rest:match("^%s") or rest:sub(1, 2) == "\194\160") then
      if rest:sub(1, 2) == "\194\160" then rest = rest:sub(3) end
      return rest:match("^%s*(.-)%s*$"), symbol
    end

    local _, after = line:match("^(.-)" .. symbol .. "(\194\160.*)$")
    if after then
      return after:sub(3):match("^%s*(.-)%s*$"), symbol
    end
  end
end

local function show_toast(title, msg)
  local safe_msg = msg:gsub("\\", "\\\\"):gsub('"', '\\"')
  local safe_title = title:gsub("\\", "\\\\"):gsub('"', '\\"')
  rex.exec({
    "osascript", "-e",
    string.format('display notification "%s" with title "%s"', safe_msg, safe_title)
  })
end

local function join_lines(lines)
  local n = #lines
  if n <= 500 then
    return table.concat(lines, "\n")
  end
  -- gopher-lua's table.concat pushes every element onto the registry stack and overflows
  -- around ~16k-20k items, so join in bounded chunks.
  local chunks = {}
  for s = 1, n, 500 do
    local e = math.min(s + 499, n)
    local chunk = {}
    for j = s, e do
      chunk[#chunk + 1] = lines[j]
    end
    chunks[#chunks + 1] = table.concat(chunk, "\n")
  end
  return join_lines(chunks)
end

local function get_last_cmd_and_output(content)
  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\r?\n") do
    lines[#lines + 1] = line
  end

  -- The newest prompt is still being edited. Walk completed commands backwards,
  -- keeping each command's output bounded by its immediate successor prompt.
  local next_prompt
  local cmd_idx, cmd_text, cmd_symbol, last_output_line
  for i = #lines, 1, -1 do
    local command, symbol = prompt_command(lines[i])
    if command ~= nil then
      if next_prompt and command ~= "" then
        cmd_idx, cmd_text, cmd_symbol = i, command, symbol
        -- This Starship configuration has a status line before each prompt.
        last_output_line = next_prompt - 2
        break
      end
      next_prompt = i
    end
  end

  if not cmd_idx then
    error("No previous non-empty command found in this pane", 0)
  end

  local first_output_line = cmd_idx + 1
  while last_output_line >= first_output_line and lines[last_output_line]:match("^%s*$") do
    last_output_line = last_output_line - 1
  end

  local result_lines = { cmd_symbol .. " " .. cmd_text }
  for i = first_output_line, last_output_line do
    result_lines[#result_lines + 1] = lines[i]
  end

  return join_lines(result_lines), cmd_text, #result_lines
end

function M.setup()
  rex.action({
    name = "copy_last_cmd_and_output",
    title = "Copy Last Command and Output",
    category = "Workflows",
    run = function(ctx)
      if not ctx.block_id then error("No active pane found", 0) end
      local res, err = rex.block.call("com.superlogical.terminal", "format", { block_id = ctx.block_id, format = "text", trim = true })
      if not res or not res.content then
        error(err or "Failed to read terminal content", 0)
      end

      local text_to_copy, cmd_name, line_count = get_last_cmd_and_output(res.content)
      local r, exec_err = rex.exec({ "env", "LC_CTYPE=UTF-8", "pbcopy" }, { stdin = text_to_copy })
      if exec_err or not r or not r.ok then
        error("pbcopy failed: " .. tostring(exec_err or (r and r.stderr) or "no result"), 0)
      end

      -- Display toast notification
      local preview = cmd_name
      if #preview > 40 then
        preview = preview:sub(1, 37) .. "..."
      end
      show_toast("Rex", string.format("Copied '%s' (%d lines)", preview, line_count))
    end,
  })

  rex.bind("ctrl+h>y", "copy_last_cmd_and_output")
end

return M
