-- ~/.config/rex/plugins/tab_switcher.lua
-- Rex plugin: floating fzf tab switcher showing:
--   session name - tab title - pwd - running application name
--
-- Community patterns & Discord feedback referenced:
-- - Floating layer + fzf + terminal CWD matching:
--     pperanich/dotfiles (rex-project-picker):
--     https://github.com/pperanich/dotfiles/tree/29ea77f4292ea8f0bb58b5a23bddeaefa4803536/pkgs/rex-project-picker
--     https://github.com/pperanich/dotfiles/blob/29ea77f4292ea8f0bb58b5a23bddeaefa4803536/home/.config/rex/init.lua
-- - Session/activity switcher workflow:
--     rtuszik/sex: https://github.com/rtuszik/sex
-- - Why fzf in a floating layer is used (no native Lua custom-picker API yet):
--     https://discord.com/channels/1546797889009881158/1568223068495810560
--     https://discord.com/channels/1546797889009881158/1567164283736031253
-- - Switching Rex.app via session.select (rex focus only moves server state;
--   requires Remote Control enabled in Rex Settings -> Server -> Rex Server):
--     phinze/rig: https://github.com/phinze/rig
--     https://discord.com/channels/1546797889009881158/1562120012179841065
--     tale/dotfiles: https://github.com/tale/dotfiles/blob/6d19a1464ba56eef2922e2a09b7798f6bcc25a25/modules/rex/init.lua#L23
--     https://discord.com/channels/1546797889009881158/1564508870465036289
--     https://discord.com/channels/1546797889009881158/1559289044439932949

local M = {}

local TERMINAL_CREATOR = "com.superlogical.terminal"

local function sanitize_field(val, fallback)
  if type(val) ~= "string" then
    return fallback
  end
  local cleaned = val:gsub("\27", ""):gsub("[\t\r\n]+", " "):match("^%s*(.-)%s*$")
  if cleaned == "" then
    return fallback
  end
  return cleaned
end

local function shorten_home(path)
  if not path or path == "" then
    return nil
  end
  local home = os.getenv("HOME")
  if home and home ~= "" then
    if path == home then
      return "~"
    end
    local prefix = home .. "/"
    if path:sub(1, #prefix) == prefix then
      return "~/" .. path:sub(#prefix + 1)
    end
  end
  return path
end

local function pick_proc_name(proc)
  if not proc then
    return nil
  end
  local name = proc.script or proc.name or proc.argv0
  if type(name) == "string" and name ~= "" then
    -- Strip leading '-' from login shells (e.g. "-zsh" -> "zsh")
    if name == proc.argv0 and name:sub(1, 1) == "-" then
      name = name:sub(2)
    end
    return name
  end
  return nil
end

local function get_block_pwd_and_app(session_id, block_id)
  local pwd_path = nil
  local app_name = nil

  -- 1. Check reported OSC 7 PWD first
  local pwd_res = rex.block.call(TERMINAL_CREATOR, "pwd", {
    session_id = session_id,
    block_id = block_id,
  })
  if pwd_res and pwd_res.pwd and pwd_res.pwd ~= "" then
    local stripped = pwd_res.pwd:gsub("^file://[^/]*", "")
    if stripped ~= "" then
      pwd_path = stripped
    end
  end

  -- 2. Inspect foreground/ancestors/child process for running app and cwd fallback
  local proc_res = rex.block.call(TERMINAL_CREATOR, "process", {
    session_id = session_id,
    block_id = block_id,
  })
  if proc_res then
    if proc_res.foreground then
      app_name = pick_proc_name(proc_res.foreground)
      if not pwd_path and proc_res.foreground.cwd and proc_res.foreground.cwd ~= "" then
        pwd_path = proc_res.foreground.cwd
      end
    end

    if proc_res.ancestors then
      for _, ancestor in ipairs(proc_res.ancestors) do
        if not app_name and ancestor.name ~= "login" then
          app_name = pick_proc_name(ancestor)
        end
        if not pwd_path and ancestor.cwd and ancestor.cwd ~= "" then
          pwd_path = ancestor.cwd
        end
      end
    end

    if proc_res.child then
      if not app_name then
        app_name = pick_proc_name(proc_res.child)
      end
      if not pwd_path and proc_res.child.cwd and proc_res.child.cwd ~= "" then
        pwd_path = proc_res.child.cwd
      end
    end
  end

  return shorten_home(pwd_path), app_name
end

local function find_window_block(window)
  local by_id = {}
  for _, layer in ipairs(window.layers or {}) do
    for _, blk in ipairs(layer.blocks or {}) do
      if blk.block_id then
        by_id[blk.block_id] = blk
      end
    end
  end

  if window.focused_block_id and by_id[window.focused_block_id] then
    return by_id[window.focused_block_id]
  end

  local tiled = window.layers and window.layers[1]
  if tiled and tiled.blocks and tiled.blocks[1] then
    return tiled.blocks[1]
  end

  for _, layer in ipairs(window.layers or {}) do
    if layer.blocks and layer.blocks[1] then
      return layer.blocks[1]
    end
  end

  return nil
end

local function resolve_tab_title(session_id, window, block)
  local label = window.label
  -- Rex assigns default labels like "Window 8f71d037"; prefer terminal title unless user renamed the tab
  if type(label) == "string" and label ~= "" and not label:match("^Window %x+$") then
    return label
  end

  if block and (not block.creator_name or block.creator_name == TERMINAL_CREATOR) then
    local title_res = rex.block.call(TERMINAL_CREATOR, "title", {
      session_id = session_id,
      block_id = block.block_id,
    })
    if title_res and type(title_res.title) == "string" and title_res.title ~= "" then
      return title_res.title
    end
  end

  return label or "(untitled)"
end

local function collect_tab_rows()
  local list_res, list_err = rex.call("session.list")
  if not list_res then
    error("tab_switcher: failed to list sessions: " .. tostring(list_err), 0)
  end

  local rows = {}
  for _, s in ipairs(list_res.sessions or {}) do
    local view = rex.session.view({ session_id = s.session_id })
    local session_name = sanitize_field(s.label, s.session_id)

    for _, w in ipairs((view and view.windows) or {}) do
      local block = find_window_block(w)
      local block_id = block and block.block_id or ""

      local pwd, app_name = nil, nil
      if block and (not block.creator_name or block.creator_name == TERMINAL_CREATOR) then
        pwd, app_name = get_block_pwd_and_app(s.session_id, block.block_id)
      end

      local tab_title = sanitize_field(resolve_tab_title(s.session_id, w, block), "(untitled)")
      local pwd_field = sanitize_field(pwd, "-")
      local app_field = sanitize_field(app_name, "-")

      local display = string.format(
        "\27[1;38;2;97;175;239m%s\27[0m  \27[38;2;220;223;228m%s\27[0m  \27[38;2;152;195;121m%s\27[0m  \27[38;2;198;120;221m%s\27[0m",
        session_name,
        tab_title,
        pwd_field,
        app_field
      )
      rows[#rows + 1] = table.concat({ s.session_id, w.window_id, block_id, display }, "\t")
    end
  end

  return rows
end

function M.setup(opts)
  opts = opts or {}
  local key = opts.key
  if key == nil then
    key = "ctrl+h>tab"
  end
  local bounds = opts.bounds or { 0.08, 0.12, 0.84, 0.72 }
  local bg_color = opts.bg_color or "#282c34"

  rex.action({
    name = "tab_switcher",
    title = "Switch Tab (fzf)",
    description = "Fuzzy search all tabs across sessions by title, working directory, and running app",
    category = "Workflows",
    keywords = "tab window switch fzf cwd pwd directory session",
    run = function(ctx)
      if not ctx.session_id then
        error("tab_switcher: no active session", 0)
      end

      local rows = collect_tab_rows()
      if #rows == 0 then
        error("tab_switcher: no tabs found", 0)
      end

      local tmp_path = os.tmpname()
      local fh, open_err = io.open(tmp_path, "w")
      if not fh then
        error("tab_switcher: failed to write temp file: " .. tostring(open_err), 0)
      end
      fh:write(table.concat(rows, "\n") .. "\n")
      fh:close()

      local shell_script = [=[
tmp="$1"
orig_sid="$2"
orig_bid="$3"
client_id="$4"
bg="$5"
trap 'rm -f "$tmp"' EXIT INT TERM

if [[ ! -s "$tmp" ]]; then
  exit 0
fi

selection=$(
  fzf --ansi \
      --layout=reverse \
      --border=none \
      --prompt="Tab > " \
      --delimiter=$'\t' \
      --with-nth=4.. \
      --no-multi \
      --color="bg:${bg},bg+:#3e4451,gutter:${bg},prompt:#61afef,pointer:#e06c75,hl:#e5c07b,hl+:#e5c07b" \
      < "$tmp"
)

if [[ -n "$selection" ]]; then
  IFS=$'\t' read -r target_sid target_wid target_bid _rest <<< "$selection"
  if [[ -n "$target_sid" && -n "$target_wid" ]]; then
    if [[ -n "$client_id" ]]; then
      err_out=$(rex -C "$client_id" do session.select session_id="$target_sid" window_id="$target_wid" 2>&1)
      rc=$?
    else
      err_out=$(rex do session.select session_id="$target_sid" window_id="$target_wid" 2>&1)
      rc=$?
    fi

    if [[ -n "$target_bid" ]]; then
      rex focus -s "$target_sid" -b "$target_bid" >/dev/null 2>&1
    else
      rex window focus -s "$target_sid" "$target_wid" >/dev/null 2>&1
    fi

    if [[ $rc -ne 0 ]]; then
      print -r -- "$err_out"
      if [[ "$err_out" == *"Remote Control"* ]]; then
        print -r -- "Enable Remote Control in Rex Settings -> Server -> Client Info."
      fi
      printf "Press any key to close..."
      read -k 1 -s
    fi
  fi
else
  if [[ -n "$orig_sid" && -n "$orig_bid" ]]; then
    rex focus -s "$orig_sid" -b "$orig_bid" >/dev/null 2>&1
  fi
fi
]=]

      local layer, err = rex.session.new_layer({
        bounds = bounds,
        focus = true,
        layout = rex.layout.block({
          flavor = "com.superlogical.terminal.shell",
          options = {
            shell = "zsh",
            login = true,
            theme = {
              background = bg_color,
            },
            command = {
              "zsh",
              "-l",
              "-c",
              shell_script,
              "rex-tab-switcher",
              tmp_path,
              ctx.session_id,
              ctx.block_id or "",
              ctx.client_id or "",
              bg_color,
            },
          },
        }),
      })

      if not layer then
        os.remove(tmp_path)
        error("tab_switcher: failed to create floating layer: " .. tostring(err), 0)
      end

      return layer
    end,
  })

  if key and key ~= false then
    rex.bind(key, "tab_switcher")
  end
end

return M
