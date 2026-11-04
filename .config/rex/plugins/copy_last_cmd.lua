-- ~/.config/rex/plugins/copy_last_cmd.lua
-- Rex plugin to copy the last input command + output to clipboard

local M = {}

local function is_prompt_line(line)
  if not line then return false end
  -- Match prompt character ❯ (or vi-mode ❮) followed by non-breaking space (UTF-8 \194\160)
  -- Or match prompt symbol at the beginning of the line
  return line:find("[❯❮]\194\160") ~= nil
    or line:match("^%s*[❯❮]%s") ~= nil
    or line:find("❯") ~= nil
end

local function show_toast(title, msg)
  local safe_msg = msg:gsub("\\", "\\\\"):gsub('"', '\\"')
  local safe_title = title:gsub("\\", "\\\\"):gsub('"', '\\"')
  rex.exec({
    "osascript", "-e",
    string.format('display notification "%s" with title "%s"', safe_msg, safe_title)
  })
end

local function get_last_cmd_and_output(content)
  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\r?\n") do
    lines[#lines + 1] = line
  end

  local prompts = {}
  for i = #lines, 1, -1 do
    if is_prompt_line(lines[i]) then
      prompts[#prompts + 1] = i
      if #prompts == 2 then break end
    end
  end

  if #prompts < 2 then
    error("No previous command found in this pane", 0)
  end

  local cmd_idx = prompts[2]
  -- Strip leading prompt characters and non-breaking spaces
  local cmd_text = lines[cmd_idx]:gsub(".*[❯❮]\194\160%s*", ""):gsub("^%s*[❯❮]%s*", "")
  local first_output_line = cmd_idx + 1

  -- Output ends before current prompt (skipping Starship status line at prompts[1] - 1)
  local last_output_line = prompts[1] - 2

  -- Trim trailing empty or whitespace-only lines
  while last_output_line >= first_output_line and lines[last_output_line]:match("^%s*$") do
    last_output_line = last_output_line - 1
  end

  local result_lines = { cmd_text }
  if last_output_line >= first_output_line then
    for i = first_output_line, last_output_line do
      result_lines[#result_lines + 1] = lines[i]
    end
  end

  return table.concat(result_lines, "\n"), cmd_text, #result_lines
end

function M.setup()
  rex.action({
    name = "copy_last_cmd_and_output",
    title = "Copy Last Command and Output",
    category = "Workflows",
    run = function(ctx)
      -- Call the fully-qualified block method: com.superlogical.terminal
      local res, err = rex.block.call("com.superlogical.terminal", "format", { format = "text", trim = true })
      if not res or not res.content then
        error(err or "Failed to read terminal content", 0)
      end

      local text_to_copy, cmd_name, line_count = get_last_cmd_and_output(res.content)
      local r, exec_err = rex.exec({ "env", "LC_CTYPE=UTF-8", "pbcopy" }, { stdin = text_to_copy })
      if exec_err or (r and not r.ok) then
        error("pbcopy failed: " .. (r and r.stderr or exec_err), 0)
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
