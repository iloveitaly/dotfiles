#!/bin/sh
# Bring a just-focused window onto the active Space and stay there.
#
# `yabai -m window --space mouse` alone loses two races:
#   1. macOS still auto-swooshes to the window's old (now empty) Space
#   2. with a second display, `mouse` may be the other screen
#
# YABAI_WINDOW_ID is set by the window_focused signal.

export PATH="/opt/homebrew/bin:/usr/bin:/bin"

win="${YABAI_WINDOW_ID:-}"
[ -n "$win" ] || exit 0

dest=$(yabai -m query --spaces --space | jq -r '.index')
ws=$(yabai -m query --windows --window "$win" | jq -r '.space')

# Already on the Space we're working on (click / Cmd-Tab same Space).
[ "$ws" = "$dest" ] && exit 0

yabai -m window "$win" --space "$dest" 2>/dev/null
yabai -m space --focus "$dest" 2>/dev/null
yabai -m window --focus "$win" 2>/dev/null

# Auto-swoosh can finish after this signal; re-assert the destination.
(
  sleep 0.15
  yabai -m space --focus "$dest" 2>/dev/null
  yabai -m window --focus "$win" 2>/dev/null
) &
