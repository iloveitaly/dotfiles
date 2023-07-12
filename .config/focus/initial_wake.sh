#!/usr/bin/env zsh

# assume the script is executed without common environment variables
# additionally, since it's not executed in login mode, ~/.zshrc is not loaded
export USER=mike
export HOME=/Users/$USER
source ~/.asdf/asdf.sh

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
  Slack Mattermost GitHub
  Discord
  Podcasts "Amazon Music" Spotify
  Dictionary Notes
  zoom.us ReadKit Readwise Texts Messages Gmail "System Settings" Music
)

for app in $apps; do
  echo "Quitting $app..."

  osascript -e "with timeout of 30 seconds
  quit app \"$app\"
  end timeout"

  if [ $? -ne 0 ]; then
    # if the application did not quit on it's own, let's force it!
    killall "$app"
  fi
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
cd ~/Projects/clean-workspace
sudo poetry run clean-workspace --tab-description "$dialogResult"

# organize todoist
echo "Organizing todoist..."
cd ~/Projects/todoist-scheduler
poetry run todoist-scheduler

