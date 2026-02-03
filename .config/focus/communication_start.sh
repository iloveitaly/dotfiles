#!/usr/bin/env zsh

# HOME is required for asdf to properly source versions
export HOME=/Users/mike
source ~/.asdf/asdf.sh

osascript -e 'display notification "Daily Communications" with title "Focus"'

# pause amazon music
# osascript << EOF
# if application "Amazon Music" is running then
#     tell application "System Events"
#         tell process "Dock"
#             tell list 1
#                 tell UI element "Amazon Music"
#                     perform action "AXShowMenu"
#                     delay 1
#                     tell menu 1
#                         if exists menu item "Play" then
#                             click menu item "Play"
#                         else
#                             perform action "AXCancel"
#                         end if
#                     end tell
#                 end tell
#             end tell
#         end tell
#     end tell
# end if
# EOF

# osascript << EOF
# tell application "QuickTime Player"
# 	activate
# 	set breakSong to open POSIX file "/Users/mike/Dropbox/break.mp3"
# 	play breakSong
# end tell

# set volume output volume 60
# EOF
