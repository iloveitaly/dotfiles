#!/usr/bin/env zsh

# you'll need to run this as root to modify the /etc/hosts file

# to test this script using sleepwatcher:
# 	sudo brew services start sleepwatcher
#
# with verbose logging enabled
#  	sudo /usr/local/sbin/sleepwatcher --verbose --wakeup .wakeup
#
# You may need to reinstall the sleepwatcher process when upgrading macos:
# 	brew reinstall sleepwatcher
#
# This process logs to `/var/log/com.apple.xpc.launchd/launchd.log`

# asdf is operating in a different environment, we can't use it directly

# commands to get the node & hostile paths
#   - `asdf which node`
#   - `asdf which hostile`

# HOME is required for asdf to properly source versions
export HOME=/Users/mike

source ~/.asdf/asdf.sh
source ~/.config/focus/functions.sh

hostile load ~/.config/distracting_sites.txt
flush-dns

# Want to check what the system is resolving a host to?
# 	dscacheutil -q host -a name www.thedomain.com

