#!/usr/bin/env zsh

# TODO should write up a blog post about this one
twitter_logout() {
  echo "Logging out of twitter..."

  # pause hyper-focus blocking so we can logout of twitter
  http --ignore-stdin POST http://localhost:9029/pause until=$(date -v+1M +%s)

  hostile remove twitter.com
  hostile remove www.twitter.com

  flush-dns

  osascript << EOF
  tell application "Safari"
    log "Opening Twitter"
    activate
    open location "https://twitter.com/logout"
  end tell

  tell application "System Events"
    tell process "Safari"
      delay 2
      log "Attempting to log out"
      click button "Log out" of group 1 of group 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1
      delay 1
    end tell
  end tell

  tell application "Safari"
    log "Closing twitter page"
    close current tab of front window
  end tell
EOF
}