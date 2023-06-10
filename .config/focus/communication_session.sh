#!/usr/bin/env zsh

osascript << EOF
tell application "Flow" to activate
tell application "Flow" to reset
tell application "Flow" to start
EOF