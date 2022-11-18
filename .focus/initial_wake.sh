#!/usr/bin/env zsh

apps=(Slack Discord Podcasts "Amazon Music" zoom.us ReadKit Texts Gmail)
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

source `brew --prefix asdf`/asdf.sh

# cleanup browser tabs
cd ~/Projects/clean-workspace
poetry run python ./archive.py "$dialogResult"

# organize todoist
cd ~/Projects/todoist-scheduler
poetry run python cli.py

