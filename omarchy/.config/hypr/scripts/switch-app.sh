#!/usr/bin/env bash
# Fuzzy-switch among currently running applications (one entry per class).
# Bound to Cmd+Tab / Super+Tab (see bindings-switcher.conf).
#
# Groups open windows by class, keeps the most recently focused window per app,
# then focuses that window on selection. Super+Space remains the full app launcher.

set -euo pipefail

clients_json=$(hyprctl clients -j 2>/dev/null) || exit 0
[[ -n "$clients_json" && "$clients_json" != "[]" ]] || exit 0

# One row per class (first after focusHistoryID sort = most recent for that class).
# Address is field 1; display is a friendly class name plus title of that window.
mapfile -t lines < <(jq -r '
  def pretty:
    if test("^chrome-") then
      sub("^chrome-"; "") | sub("__.*$"; "") | gsub("-"; ".")
    elif test("\\.") then
      split(".") | last
    else
      .
    end;

  [.[] | select(.mapped == true and .hidden == false)]
  | sort_by(.focusHistoryID)
  | group_by(.class)
  | map(sort_by(.focusHistoryID) | .[0])
  | sort_by(.focusHistoryID)
  | .[]
  | (.title // "") as $t
  | (.class // "?") as $c
  | ($c | pretty) as $name
  | "\(.address)\t\($name) — \($t | gsub("[\t\n]"; " "))"
' <<<"$clients_json")

((${#lines[@]} > 0)) || exit 0

labels=()
for line in "${lines[@]}"; do
  labels+=("${line#*$'\t'}")
done

selected=$(
  printf '%s\n' "${labels[@]}" |
    omarchy-launch-walker --dmenu \
      -p "Apps" \
      --width 560 --minheight 1 --maxheight 400 \
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
