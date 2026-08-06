#!/usr/bin/env bash
# Fuzzy-switch among all open Hyprland windows (Walker dmenu).
# Bound to Hyper+W (see bindings-switcher.conf).
#
# Each mapped, non-hidden client is listed as:
#   [workspace] class — title
# Selecting focuses that window (and its workspace).

set -euo pipefail

clients_json=$(hyprctl clients -j 2>/dev/null) || exit 0
[[ -n "$clients_json" && "$clients_json" != "[]" ]] || exit 0

# Sort by focus history (0 = most recently focused). Skip unmapped/hidden.
# Address is field 1 (tab-separated) so titles may contain anything.
mapfile -t lines < <(jq -r '
  [.[] | select(.mapped == true and .hidden == false)]
  | sort_by(.focusHistoryID)
  | .[]
  | (.title // "") as $t
  | (.class // "?") as $c
  | (.workspace.name // "?") as $w
  | "\(.address)\t[\($w)] \($c) — \($t | gsub("[\t\n]"; " "))"
' <<<"$clients_json")

((${#lines[@]} > 0)) || exit 0

# Labels only for the picker (hide the address column).
labels=()
for line in "${lines[@]}"; do
  labels+=("${line#*$'\t'}")
done

selected=$(
  printf '%s\n' "${labels[@]}" |
    omarchy-launch-walker --dmenu \
      -p "Windows" \
      --width 720 --minheight 1 --maxheight 400 \
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

hyprctl dispatch focuswindow "address:$address" >/dev/null
hyprctl dispatch alterzorder top,address:"$address" >/dev/null 2>&1 || true
