#!/usr/bin/env zsh

# you'll need to run this as root to modify the /etc/hosts file
# test with `sudo env -i wake.sh`

export HOME=/Users/mike
export PATH="$HOME/.local/bin:/sbin:/usr/sbin:/opt/homebrew/bin:$PATH"

source ~/.config/focus/functions.sh

$(mise which hostile) load ~/.config/distracting_sites.txt

flush-dns
