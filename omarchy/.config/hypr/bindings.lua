-- Personal overrides. Loaded after Omarchy defaults (hyprland.lua).
-- Omarchy Quattro uses Lua only — ~/.config/hypr/*.conf overlays are not read.

-- Hyper = Caps Lock via keyd (Ctrl+Alt+Shift+Super). See bindings-hyper.conf.
-- Super+arrows stay stock tiling focus; Cmd+arrows stay keyd Home/End.

o.bind("SUPER + CTRL + ALT + SHIFT + LEFT", "Focus left (Hyper)", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + CTRL + ALT + SHIFT + RIGHT", "Focus right (Hyper)", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + CTRL + ALT + SHIFT + UP", "Focus up (Hyper)", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + CTRL + ALT + SHIFT + DOWN", "Focus down (Hyper)", hl.dsp.focus({ direction = "d" }))

o.bind("SUPER + CTRL + ALT + SHIFT + D", "Toggle dictation (Hyper)", "voxtype record toggle")

-- Hyper includes Ctrl, so an unbound Hyper+wheel is Ctrl+wheel in Chrome (page zoom).
o.bind("SUPER + CTRL + ALT + SHIFT + mouse_down", "Ignore Hyper+scroll", function() end)
o.bind("SUPER + CTRL + ALT + SHIFT + mouse_up", "Ignore Hyper+scroll", function() end)

-- Stock Super+F is fullscreen. keyd already rewrites Cmd+F → Ctrl+F (search).
hl.unbind("SUPER + F")
o.bind("SUPER + CTRL + ALT + SHIFT + F", "Full screen (Hyper)", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Workspaces on Hyper+1..0 so Super+1..9 can be Cmd-style tab select.
-- Stock Super+code:10..19 was switch workspace 1..10 (tiling.lua).
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + " .. key)
  o.bind(
    "SUPER + CTRL + ALT + SHIFT + " .. key,
    "Switch to workspace " .. workspace .. " (Hyper)",
    hl.dsp.focus({ workspace = tostring(workspace) })
  )
end

-- Ghostty pane focus: Cmd+Option+arrows (config.local super+alt+arrow_*).
-- Stock Super+Alt+arrows was move window into group (tiling.lua). Groups stay Super+G.
hl.unbind("SUPER + ALT + LEFT")
hl.unbind("SUPER + ALT + RIGHT")
hl.unbind("SUPER + ALT + UP")
hl.unbind("SUPER + ALT + DOWN")

-- Column resize on scrolling layout (not Hyper — Hyper adds Shift).
-- home/end: keyd maps bare Cmd+Left/Right → Home/End; same cycle as a fallback.
o.bind("SUPER + CTRL + ALT + LEFT", "Cycle narrower column", hl.dsp.layout("colresize -conf"))
o.bind("SUPER + CTRL + ALT + RIGHT", "Cycle wider column", hl.dsp.layout("colresize +conf"))
o.bind("SUPER + CTRL + ALT + HOME", "Cycle narrower column", hl.dsp.layout("colresize -conf"))
o.bind("SUPER + CTRL + ALT + END", "Cycle wider column", hl.dsp.layout("colresize +conf"))
o.bind("SUPER + CTRL + ALT + S", "Swap window left", hl.dsp.window.swap({ direction = "l" }))

-- Stock Super+Shift+B / Super+Shift+Return is omarchy-launch-browser (xdg desktop).
-- chrome-personal: one google-chrome window per workspace (Profile 1).
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + B", "Browser", "chrome-personal")
o.bind("SUPER + SHIFT + RETURN", "Browser", "chrome-personal")

-- Cmd+T/W/1..9: binddn so Ghostty gets Super+… (config.local); browsers get Ctrl via scripts.
-- Stock Super+T was float toggle; Super+W was close window; Super+L was layout toggle.
hl.unbind("SUPER + T")
hl.unbind("SUPER + W")
hl.unbind("SUPER + L")
o.bind("SUPER + T", "New tab", "~/.config/hypr/scripts/cmd-new-tab.sh", { non_consuming = true })
o.bind("SUPER + W", "Close tab", "~/.config/hypr/scripts/cmd-close-tab.sh", { non_consuming = true })
o.bind("SUPER + L", "Location bar / layout toggle", "~/.config/hypr/scripts/cmd-location-bar.sh")

for tab = 1, 9 do
  o.bind(
    "SUPER + code:" .. tostring(tab + 9),
    "Select tab " .. tab,
    "~/.config/hypr/scripts/cmd-select-tab.sh " .. tab,
    { non_consuming = true }
  )
end

-- Cmd+Q close window (stock Super+W). Super+W stays close-tab / Ghostty pass-through.
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Super+Ctrl+Left/Right: prev/next existing workspace.
-- Stock Super+Ctrl+arrows was grouped-window focus (tiling.lua).
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Hyper+W: windows on this workspace. Cmd+Tab: running apps.
-- Stock Super+Tab was next workspace (tiling.lua).
hl.unbind("SUPER + TAB")
o.bind("SUPER + CTRL + ALT + SHIFT + W", "Switch window (Hyper)", "~/.config/hypr/scripts/switch-window.sh")
o.bind("SUPER + TAB", "Switch running app (Cmd+Tab)", "~/.config/hypr/scripts/switch-app.sh")

-- Cmd+Shift+Space: 1Password Quick Access. Stock Super+Shift+Space was toggle bar.
-- Super+Shift+/ was Passwords launcher.
hl.unbind("SUPER + SHIFT + SPACE")
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SPACE", "Open 1Password Quick Access", "1password --quick-access")

-- Cmd+Shift+C: clipboard history. Stock Super+Shift+C was HEY Calendar.
-- Walker is gone on Quattro; same manager as stock Super+Ctrl+V.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- Super+Shift+E: Superhuman. Stock Super+Shift+E / Super+Shift+Alt+E were HEY.
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + E", "Superhuman Work", "superhuman-work")
o.bind("SUPER + SHIFT + ALT + E", "Superhuman Personal", "superhuman-personal")

-- Vicinae (Raycast-style). Super+Space stays Omarchy menu.
o.bind("CTRL + SPACE", "Launch apps (Vicinae)", "~/.local/bin/vicinae toggle")
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "vicinae" }, no_anim = true, animation = "none" })

-- Stock chords we drop (no replacement). Ghostty keeps Super+D / Super+Shift+D splits.
hl.unbind("SUPER + CTRL + SPACE") -- was: background switcher
hl.unbind("SUPER + SHIFT + M") -- was: Music / Spotify
hl.unbind("SUPER + SHIFT + X") -- was: X
hl.unbind("SUPER + SHIFT + ALT + X") -- was: X Post
hl.unbind("SUPER + SHIFT + P") -- was: Google Photos
hl.unbind("SUPER + RETURN") -- was: Terminal
hl.unbind("SUPER + SHIFT + D") -- was: Docker (lazydocker)
hl.unbind("SUPER + S") -- was: scratchpad
hl.unbind("SUPER + ALT + S") -- was: move window to scratchpad
hl.unbind("SUPER + P") -- was: dwindle pseudo
hl.unbind("SUPER + K") -- was: keybindings menu

