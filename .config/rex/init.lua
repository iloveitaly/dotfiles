-- ~/.config/rex/init.lua
-- Rex configuration (Lua 5.1)

local home = os.getenv("HOME") or ""
local config_dir = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local rex_dir = config_dir .. "/rex"
local plugins_dir = rex_dir .. "/plugins"

-- 1. Extend package.path so require() resolves plugins and local modules:
--    - ~/.config/rex/plugins/<plugin>.lua
--    - ~/.config/rex/plugins/<plugin>/init.lua
--    - ~/.config/rex/plugins/<plugin>/<plugin>.lua
--    - ~/.config/rex/<module>.lua
package.path = table.concat({
  rex_dir .. "/?.lua",
  rex_dir .. "/?/init.lua",
  plugins_dir .. "/?.lua",
  plugins_dir .. "/?/init.lua",
  plugins_dir .. "/?/?.lua",
  package.path,
}, ";")

-- 2. Helper to safely require and setup a plugin
local function use_plugin(name, opts)
  local ok, plugin = pcall(require, name)
  if not ok then
    return nil, plugin
  end
  if type(plugin) == "table" and type(plugin.setup) == "function" then
    local setup_ok, err = pcall(plugin.setup, opts or {})
    if not setup_ok then return nil, err end
  end
  return plugin
end

-- 3. Auto-load all plugins found in ~/.config/rex/plugins/
local function load_all_plugins()
  local r = rex.exec({ "/bin/sh", "-c", "ls -1d " .. plugins_dir .. "/* 2>/dev/null" })
  if not r or not r.ok or not r.stdout then return end

  for path in r.stdout:gmatch("[^\r\n]+") do
    local basename = path:match("([^/]+)$")
    if basename and not basename:match("^%.") then
      local mod_name = basename:gsub("%.lua$", "")
      use_plugin(mod_name)
    end
  end
end

load_all_plugins()
