set shell := ["zsh", "-cu", "-o", "pipefail"]

# determines what shell to use for [script]
set script-interpreter := ["zsh", "-euBh", "-o", "pipefail"]

set unstable := true

upgrade:
	brew upgrade fzf atuin awscli git rg fd gh zsh gmailctl dolt 1password-cli yazi dolt bat ov
	gh extension upgrade --all

	# TODO can't figure out why this is not working
	# this will update starship as well
	# zsh -cl "zinit-update"

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