#!/bin/bash

# Manual Configuration Required:
#
#   - Alfred Configuration Backup. Sync to cloud storage.
#   - Google Chrome. Sync to user profile.
#   - 1Password. Support was never merged, sensitive application to muck with permissions. https://github.com/lra/mackup/pull/1080
#   - Dash. Save preferences and snippets in-app.
#   - SSH and GPG
#   - Enable location services
#   - Add '~/Projects' to Spotlight exclusion to avoid matching against node_modules
#   - Slack setup. Login under various emails.
#   - Discord
#   - Some zoom configuration doesn't copy over:
#       * General > use dual monitors
#       * General > Show meeting duration
#       * Video > Hide Self View
#       * Video > Always show participant name on the video
#       * Audio > Mute my mic when joining a meeting
#       * Show meeting duration
#       TODO explode out videos from the primary area
#   - Copy `jack` (texts) and raycast keychain items over to the new machine
#   - Enter GPG passphase. This should be prompted automatically when making a commit

mackup backup

# manually copy files to the new machine
pg_dumpall > ~/Desktop/postgres_backup
mysqldump -u root -p --all-databases > ~/Desktop/mysql_backup.sql
