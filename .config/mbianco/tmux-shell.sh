#!/usr/bin/env bash

# Description: tmux launcher for VS Code which will name the sessions. Naming sessions is helpful when inspecting them
# later (via tmux list-sessions) or reattaching to them (which will happen automatically in VSC). Note that bash
# is intentional and important here: it avoids ~/.zshenv being sourced, which can cause homebrew and other PATH mutations
# to load which will impact mise, direnv, etc downstream. The intention here is to start a very clean + simple shell.

session_uid=${PWD:t}
counter=0

# tmux converts periods to _
session_uid="${session_uid//./_}"

# prevent conflicts when multiple shell sessions are opening at the same time
sleep 0.2

while [[ $counter -lt 20 ]]; do
  session="${session_uid}-${counter}"

  # if the session doesn't exist, create it
  if ! /opt/homebrew/bin/tmux has-session -t "$session" 2>/dev/null; then
    exec /opt/homebrew/bin/tmux new -ADs "$session"
  fi

  counter=$((counter + 1))
done
