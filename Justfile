set shell := ["zsh", "-cu", "-o", "pipefail"]

# determines what shell to use for [script]
set script-interpreter := ["zsh", "-euBh", "-o", "pipefail"]

set unstable := true

upgrade:
	brew upgrade atuin awscli git rg fd gh zsh gmailctl dolt yazi dolt bat ov difftastic
	gh extension upgrade --all
	
	mise self-update
	mise upgrade
	ya pkg upgrade

	# this will update starship as well
	# zinit-update must have an interactive environment to run
	echo "Please run \`zinit update\` in an interactive shell to update zinit plugins like starship."

sync:
	fd --hidden --max-depth 4 -t f --exclude=.git | \
		entr rsync --exclude-from=install/standard-exclude.txt -av . ~

# what quicklook plugins are installed?
list-quicklook:
	qlmanage -m plugins

configure-launchagents:
	# tmux first
	# TODO link to blog post
	cp ./tmux.plist ~/Library/LaunchAgents/mikebianco.tmux.plist
	tmux kill-server
	launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/mikebianco.tmux.plist

	sudo cp ./pty.plist /Library/LaunchDaemons/mikebianco.pty.plist
	sudo launchctl bootstrap system /Library/LaunchDaemons/mikebianco.pty.plist

pull-ide-integration:
	cp ~/Library/Application\ Support/Code/User/{settings,keybindings}.json .vscode/
	cp ~/Library/Application\ Support/Cursor/User/{settings,keybindings}.json .cursor/

# vscode and cursor integration
patch-ide-integration:
	cp "$(code --locate-shell-integration-path zsh)" .vscode/zsh-integration-original.zsh
	patch -o .vscode/zsh-integration.zsh .vscode/zsh-integration-original.zsh .vscode/zsh-integration.patch

# Extract user and core.whitespace config to .gitconfig-agent, the default gitconfig assumes an interactive TUI, so we have a simplified config
# to avoid weird agent problems.
sync-gitconfig-agent:
		yq -p ini -o ini '{"user": .user, "core": {"whitespace": .core.whitespace}}' .gitconfig > .gitconfig-agent
		@echo "✓ .gitconfig-agent updated via yq"

# Export OrbStack Development Root CA so Python requests (and other tools)
# can verify *.orb.local HTTPS certificates.
#
# Why this is needed:
# - OrbStack only installs its root CA into the macOS user keychain.
# - Python's requests + certifi does not read the system/user keychain.
# - Without this, you get SSL certificate verification errors on *.orb.local.
#
# REQUESTS_CA_BUNDLE *replaces* certifi's defaults rather than adding to
# them, so pointing it at just the OrbStack cert would break every other
# HTTPS call. We export the OrbStack root and concatenate it with
# certifi's bundle to produce a single merged PEM.
#
# Re-run after upgrading certifi or if OrbStack rotates its root.
#
# Then in your shell rc or direnv:
#   export REQUESTS_CA_BUNDLE="$HOME/.orbstack/certs/bundle.pem"
#   export SSL_CERT_FILE="$HOME/.orbstack/certs/bundle.pem"

export-orbstack-ca:
    mkdir -p ~/.orbstack/certs
    security find-certificate -a -c "OrbStack Development Root CA" -p > ~/.orbstack/certs/ca.pem.tmp
    test -s ~/.orbstack/certs/ca.pem.tmp
    mv ~/.orbstack/certs/ca.pem.tmp ~/.orbstack/certs/ca.pem
    cat "$(python -m certifi)" ~/.orbstack/certs/ca.pem > ~/.orbstack/certs/bundle.pem.tmp
    mv ~/.orbstack/certs/bundle.pem.tmp ~/.orbstack/certs/bundle.pem