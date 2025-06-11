#!/usr/bin/env zsh

# test with `❯ sudo env -i .config/focus/initial_wake.sh`

# assume the script is executed without common environment variables
# additionally, since it's not executed in login mode, ~/.zshrc is not loaded
export USER=mike
export HOME=/Users/$USER

# add `mise` bin to path
export PATH="$HOME/.local/bin:/sbin:/usr/sbin:/opt/homebrew/bin:$PATH"

# for macos-logout, and other functions
source ~/.functions

# for api keys
source ~/.extra

source ~/.config/focus/functions.sh
source ~/.config/focus/twitter_logout.sh

unthrottle-internet

# do we have internet access?
if ! ping -c 1 google.com &>/dev/null; then
  echo "No internet access, waiting for 1 minute"
  sleep 120
fi

# if we don't have internet after this, some of the operations will will fail, which is completely fine

work_apps=()

# close work related apps on sunday
if [ $(date +%u) -eq 7 ]; then
  # TODO maybe turn on DND too? via raycast status?

  # wait for 5 minutes to download some stuff, give the user time to clean up, etc
  osascript -e 'display notification "Sunday Cleanup! 30m Until Shutdown" with title "Focus"'

  # the most we can wait is 10m
  # https://github.com/iloveitaly/hyper-focus/blob/0d23d022a3bd2fe914c38ff859275d845dd71d52/Sources/hyper-focus/taskrunner.swift#L13
  sleep 500

  # TODO we can use the DND raycast script here

  echo "It's sunday, closing additional apps..."
  work_apps=(TablePlus "Visual Studio Code" Zui)

  # can we cause pause arq as well?

  echo "Now, throttle the internet, since it's sunday"
  throttle-internet
fi

apps=(
  $work_apps
  Slack GitHub
  Dropbox "Dropbox Capture" "Google Drive" Numbers Stocks SoundPaste
  Discord Buffer Signal Telegram
  Podcasts "Amazon Music" Spotify
  Dictionary Notes Preview "QuickTime Player" Contacts
  zoom.us Reader Texts Gmail "System Settings" Music Superhuman
  "Google Software Update" "Google Chrome Canary" "Firefox"
  "Activity Monitor" "System Preferences" "App Store" "Disk Utility" "System Information" Console "Find My"
)

# TODO WebCatalog SSB don't like this method of quitting
quit_app() {
  local app=$1

  echo "Quitting $app..."

  osascript -e "with timeout of 30 seconds
  quit app \"$app\"
  end timeout"

  if [ $? -ne 0 ]; then
    # if the application did not quit on it's own, let's force it!
    killall "$app"
  fi

  # TODO check if the application is still running and try the kill approach
}

for app in $apps; do
  quit_app $app
done

twitter_logout

# prompt user for context on what's left in the browser tabs
dialogResult=$(
  osascript <<EOT
set dialogResult to display dialog "What were you working on yesterday?" buttons {"OK"} default button "OK" giving up after 300 default answer ""
return text returned of dialogResult
EOT
)

# cleanup browser tabs
echo "Cleaning browser tabs..."
$(mise which clean-workspace) --tab-description "$dialogResult"

# TODO the script below is not properly running as root

# must run as non-root user!
# su - mike -c "~/.time-machine-includes.sh"

# it seems to get junked up after a while and slow down
# a daily restart keeps it operating quickly
echo "Restarting Raycast..."
quit_app "Raycast"
while pgrep -q -x "Raycast"; do sleep 0.1; done
open -a "Raycast"
