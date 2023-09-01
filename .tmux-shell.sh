#!/usr/bin/env zsh
# Description: tmux launcher for vs code which will restore a terminal session based on the directory it was opened in

session_uid=${PWD:t}
counter=0

# sleep for a random amount of time between 0 and 2 seconds
# sleep $(((RANDOM % 2000)/1000.0))

while [[ $counter -lt 10 ]]; do
  session="${session_uid}-$counter"

  # if the session doesn't exist, create it
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new -ADs "$session"
    break
  fi

  # if the session exists but isn't attached, attach it
  if [ -z "$(tmux list-sessions -F "#{session_name} #{session_attached}" | grep "^$session 1")" ]; then
    tmux attach -dt "$session"
    break
  fi

  counter=$((counter + 1))
done

if [[ $counter -ge 10 ]]; then
  echo "Could not find an unattached session after 10 attempts."
fi
