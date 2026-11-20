-- ~/.config/rex/plugins/tab_switcher.lua
-- Rex plugin: floating fzf tab switcher across all connected machines showing:
--   machine name  session name  tab title  pwd  running application name
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
--   requires Remote Control enabled in Rex Settings -> Server -> Client Info):
--     phinze/rig: https://github.com/phinze/rig
--     https://discord.com/channels/1546797889009881158/1562120012179841065
--     tale/dotfiles: https://github.com/tale/dotfiles/blob/6d19a1464ba56eef2922e2a09b7798f6bcc25a25/modules/rex/init.lua#L23
--     https://discord.com/channels/1546797889009881158/1564508870465036289
--     https://discord.com/channels/1546797889009881158/1559289044439932949

local M = {}

local TERMINAL_CREATOR = "com.superlogical.terminal"
local SWITCH_TITLE_PREFIX = "__REX_TAB_SWITCH__:"

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

local function shorten_home(path, block_home)
  if not path or path == "" then
    return nil
  end
  local home = (block_home and block_home ~= "" and block_home) or os.getenv("HOME")
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
  -- Match Rex's process_changed priority: script -> argv0 -> name
  local raw = proc.script or proc.argv0 or proc.name
  if type(raw) == "string" and raw ~= "" then
    -- Strip leading '-' from login shells (e.g. "-zsh" -> "zsh") and any path prefix
    local name = raw:gsub("^%-", ""):match("([^/]+)$") or raw
    if name ~= "" then
      return name
    end
  end
  return nil
end

local function find_local_rex_bin()
  local r = rex.exec({ "/bin/sh", "-c", "command -v rex 2>/dev/null || true" })
  if r and r.ok and type(r.stdout) == "string" then
    local p = r.stdout:match("^%s*(.-)%s*$")
    if p ~= "" then
      return p
    end
  end

  local home = os.getenv("HOME") or ""
  local mac_bundled = home .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
  local chk = rex.exec({ "/bin/sh", "-c", [[test -x "$1"]], "chk", mac_bundled })
  if chk and chk.ok then
    return mac_bundled
  end

  return "rex"
end

local function local_machine_name()
  local res = rex.exec({ "hostname", "-s" })
  if res and res.ok and type(res.stdout) == "string" then
    local name = sanitize_field(res.stdout, nil)
    if name then
      return name
    end
  end
  return "local"
end

local function get_block_pwd_and_app(api, session_id, block_id)
  local pwd_path = nil
  local app_name = nil
  local block_home = nil

  local pwd_res = api.block.call(TERMINAL_CREATOR, "pwd", {
    session_id = session_id,
    block_id = block_id,
  })
  if pwd_res and pwd_res.pwd and pwd_res.pwd ~= "" then
    local stripped = pwd_res.pwd:gsub("^file://[^/]*", "")
    if stripped ~= "" then
      pwd_path = stripped
    end
  end

  local proc_res = api.block.call(TERMINAL_CREATOR, "process", {
    session_id = session_id,
    block_id = block_id,
  })
  if proc_res then
    block_home = proc_res.home

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

  return shorten_home(pwd_path, block_home), app_name
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

local function resolve_tab_title(api, session_id, window, block)
  local label = window.label
  -- Rex assigns default labels like "Window 8f71d037"; prefer terminal title unless user renamed the tab
  if type(label) == "string" and label ~= "" and not label:match("^Window %x+$") then
    return label
  end

  if block and (not block.creator_name or block.creator_name == TERMINAL_CREATOR) then
    local title_res = api.block.call(TERMINAL_CREATOR, "title", {
      session_id = session_id,
      block_id = block.block_id,
    })
    if title_res and type(title_res.title) == "string" and title_res.title ~= "" then
      return title_res.title
    end
  end

  return label or "(untitled)"
end

-- Resolve the client_id valid on `api`'s server (since client IDs are per-server).
local function resolve_target_client_id(api, preferred_client_id)
  local res = api.call("client.list")
  if not res or not res.clients then
    return ""
  end

  local apps = {}
  for _, c in ipairs(res.clients) do
    if preferred_client_id and c.client_id == preferred_client_id then
      return preferred_client_id
    end
    if c.info and c.info.kind == "app" then
      apps[#apps + 1] = c
    end
  end

  if #apps == 1 then
    return apps[1].client_id or ""
  end

  for _, c in ipairs(apps) do
    if c.info and c.info.platform == "macos" then
      return c.client_id or ""
    end
  end

  return ""
end

local function collect_server_rows(api, server_label, machine_name, preferred_client_id, out_rows)
  local list_res, list_err = api.call("session.list")
  if not list_res then
    return nil, list_err
  end

  local target_client_id = sanitize_field(resolve_target_client_id(api, preferred_client_id), "none")
  local safe_machine = sanitize_field(machine_name, "local")
  -- Use non-empty sentinel values ("local", "none") so IFS=$'\t' read never collapses empty columns
  local safe_server = sanitize_field(server_label, "local")

  for _, s in ipairs(list_res.sessions or {}) do
    local view = api.session.view({ session_id = s.session_id })
    if not view then
      -- Fresh streams (such as rex.server() or rex do) may need attaching before session.view
      api.session.attach({ session_id = s.session_id })
      view = api.session.view({ session_id = s.session_id })
    end

    local session_name = sanitize_field(s.label, s.session_id)

    for _, w in ipairs((view and view.windows) or {}) do
      local block = find_window_block(w)
      local block_id = (block and block.block_id and block.block_id ~= "") and block.block_id or "none"

      local pwd, app_name = nil, nil
      if block and (not block.creator_name or block.creator_name == TERMINAL_CREATOR) then
        pwd, app_name = get_block_pwd_and_app(api, s.session_id, block.block_id)
      end

      local tab_title = sanitize_field(resolve_tab_title(api, s.session_id, w, block), "(untitled)")
      local pwd_field = sanitize_field(pwd, "-")
      local app_field = sanitize_field(app_name, "-")

      local display = string.format(
        "\27[38;2;86;182;194m%s\27[0m  \27[1;38;2;97;175;239m%s\27[0m  \27[38;2;220;223;228m%s\27[0m  \27[38;2;152;195;121m%s\27[0m  \27[38;2;198;120;221m%s\27[0m",
        safe_machine,
        session_name,
        tab_title,
        pwd_field,
        app_field
      )
      out_rows[#out_rows + 1] = table.concat({
        safe_server,
        target_client_id,
        s.session_id,
        w.window_id,
        block_id,
        display,
      }, "\t")
    end
  end

  return true
end

function M._collect_local_rows()
  local rows = {}
  local ok, err = collect_server_rows(rex, "local", local_machine_name(), nil, rows)
  if not ok then
    error("tab_switcher: failed to list local sessions: " .. tostring(err), 0)
  end
  return rows
end

local function plugin_dir_path()
  local src = debug.getinfo(1, "S").source or ""
  local path = src:gsub("^@", "")
  local dir = path:match("^(.*)[/\\][^/\\]+$")
  if dir and dir ~= "" then
    return dir
  end
  local home = os.getenv("HOME") or ""
  local cfg = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
  return cfg .. "/rex/plugins"
end

local function collect_all_tab_rows(ctx, local_rex_bin)
  local rows = {}
  local is_remote = type(ctx.server) == "string" and ctx.server ~= ""
  local active_server = is_remote and ctx.server or "local"
  local active_machine = is_remote and ctx.server or local_machine_name()

  -- 1. Collect from the server handling this action (local or ctx.server)
  local ok, err = collect_server_rows(rex, active_server, active_machine, ctx.client_id, rows)
  if not ok then
    error("tab_switcher: failed to list sessions: " .. tostring(err), 0)
  end

  -- 2. When triggered from a remote server, also query the local Mac server via local CLI
  if is_remote then
    local lua_expr = string.format(
      "package.path = %q .. ';' .. package.path; return require('tab_switcher')._collect_local_rows()",
      plugin_dir_path() .. "/?.lua"
    )
    local res = rex.exec({ local_rex_bin, "do", "-e", lua_expr, "--json" }, { timeout = 5 })
    if res and res.ok and type(res.stdout) == "string" and res.stdout ~= "" then
      local local_rows = rex.json.decode(res.stdout)
      if type(local_rows) == "table" then
        for _, r in ipairs(local_rows) do
          rows[#rows + 1] = r
        end
      end
    end
  end

  -- 3. Collect from all other connected remote servers exposed via rex.servers()
  if type(rex.servers) == "function" then
    for _, srv_name in ipairs(rex.servers()) do
      if srv_name ~= ctx.server then
        local srv_ok, srv_api = pcall(rex.server, srv_name)
        if srv_ok and srv_api then
          local ok_srv, err_srv = pcall(collect_server_rows, srv_api, srv_name, srv_name, nil, rows)
          if not ok_srv then
            rex.log("warn", "tab_switcher: skipping server " .. tostring(srv_name) .. ": " .. tostring(err_srv))
          end
        end
      end
    end
  end

  return rows
end

-- When the floating layer runs on a remote server (e.g. BiancoBox), that server may not have
-- a network route back to the Mac's local Unix socket. Watch the layer block from the Mac and
-- perform cross-server switches locally when the popup emits the switch title marker.
local function start_remote_switch_bridge(local_rex_bin, remote_server, remote_session_id, layer_block_id)
  local watcher_lua = [=[
local target_block = rex.args.block_id
local local_rex = rex.args.local_rex
local prefix = rex.args.prefix

local function run_switch(payload)
  local srv, cid, sid, wid, bid = payload:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
  if not sid or sid == "" or not wid or wid == "" then
    return
  end

  local select_cmd = { local_rex }
  local focus_cmd = { local_rex }
  if srv ~= "" and srv ~= "local" then
    select_cmd[#select_cmd + 1] = "-S"
    select_cmd[#select_cmd + 1] = srv
    focus_cmd[#focus_cmd + 1] = "-S"
    focus_cmd[#focus_cmd + 1] = srv
  end
  if cid ~= "" and cid ~= "none" then
    select_cmd[#select_cmd + 1] = "-C"
    select_cmd[#select_cmd + 1] = cid
  end

  select_cmd[#select_cmd + 1] = "do"
  select_cmd[#select_cmd + 1] = "session.select"
  select_cmd[#select_cmd + 1] = "session_id=" .. sid
  select_cmd[#select_cmd + 1] = "window_id=" .. wid

  if bid ~= "" and bid ~= "none" then
    focus_cmd[#focus_cmd + 1] = "focus"
    focus_cmd[#focus_cmd + 1] = "-s"
    focus_cmd[#focus_cmd + 1] = sid
    focus_cmd[#focus_cmd + 1] = "-b"
    focus_cmd[#focus_cmd + 1] = bid
  else
    focus_cmd[#focus_cmd + 1] = "window"
    focus_cmd[#focus_cmd + 1] = "focus"
    focus_cmd[#focus_cmd + 1] = "-s"
    focus_cmd[#focus_cmd + 1] = sid
    focus_cmd[#focus_cmd + 1] = wid
  end

  rex.exec(select_cmd, { timeout = 5 })
  rex.exec(focus_cmd, { timeout = 5 })
end

rex.on("terminal.title_changed", function(_ctx, ev)
  if ev.block_id ~= target_block or type(ev.title) ~= "string" then
    return
  end
  if ev.title:sub(1, #prefix) == prefix then
    run_switch(ev.title:sub(#prefix + 1))
    rex.stop(0)
  end
end)

rex.on("terminal.child_exited", function(_ctx, ev)
  if ev.block_id == target_block then
    rex.stop(0)
  end
end)

rex.on("block_closed", function(_ctx, ev)
  if ev.block_id == target_block then
    rex.stop(0)
  end
end)
]=]

  rex.exec.start({
    local_rex_bin,
    "-S", remote_server,
    "do",
    "-s", remote_session_id,
    "--for", "5m",
    "-e", watcher_lua,
    "block_id=" .. layer_block_id,
    "local_rex=" .. local_rex_bin,
    "prefix=" .. SWITCH_TITLE_PREFIX,
  }, { detach = true, stdout = false, stderr = false })
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
    description = "Fuzzy search all tabs across all connected machines by session, title, working directory, and running app",
    category = "Workflows",
    keywords = "tab window switch fzf cwd pwd directory session host machine",
    run = function(ctx)
      if not ctx.session_id then
        error("tab_switcher: no active session", 0)
      end

      local local_rex_bin = find_local_rex_bin()
      local rows = collect_all_tab_rows(ctx, local_rex_bin)
      if #rows == 0 then
        error("tab_switcher: no tabs found", 0)
      end

      local rows_payload = table.concat(rows, "\n")
      local current_server = (type(ctx.server) == "string" and ctx.server ~= "" and ctx.server) or "local"

      local shell_script = [=[
rows_data="$1"
orig_sid="$2"
orig_bid="$3"
current_server="$4"
bg="$5"
switch_prefix="$6"

if [[ -z "$rows_data" ]]; then
  exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
  print -r -- "tab_switcher: fzf not found on PATH"
  printf "Press any key to close..."
  read -k 1 -s
  exit 1
fi

selection=$(
  printf '%s\n' "$rows_data" | fzf --ansi \
      --layout=reverse \
      --border=none \
      --prompt="Tab > " \
      --delimiter=$'\t' \
      --with-nth=6.. \
      --no-multi \
      --color="bg:${bg},bg+:#3e4451,gutter:${bg},prompt:#61afef,pointer:#e06c75,hl:#e5c07b,hl+:#e5c07b"
)

if [[ -n "$selection" ]]; then
  IFS=$'\t' read -r target_srv target_cid target_sid target_wid target_bid _rest <<< "$selection"
  if [[ -n "$target_sid" && -n "$target_wid" ]]; then
    # If running on a remote host and switching to a different host (e.g. back to the Mac),
    # signal the detached local watcher via OSC 0 title so the Mac executes the switch.
    if [[ "$current_server" != "local" && "$target_srv" != "$current_server" ]]; then
      printf '\033]0;%s%s|%s|%s|%s|%s\007' "$switch_prefix" "$target_srv" "$target_cid" "$target_sid" "$target_wid" "$target_bid"
      sleep 0.3
      exit 0
    fi

    srv_args=()
    if [[ "$target_srv" != "local" && "$target_srv" != "$current_server" ]]; then
      srv_args=(-S "$target_srv")
    fi

    cid_args=()
    if [[ -n "$target_cid" && "$target_cid" != "none" ]]; then
      cid_args=(-C "$target_cid")
    fi

    err_out=$(rex "${srv_args[@]}" "${cid_args[@]}" do session.select session_id="$target_sid" window_id="$target_wid" 2>&1)
    rc=$?

    if [[ -n "$target_bid" && "$target_bid" != "none" ]]; then
      rex "${srv_args[@]}" focus -s "$target_sid" -b "$target_bid" >/dev/null 2>&1
    else
      rex "${srv_args[@]}" window focus -s "$target_sid" "$target_wid" >/dev/null 2>&1
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
              rows_payload,
              ctx.session_id,
              ctx.block_id or "",
              current_server,
              bg_color,
              SWITCH_TITLE_PREFIX,
            },
          },
        }),
      })

      if not layer then
        error("tab_switcher: failed to create floating layer: " .. tostring(err), 0)
      end

      if current_server ~= "local" and layer.block_ids and layer.block_ids[1] then
        start_remote_switch_bridge(local_rex_bin, current_server, ctx.session_id, layer.block_ids[1])
      end

      return layer
    end,
  })

  if key and key ~= false then
    rex.bind(key, "tab_switcher")
  end
end

return M
