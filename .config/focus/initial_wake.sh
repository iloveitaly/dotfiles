#!/usr/bin/env zsh

# assume the script is executed without common environment variables
# additionally, since it's not executed in login mode, ~/.zshrc is not loaded
export USER=mike
export HOME=/Users/$USER
source ~/.asdf/asdf.sh

# do we have internet access?
if ! ping -c 1 google.com &> /dev/null; then
  echo "No internet access, waiting for 1 minute"
  sleep 60
fi

# if we don't have internet after this, some of the operations will will fail, which is completely fine

# stop caffinating so the computer actually falls back to sleep
/usr/bin/killall caffeinate

# close work related apps on sunday
work_apps=()
if [ $(date +%u) -eq 7 ]; then
  echo "It's sunday, closing additional apps"
  work_apps=(TablePlus "Visual Studio Code" Postico Kaleidoscope)
fi

apps=(
  $work_apps
  Slack Mattermost GitHub Rewind
  Dropbox "Google Drive"
  Discord ChatGPT Buffer
  Podcasts "Amazon Music" Spotify
  Dictionary Notes Preview Flow Streaks "QuickTime Player" Contacts
  zoom.us ReadKit Readwise Texts Messages Gmail "System Settings" Music Superhuman
  "Google Software Update" "Google Chrome Canary" "Firefox"
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

# prompt user for context on what's left in the browser tabs
dialogResult=$(
osascript <<EOT
set dialogResult to display dialog "What were you working on yesterday?" buttons {"OK"} default button "OK" giving up after 300 default answer ""
return text returned of dialogResult
EOT
)


# cleanup browser tabs
echo "Cleaning browser tabs..."
cd ~/Projects/productivity/clean-workspace
# sudo must come before direnv
sudo direnv exec . poetry run clean-workspace --tab-description "$dialogResult"

# organize todoist
echo "Organizing todoist..."
cd ~/Projects/productivity/todoist-scheduler
direnv exec . poetry run todoist-scheduler