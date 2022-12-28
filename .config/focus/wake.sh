#!/usr/bin/env bash

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

source /Users/mike/.asdf/asdf.sh
hostile load /Users/mike/.config/distracting_sites.txt

# https://apple.stackexchange.com/questions/303110/flush-cache-of-dns-on-macos-sierra-high-sierra/303119#303119
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Want to check what the system is resolving a host to?
# 	dscacheutil -q host -a name www.thedomain.com

# safari will often cache DNS, lets clear it to ensure everything is blocked
osascript << EOF
tell application "Safari"
	activate
end tell

tell application "System Events"
	tell process "Safari"
		tell menu bar 1 to tell menu bar item "Develop" to tell menu 1 to tell menu item "Empty Caches" to click
	end tell
end tell
EOF