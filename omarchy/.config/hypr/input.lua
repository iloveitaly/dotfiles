-- Personal input overrides. Loaded after Omarchy defaults (hyprland.lua).
-- Caps Lock is Hyper via keyd — do not set compose:caps (stock default).
-- Click-to-focus: hover-focus pans the scrolling layout and feels like a jump.

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "",
    follow_mouse = 0,
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    touchpad = {
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})
