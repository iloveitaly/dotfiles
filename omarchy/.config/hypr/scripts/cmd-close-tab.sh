#!/usr/bin/env bash
# Cmd+W: close tab in the focused browser / terminal.
# Hypr binds Super+W as binddn (non-consuming):
#   - Ghostty: Super+W → super+w=close_tab:this (config.local). No-op here.
#   - Browsers: ignore Super+W; inject Ctrl+W via wtype.
#   - Other terminals: inject Ctrl+Shift+W (common close-tab chord).
# Non-browser/non-terminal: no-op (window close is Super+Q). See omarchy/README.md.

set -euo pipefail

class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
class_lc=${class,,}

send_ctrl() {
  local key=$1
  if command -v wtype >/dev/null 2>&1; then
    wtype -M ctrl -k "$key" -m ctrl
  else
    hyprctl dispatch sendshortcut "CTRL,$key,activewindow"
  fi
}

send_ctrl_shift() {
  local key=$1
  if command -v wtype >/dev/null 2>&1; then
    wtype -M ctrl -M shift -k "$key" -m shift -m ctrl
  else
    hyprctl dispatch sendshortcut "CTRL SHIFT,$key,activewindow"
  fi
}

case "$class_lc" in
  chromium|google-chrome*|brave-browser|brave-browser*|firefox|firefox-*|chrome-*)
    send_ctrl w
    ;;
  com.mitchellh.ghostty|ghostty)
    # Super+W already passed through (binddn) → Ghostty close_tab. Do not re-inject.
    :
    ;;
  alacritty|kitty|foot)
    send_ctrl_shift w
    ;;
  *)
    :
    ;;
esac
