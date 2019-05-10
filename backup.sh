#!/bin/bash

# Manual Configuration Required:
# 
#   - Alfred Configuration Backup. Sync to cloud storage.
#   - Google Chrome. Sync to user profile.
#   - 1Password. Support was never merged, sensitive application to muck with permissions. https://github.com/lra/mackup/pull/1080
#   - Dash. Save preferences and snippets in-app.
#   - SSH and GPG
#   - Enable location services

mackup backup

cp "$HOME/Library/Application Support/Code/User/settings.json" ./vscode-settings.json
code --list-extensions > ./vscode-extensions.txt

# manually copy files to the new machine
pg_dumpall > ~/Desktop/postgres_backup
mysqldump -u root -p --all-databases > ~/Desktop/mysql_backup.sql
