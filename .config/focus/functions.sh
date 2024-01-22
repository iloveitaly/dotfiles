# check active rules: sudo pfctl -s rules
# check active pipes: sudo dnctl list

# based on: https://github.com/sitespeedio/throttle

throttle-internet() {
	local DOWNLOAD_LIMIT="1000Kbit/s"
	local UPLOAD_LIMIT="200Kbit/s"

	# Configure pipe for incoming traffic (download)
	(sudo dnctl pipe 1 config bw $DOWNLOAD_LIMIT && echo "Download pipe configured") || echo "Failed to configure download pipe"

	# Configure pipe for outgoing traffic (upload)
	(sudo dnctl pipe 2 config bw $UPLOAD_LIMIT && echo "Upload pipe configured") || echo "Failed to configure upload pipe"

	# Apply the rules to all devices
	sudo pfctl -f - <<-EOF
dummynet-anchor "throttle"
anchor "throttle"
EOF

	# Enable PF if not already enabled
	sudo pfctl -e

	sudo pfctl -a throttle -f - <<-EOF
dummynet in all pipe 1
dummynet out all pipe 2
EOF

	echo "Throttling applied to device en1"
}

unthrottle-internet() {
	echo "Unthrottling internet..."

	sudo dnctl -q flush
	sudo pfctl -f /etc/pf.conf
	sudo pfctl -d

	echo "Throttling removed"
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