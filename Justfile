set shell := ["zsh", "-cu", "-o", "pipefail"]

# determines what shell to use for [script]
set script-interpreter := ["zsh", "-euBh", "-o", "pipefail"]

set unstable := true

upgrade:
	brew upgrade fzf atuin nixpacks awscli git rg fd gh zsh nano
	gh extension upgrade --all
	
	# TODO can't figure out why this is not working
	# zsh -cl "zinit-update"

sync:
	fd --hidden --max-depth 4 -t f --exclude=.git | entr rsync --exclude-from=install/standard-exclude.txt -av . ~

# what quicklook plugins are installed?
list-quicklook:
	qlmanage -m plugins