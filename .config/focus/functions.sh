# check active rules: sudo pfctl -s rules
# check active pipes: sudo dnctl list

# https://github.com/sitespeedio/throttle

throttle-internet() {
	echo "Throttling internet..."

  sudo pfctl -E
  sudo dnctl pipe 1 config bw 1Mbit/s
  # echo "dummynet out quick on en7 pipe 1" | sudo pfctl -ef -
  echo "dummynet in quick proto tcp from any to any pipe 1" | sudo pfctl -a throttleRule -ef -
}

unthrottle-internet() {
	echo "Unthrottling internet..."

  sudo dnctl -q flush
  sudo pfctl -d
}

# https://apple.stackexchange.com/questions/303110/flush-cache-of-dns-on-macos-sierra-high-sierra/303119#303119
flush-dns() {
	echo "Flushing DNS..."

	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder

	# TODO maybe use this trick https://apple.stackexchange.com/questions/303110/flush-cache-of-dns-on-macos-sierra-high-sierra/303119#303119

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