#!/usr/bin/env zsh
# Description: tmux launcher for vs code which will name the sessions

session_uid=${PWD:t}
counter=0

# tmux converts periods to _
session_uid="${session_uid//./_}"

sleep 1
while [[ $counter -lt 20 ]]; do
  session="${session_uid}-${counter}"

  # if the session doesn't exist, create it
  if ! tmux has-session -t "$session" 2> /dev/null; then
    tmux new -ADs "$session"
    break
  fi

  counter=$((counter + 1))
done
