#!/usr/bin/env zsh

# assume the script is executed without common environment variables
# additionally, since it's not executed in login mode, ~/.zshrc is not loaded
export USER=mike
export HOME=/Users/$USER

source ~/.asdf/asdf.sh
source ~/.config/focus/functions.sh

# stop caffinating so the computer actually falls back to sleep
/usr/bin/killall caffeinate

throttle-internet

# TODO maybe ask for the one big thing I want to do tomorrow?