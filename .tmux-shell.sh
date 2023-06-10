#!/usr/bin/env zsh

session_name=${PWD:t}
counter=0

while [[ $counter -lt 10 ]]; do
  if [[ $counter -gt 0 ]]; then
    session="${session_name} $counter"
  else
    session="${session_name}"
  fi

  # if the session doesn't exist, create it
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new -ADs "$session"
    break
  fi

  # if the session exists but isn't attached, attach it
  if [ -z "$(tmux list-sessions -F "#{session_name} #{session_attached}" | grep "^$session 1")" ]; then
    tmux attach -t "$session"
    break
  fi

  counter=$((counter + 1))
done

if [[ $counter -ge 10 ]]; then
  echo "Could not find an unattached session after 10 attempts."
fi
