#!/usr/bin/env bash
# Ensure keyd-application-mapper is running (Hyprland exec-once only at session start).
# Reload config via SIGUSR1 if already running. Requires group "keyd" for the socket.
set -euo pipefail

pid="$(ps -eo pid=,args= | awk '/\/keyd-application-mapper( |$)/ && !/awk/ {print $1; exit}')"

if [[ -n "${pid:-}" ]]; then
  kill -USR1 "$pid" 2>/dev/null || true
  echo "keyd-application-mapper: reloaded config (pid $pid)"
  exit 0
fi

if ! command -v keyd-application-mapper >/dev/null 2>&1; then
  echo "keyd-application-mapper: not installed" >&2
  exit 0
fi

if ! groups | grep -qw keyd; then
  echo "keyd-application-mapper: skipped — user not in group keyd (run: just configure && re-login)" >&2
  exit 0
fi

# Foreground in background; no -d (restart loops on some setups)
keyd-application-mapper >/dev/null 2>&1 &
disown 2>/dev/null || true
sleep 0.2
pid="$(ps -eo pid=,args= | awk '/\/keyd-application-mapper( |$)/ && !/awk/ {print $1; exit}')"
if [[ -n "${pid:-}" ]]; then
  echo "keyd-application-mapper: started (pid $pid)"
else
  echo "keyd-application-mapper: failed to stay up (check socket / group keyd)" >&2
fi
