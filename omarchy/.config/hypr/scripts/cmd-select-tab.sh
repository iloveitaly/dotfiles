#!/usr/bin/env bash
# Cmd+1..9: select tab N in the focused app.
#
# Hyprland binds Super+digit as binddn (non-consuming) in bindings-tabs.conf so
# the key also reaches the focused window:
#   - Ghostty: Super+N → super+N=goto_tab (config.local). No-op here.
#   - Browsers: ignore Super+N; we inject Ctrl+N via wtype.
#
# Usage: cmd-select-tab.sh <1-9>
# See omarchy/README.md "Key input layering".

set -euo pipefail

n="${1:-}"
[[ "$n" =~ ^[1-9]$ ]] || exit 0

class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
class_lc=${class,,}

case "$class_lc" in
  chromium|google-chrome*|brave-browser|brave-browser*|firefox|firefox-*|chrome-*)
    # Super still held during bind; browsers accept Ctrl+N (often with Super too).
    if command -v wtype >/dev/null 2>&1; then
      wtype -M ctrl -k "$n" -m ctrl
    else
      hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"CTRL\", key = \"$n\" })"
    fi
    ;;
  com.mitchellh.ghostty|ghostty)
    # Super+N already passed through (binddn) → Ghostty goto_tab. Do not re-inject:
    # synthetic Super/Alt while physical Super is held becomes Super+Alt+N and fails.
    :
    ;;
  *)
    :
    ;;
esac
