#!/usr/bin/env zsh
# Description: tmux launcher for vs code which will name the sessions

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
    /opt/homebrew/bin/tmux new -ADs "$session"
    break
  fi

  counter=$((counter + 1))
done
