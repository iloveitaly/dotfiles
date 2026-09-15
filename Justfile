set shell := ["zsh", "-cu", "-o", "pipefail"]

# determines what shell to use for [script]
set script-interpreter := ["zsh", "-euBh", "-o", "pipefail"]

set unstable := true

rsync_cmd := "rsync --exclude-from=install/standard-exclude.txt -av . ~"

upgrade:
	brew upgrade -y awscli git zsh gmailctl dolt hunk block-buzz yabai
	gh extension upgrade --all
	
	mise self-update -y
	mise upgrade -y
	mise prune -y
	ya pkg upgrade --discard
	XDG_CONFIG_HOME="{{justfile_directory()}}/.config" nvim --headless "+Lazy! update" +qa

	# this will update starship as well
	# zinit update has job-control/pager quirks in non-interactive subshells
	echo "Please run \`zinit update\` in an interactive shell to update zinit plugins like starship."

sync:
	if command -v entr &>/dev/null; then \
		fd --hidden --max-depth 4 -t f --exclude=.git | entr {{rsync_cmd}}; \
	else \
		echo "entr not found, running a one-shot sync instead" >&2; \
		{{rsync_cmd}}; \
	fi

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
# 
# https://github.com/orbstack/orbstack/issues/1159

export-orbstack-ca:
    mkdir -p ~/.orbstack/certs
    security find-certificate -a -c "OrbStack Development Root CA" -p > ~/.orbstack/certs/ca.pem.tmp
    test -s ~/.orbstack/certs/ca.pem.tmp
    mv ~/.orbstack/certs/ca.pem.tmp ~/.orbstack/certs/ca.pem
    cat "$(python -m certifi)" ~/.orbstack/certs/ca.pem > ~/.orbstack/certs/bundle.pem.tmp
    mv ~/.orbstack/certs/bundle.pem.tmp ~/.orbstack/certs/bundle.pem

# Drop package-manager / toolchain caches and project build junk older than 30d.
# Safe regenerable state only — not Docker (see clean-docker) and not full mise installs
# wipe (mise prune only removes unreferenced versions).
clean:
    npm cache clean --force
    pnpm store prune
    # `bun pm cache rm` requires a package.json; wipe the global install cache instead
    rm -rf "$HOME/.cache/.bun/install" "$HOME/.cache/.bun/bin"

    # Python
    uv cache clean
    pip cache purge

    # Go module + build caches
    go clean -cache -testcache -modcache

    # Toolchain managers
    mise cache prune
    mise prune
    brew cleanup --prune=all

# Reclaim Docker/OrbStack disk (dangling images, stopped containers, build cache,
# unused volumes). Prompts once; does not remove tagged in-use images (-a would).
clean-docker:
    docker system prune --volumes
    docker builder prune

# Configure Docker defaults: table psFormat on all OSes; log limits & containerd on macOS/OrbStack; log limits on Linux.
[script]
set-docker-config:
    # CLI client config: set compact `docker ps` column formatting across all OSes
    mkdir -p "$HOME/.docker"
    [[ -f "$HOME/.docker/config.json" ]] || echo '{}' > "$HOME/.docker/config.json"

    # simplify default ps format so it actually fits on the screen
    yq -i -o json '.psFormat = "table {{ "{{" }}.ID}}\t{{ "{{" }}.Image}}\t{{ "{{" }}.Names}}"' "$HOME/.docker/config.json"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS / OrbStack: cap log size and enable containerd snapshotter (required by Railpack / BuildKit)
        mkdir -p "$HOME/.orbstack/config"
        [[ -f "$HOME/.orbstack/config/docker.json" ]] || echo '{}' > "$HOME/.orbstack/config/docker.json"
        yq -i -o json '
            .log-driver = "json-file" |
            .log-opts.max-size = "10m" |
            .log-opts.max-file = "3" |
            .features."containerd-snapshotter" = true
        ' "$HOME/.orbstack/config/docker.json"

        # Register remote Docker hosts over SSH for multi-host CLI access
        for host in ${DOCKER_HOSTS:-}; do
            docker context create "$host" --docker "host=ssh://$host@$host.lan" 2>/dev/null || true
        done

        if command -v orb >/dev/null; then
            orb restart docker
        fi
    else
        # Linux: write daemon log caps to /etc/docker/daemon.json; pipe via user yq so sudo secure_path doesn't drop mise binaries
        sudo mkdir -p /etc/docker
        { sudo cat /etc/docker/daemon.json 2>/dev/null || echo '{}'; } | yq -o json '
            .log-driver = "json-file" |
            .log-opts.max-size = "10m" |
            .log-opts.max-file = "3"
        ' | sudo tee /etc/docker/daemon.json >/dev/null

        # Reload systemd Docker service if currently running to apply the new daemon configuration
        if command -v systemctl >/dev/null && systemctl is-active --quiet docker; then
            sudo systemctl reload docker 2>/dev/null || sudo systemctl restart docker 2>/dev/null || true
        fi
    fi
