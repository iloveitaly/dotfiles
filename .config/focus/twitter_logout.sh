#!/usr/bin/env zsh

# logout of twitter
twitter_logout() {
  http --ignore-stdin POST http://localhost:9029/pause until=$(date -v+1M +%s)

  hostile remove twitter.com
  hostile remove www.twitter.com

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

    delay 0.5
  end tell

  tell application "Safari"
      close current tab of front window
  end tell
EOF
}