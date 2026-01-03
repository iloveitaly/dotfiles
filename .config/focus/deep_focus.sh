#!/usr/bin/env zsh

function quit_apps() {
  for app in $@; do
    echo "Quitting $app..."

    osascript -e "with timeout of 30 seconds
    quit app \"$app\"
    end timeout"

    if [ $? -ne 0 ]; then
      # if the application did not quit on it's own, let's force it!
      killall "$app"
    fi
  done
}

function hide_apps() {
  for app in $@; do
    echo "Hiding $app..."

    osascript -e "tell application \"System Events\"
        set visible of application process \"$app\" to false
    end tell"
  done
}

quit_apps Slack Discord Podcasts zoom.us ReadKit Texts Messages Gmail "System Settings" Music Preview Todoist Cron
hide_apps "Amazon Music"
