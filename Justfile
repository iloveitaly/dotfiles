set shell := ["zsh", "-cu", "-o", "pipefail"]

# determines what shell to use for [script]
set script-interpreter := ["zsh", "-euBh", "-o", "pipefail"]

set unstable := true

upgrade:
	brew upgrade fzf atuin awscli git rg fd gh zsh nano gmailctl dolt 1password-cli yazi dolt bat ov

	gh extension upgrade --all

	eget --tag nightly zyedidia/micro --to=~/.local/bin/

	# TODO can't figure out why this is not working
	# this will update starship as well
	# zsh -cl "zinit-update"

sync:
	fd --hidden --max-depth 4 -t f --exclude=.git | entr rsync --exclude-from=install/standard-exclude.txt -av . ~

# what quicklook plugins are installed?
list-quicklook:
	qlmanage -m plugins