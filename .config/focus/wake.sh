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

# https://apple.stackexchange.com/questions/303110/flush-cache-of-dns-on-macos-sierra-high-sierra/303119#303119
flush-dns() {
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder

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
}

# logout of twitter
http POST http://localhost:9029/pause until=$(date -v+1M +%s)
hostile remove twitter.com
flush-dns

osascript << EOF
tell application "Safari"
	activate
	open location "https://twitter.com/logout"
	delay 1
end tell

tell application "System Events"
	tell process "Safari"
		click button "Log out" of group 1 of group 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1
	end tell
end tell
EOF

hostile load ~/.config/distracting_sites.txt
flush-dns

# Want to check what the system is resolving a host to?
# 	dscacheutil -q host -a name www.thedomain.com

