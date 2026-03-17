#!/usr/bin/env zsh

# since this can be run as root, we need to reconfigure some basic environment configuration
export HOME=/Users/mike
export USER=mike
# add `mise` bin to path
export PATH="$HOME/.local/bin:/sbin:/usr/sbin:/opt/homebrew/bin:$PATH"

eval "$(~/.local/bin/mise activate)"

# block all distracting websites as defined by our configuration
npx hostile load ~/.config/distracting_sites.txt

# these seem to be wiped out for some reason...
npx hostile set 127.0.0.1 localhost
npx hostile set ::1 localhost

# source ~/.config/focus/functions.sh
# flush-dns
