#!/usr/bin/env zsh

# TODO should write up a blog post about this one
twitter_logout() {
  echo "Logging out of X..."

  # pause hyper-focus blocking so we can logout of X
  http --ignore-stdin POST http://localhost:9029/pause until=$(date -v+1M +%s)

  $(mise which hostile) remove x.com
  $(mise which hostile) remove www.x.com

  flush-dns

  osascript <<EOF
  tell application "Safari"
    log "Opening X"
    activate
    open location "https://x.com/logout"
  end tell

  tell application "System Events"
    tell process "Safari"
      delay 2
      log "Attempting to log out"
      click button "Log out" of group 1 of group 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1
      delay 1
    end tell
  end tell
EOF

  # separate script even if the first one fails
  osascript -e 'tell application "Safari" to if (URL of current tab of front window contains "x.com") then close current tab of front window'
}
