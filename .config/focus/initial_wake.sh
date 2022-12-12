#!/usr/bin/env zsh

apps=(Slack Discord Podcasts "Amazon Music" zoom.us ReadKit Texts Messages Gmail "System Settings" Music)
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

# when executed as part of a sleepwatcher, the environment is not set up
export HOME=/Users/mike
source $HOME/.asdf/asdf.sh

# cleanup browser tabs
echo "Cleaning browser tabs..."
cd ~/Projects/clean-workspace
poetry run clean-workspace "$dialogResult"

# organize todoist
echo "Organizing todoist..."
cd ~/Projects/todoist-scheduler
poetry run todoist-scheduler

