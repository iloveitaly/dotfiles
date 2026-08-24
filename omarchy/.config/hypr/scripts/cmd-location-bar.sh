#!/usr/bin/env bash
# Cmd+L: focus location bar in browser (Ctrl+L). Elsewhere: stock Super+L layout toggle.
# Super is still held during the bind — use wtype for a clean Ctrl+L.

set -euo pipefail

class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
class_lc=${class,,}

case "$class_lc" in
  chromium|google-chrome*|brave-browser|brave-browser*|firefox|firefox-*|chrome-*)
    if command -v wtype >/dev/null 2>&1; then
      wtype -M ctrl -k l -m ctrl
    else
      hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "L" })'
    fi
    ;;
  *)
    omarchy-hyprland-workspace-layout-toggle
    ;;
esac
