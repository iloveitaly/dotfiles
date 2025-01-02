# A subset of packages that are safe to install on both macos and linux and documented in this Brewfile
# the goal is to provide a common of set of utilities that can be installed on a macos or linux (codespace) machine

tap 'homebrew/bundle'

# == General Utilities
brew "git"
brew "vim"
brew "lynx"
brew "rename"
brew "wget"
brew "ngrep" # network grep
brew "optipng"
brew "iftop" # network top
brew "trippy" # traceroute
brew "lftp"
brew "iproute2mac"
# required fix for me: https://github.com/httpie/cli/issues/1535#issuecomment-1773774369
brew "httpie"
brew "ncdu"
brew "curl"
brew "awk" # in codespaces, the default version is especially strange
brew "awscli"
brew "aws-sam-cli"
brew "session-manager-plugin" if OS.mac?
brew "cloc" # code analytics
brew "jq" # json extraction
brew "hey"
brew "gh"
brew "sqlite"
brew "md5sha1sum"
brew "git-lfs"
brew "vimcal"
brew "caddy"
brew "yazi"
brew "fx" # json tui
brew "setapp"
brew "gitx" # visual git tool, kaleidoscope alternative
brew "kdiff3"

# == Data manipulation
brew "q" if OS.mac? # sql on csv
brew "dsq" # sql over json and other formats
brew "yq" # yq for yaml and others, great for in place manipulating files
brew "dasel" # consistent language for extracting data from XML, CSV, and others. No aggregates.
tap "brimdata/tap"
brew "brimdata/tap/zq" # faster/better jq, has aggregates
brew "htmlq"
brew "xsv" # csv tooling
brew "tabiew" # tui for csv and data viewing

# == Shell productivity utilities
brew "zsh"
brew "ripgrep"
brew "entr"
brew "prettyping"
brew "less"
brew "nano"
brew "fd" # find
brew "yank"
brew "tldr"
brew "zoxide"
brew "fzf"
brew "bc" # used by git-fuzzy
brew "diff-so-fancy" # diff replacement
brew "git-delta" # diff replacement
brew "bat" # cat, can also do paging
brew "eza" # ls
brew "hck" # cut
brew "tre-command"
brew "htop"
brew "procs" # ps
brew "sd" # sed
brew "svn" # for `zinit ice svn`
brew "dog" # dig replacement
brew "moreutils" # sponge
brew "xplr" # file management
brew "dust" # du replacement, another option is duf
brew "qpdf" # for decrypting pdf files
brew "rsync" # get the latest version for new features
brew "watch" # execute program every X seconds
brew "docker-completion" if OS.linux?
brew "shellcheck" # for vscode bash ide
brew "iotop"

# == tmux related tools
brew "tmux"
brew "reattach-to-user-namespace" if OS.mac?
brew "urlview"
brew "terminal-notifier" if OS.mac? # for `zsh-notify`

# == Experimental (don't install on server)
if OS.mac?
    tap "afnanenayet/tap"
    brew "afnanenayet/tap/diffsitter"
    tap "noahgorstein/tap"
    brew "noahgorstein/tap/jqp"
    brew "act"
    brew "trunk-io"
    brew "pstree" # procs seem to have a tree view and is a bit better
    brew "broot" # better file finding
    brew "dolt"
    brew "noborus/tap/ov" # pager replacement
    brew "lnav" # log viewer, partial pager replacement
    brew "ollama"
    brew "llm"
    brew "buildpacks/tap/pack"
    brew "dive" # docker inspection
    brew "pgcli" # better psql, with autocompletion and DATABASE_URL connection support
    brew "kitty" # yet another terminal
    brew "gmailctl" # gmail filter configuration as code
    brew "cleanshot" # best email tool, not sure if it's better than dropbox capture
    tap "heroku/brew"
    brew "heroku/brew/heroku"
    tap "railwayapp/railway"
    brew "railway"
    brew "google-cloud-sdk" # cli tools for google cloud
    brew "azure-cli"
    brew "certbot"
end

if OS.mac?
    tap 'homebrew/cask'
    tap "homebrew/cask-drivers"
    tap 'homebrew/cask-fonts'
    tap 'homebrew/cask-versions'

    brew "lunchy"
    brew "yt-dlp"
    brew "gpg"
    brew "pinentry-mac"
    brew "iloveitaly/tap/hyper-focus"

    cask "another-redis-desktop-manager"
    cask "todoist"
    cask "grammarly-desktop"
    cask "spotify"
    cask "bartender"
    cask "microsoft-teams"
    cask "arctype"
    cask "arc"
    cask "signal"
    cask "google-chrome"
    cask "dropbox"
    cask "1password"
    cask "1password-cli"
    cask "google-drive"
    cask "iterm2"
    # cask "slack"
    cask "slack-beta"
    # does not support silicon installation yet
    system "arch -x86_64 brew install amazon-music"
    cask "amazon-photos"
    cask "homebrew/cask-versions/soulver2"
    cask "kap"
    cask "stay"
    cask "homebrew/cask-versions/kaleidoscope2"
    cask "skype"
    cask "postgres-unofficial"
    cask "rectangle"
    cask "valentina-studio"
    cask "libreoffice"
    cask "onyx"
    cask "cyberduck"
    cask "dash"
    cask "skyfonts"
    cask "base"
    cask "colorpicker-skalacolor"
    cask "homebrew/cask-versions/arq5"
    cask "messenger"
    cask "scrivener"
    cask "postico"
    cask "wordpresscom"
    cask "gimp"
    cask "grammarly"
    cask "launchcontrol"
    cask "hyper"
    cask "raycast"
    cask "google-chrome-canary"
    cask "zoom"
    cask "the-unarchiver"
    cask "sketch"
    # cask "disk-sensei"
    cask "paw"
    cask "safari-technology-preview"
    cask "openrefine"
    cask "lepton"
    cask "muzzle"
    # cask "https://raw.githubusercontent.com/Homebrew/homebrew-cask/00a37cb6ea00ca2820652b75ebd1f57ba160c3e5/Casks/screenflow.rb"
    cask "visual-studio-code"
    cask "visual-studio-code-insiders"
    cask "cloudapp"
    cask "chromedriver"
    # you must open up the docker macos app in order to symlink docker cli
    cask "docker"
    cask "monitorcontrol"
    cask "activitywatch"
    cask "discord"
    cask "keybase"
    cask "telegram"
    cask "alacritty", args: { no_quarantine: true }
    # helpful for phone-only applications that you want to run your mac without apple silicon
    cask "bluestacks"
    cask "cron"
    cask "obsidian"
    cask "calibre"
    cask "shortcutdetective"
    cask "logitech-options"
    cask "karabiner-elements"
    cask "insomnia"
    cask "mysteriumvpn"
    cask "stats"
    cask "vnc-viewer"
    cask "dropbox-capture"
    cask "loom"
    cask "ngrok"
    cask "firefox" # for debugging, not actual use

    # == Experimental
    cask "appcleaner"
    cask "fig"
    cask "tip"
    cask "krisp"
    cask "webcatalog"
    cask "warp"
    cask "wireshark"
    cask "cheatsheet"
    cask "rocket"
    cask "figma"
    cask "tableplus"
    cask "openrefine", { args: { no_quarantine: true } }
    cask "keycastr"

    # == Quicklook Plugins
    # These need to be manually enabled in macos preferences
    #   - https://github.com/sindresorhus/quick-look-plugins
    #   - https://github.com/haokaiyang/Mac-QuickLook
    cask "qlmarkdown", args: { no_quarantine: true }
    cask "qlimagesize"
    cask "mdimagesizemdimporter"
    cask "iloveitaly/tap/qlzipinfo"
    # remove the cached file if you run into weird rendering issues
    cask "syntax-highlight", args: { no_quarantine: true }
    cask "webpquicklook"
    cask "apparency"
    # TODO peek paid quicklook

    # == Fonts
    cask "font-source-code-pro"
    cask "font-hack"
    cask "font-roboto-mono-nerd-font"

    # == MacOS-only Shell Tooling
    # some of these tools are strictly terminal related, but do not play well with linux/codespaces
    brew "wp-cli", args: ["ignore-dependencies"]
    brew "ffmpeg" # mainly for gif generation
    brew "gifsicle"
    brew "mackup"
    brew "duti"
    brew "spoof-mac"
    brew "keith/formulae/zap"
    brew "mas"
    brew "webkit2png"
    brew "rga"
    brew "cmake" # for ruby native extensions
    brew "make" # to get the latest version (4.x vs 3.x)
    brew "gnu-time" # much better than shell time builtin for performance tracking
    brew "java" # for elixir
    brew "wxwidgets" # for elixir
    # helpful dependencies for rga
    %w(pandoc poppler tesseract ffmpeg).map {|p| brew p}
    brew "saulpw/vd/visidata"
    # php-related packages for asdf install
    %w(re2c bison bzip2 freetype gettext libiconv icu4c jpeg libedit libpng libxml2 libzip openssl readline webp zlib gmp libsodium imagemagick).map { |p| brew p }

    # == Experimental
    brew "siege" # load testing tool
    brew "ameshkov/tap/dnslookup"
    brew "smudge/smudge/nightlight"
    brew "hyperfine"
    # homerow

    # == Mac App store

    # personal account
    mas "Streaks", id: 963034692
    mas "Flow", id: 1423210932
    mas "Harvest", id: 506189836
    mas "Free Ruler", id: 1483172210
    mas "Tailscale", id: 1475387142
    mas "Flighty" id: 1358823008
    # shareful
    # quicklook plugin


    # xcode kept reinstalling for me, adding a extra gate here
    if !File.directory?("/Applications/Xcode.app")
        mas "Xcode", id: 497799835
        system "sudo xcodebuild -license accept"
    else
        puts "Xcode already installed, skipping"
    end

    mas "AudioWrangler", id: 1565701763
    mas "Streaks", id: 963034692
    mas "EasyRes", id: 688211836
    # TODO kindle
    # TODO these are ios apps which do not seem to install well
    # mas "blink-home-monitor", id: 1013961111
    # mas "wyze-make-your-home-smarter", id: 1288415553
    # TODO Owlet, is there a way to force this to install?
    # TODO wireguard

    # on business account
    mas "Icon Slate", id: 439697913
    mas "Mactracker", id: 430255202
    mas "Trello", id: 1278508951
    mas "Medis - GUI for Redis", id: 1063631769
    mas "Drop - Color Picker", id: 1173932628
    mas "Pixelmator Classic", id: 407963104
    mas "Toolbox for Pages", id: 571654652
end
