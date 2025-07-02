#!/usr/bin/env zsh

# you'll need to run this as root to modify the /etc/hosts file
# test with `sudo env -i wake.sh` which replicates a `sudo` hyper-focus execution

export HOME=/Users/mike
export PATH="$HOME/.local/bin:/sbin:/usr/sbin:/opt/homebrew/bin:$PATH"

$(mise which hostile) load ~/.config/distracting_sites.txt

source ~/.config/focus/functions.sh
flush-dns
