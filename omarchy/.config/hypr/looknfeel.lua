-- Personal look/feel. Loaded after Omarchy defaults (hyprland.lua).
-- Mirrors looknfeel.conf (unused under Lua).

-- Flush L/R, keep vertical pad; niri-like side-scrolling columns.
hl.config({
  general = {
    gaps_out = { top = 10, right = 0, bottom = 10, left = 0 },
    layout = "scrolling",
  },
  scrolling = {
    -- Full-width default (stock Omarchy is 0.49 ≈ two columns + side slack).
    column_width = 1.0,
    -- Don't force a lone column fullscreen — colresize ±conf owns width.
    fullscreen_on_one_column = false,
    -- Cycle with Super+Ctrl+Alt+Left/Right.
    explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
  },
})
