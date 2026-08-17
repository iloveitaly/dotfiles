#!/usr/bin/env bash
# Cmd+T: new tab in the *focused* app (not a new Chromium process).
# Float toggle is Hyper+T (bindings-hyper.conf).
#
# Hypr binds Super+T as binddn (non-consuming) so Ghostty receives Super+T →
# super+t=new_tab (config.local). Browsers ignore Super+T; we inject Ctrl+T.
# Super is still held during the bind, so wtype is more reliable than sendshortcut.
# Do not use `chromium about:blank` — that attaches to some browser session, not
# necessarily the focused window.
#
# See omarchy/README.md "Key input layering".

set -euo pipefail

class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
class_lc=${class,,}

send_ctrl_t() {
  if command -v wtype >/dev/null 2>&1; then
    wtype -M ctrl -k t -m ctrl
  else
    hyprctl dispatch sendshortcut "CTRL,T,activewindow"
  fi
}

case "$class_lc" in
  # Browsers + Chrome web apps (class chrome-*, e.g. Todoist / Grammarly)
  chromium|google-chrome*|brave-browser|brave-browser*|firefox|firefox-*|chrome-*)
    send_ctrl_t
    ;;
  com.mitchellh.ghostty|ghostty)
    # Super+T already passed through (binddn) → Ghostty new_tab. Do not re-inject.
    :
    ;;
  *)
    :
    ;;
esac
