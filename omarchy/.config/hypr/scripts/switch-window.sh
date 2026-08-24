#!/usr/bin/env bash
# Fuzzy-switch among open windows on the *current* workspace (omarchy-menu-select).
# Bound to Hyper+W (see bindings-switcher.conf).
#
# Each mapped, non-hidden client on the active workspace is listed as:
#   class — title
# Selecting focuses that window.

set -euo pipefail

clients_json=$(hyprctl clients -j 2>/dev/null) || exit 0
[[ -n "$clients_json" && "$clients_json" != "[]" ]] || exit 0

ws_id=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')
[[ -n "$ws_id" ]] || exit 0

# Sort by focus history (0 = most recently focused). Current workspace only.
# Address is field 1 (tab-separated) so titles may contain anything.
mapfile -t lines < <(jq -r --argjson ws "$ws_id" '
  [.[] | select(.mapped == true and .hidden == false and .workspace.id == $ws)]
  | sort_by(.focusHistoryID)
  | .[]
  | (.title // "") as $t
  | (.class // "?") as $c
  | "\(.address)\t\($c) — \($t | gsub("[\t\n]"; " "))"
' <<<"$clients_json")

((${#lines[@]} > 0)) || exit 0

# Labels only for the picker (hide the address column).
labels=()
for line in "${lines[@]}"; do
  labels+=("${line#*$'\t'}")
done

selected=$(
  printf '%s\n' "${labels[@]}" |
    omarchy-menu-select "Windows" -- --width 720 --maxheight 400 \
      2>/dev/null
) || exit 0

[[ -n "${selected:-}" ]] || exit 0

address=""
for line in "${lines[@]}"; do
  label="${line#*$'\t'}"
  if [[ "$label" == "$selected" ]]; then
    address="${line%%$'\t'*}"
    break
  fi
done

[[ -n "$address" ]] || exit 0

hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null
hyprctl dispatch "hl.dsp.window.bring_to_top()" >/dev/null 2>&1 || true
