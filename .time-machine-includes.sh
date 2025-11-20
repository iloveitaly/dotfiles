#!/usr/bin/env zsh
# Description: exclude node_modules and other noisy directories from time machine

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" 1>&2
  exit 1
fi

# TODO make sure home is not the root user

# clear out any existing exclusions:
# sudo defaults write /Library/Preferences/com.apple.TimeMachine.plist SkipPaths -array

static_exclusions=(
  "$HOME/.cache/whisper"
  "$HOME/.ollama"
  "$HOME/.orbstack"
  "$HOME/.docker"
  "$HOME/.asdf"
  "$HOME/.Trash"
  "$HOME/.cache"
  "$HOME/.npm"
  "$HOME/.pnpm-state"
  "$HOME/.vscode/extensions"
  "$HOME/.cursor/extensions"
  "$HOME/Library/Caches/mix"
  "$HOME/Library/Caches/Yarn"
  "$HOME/Library/Application Support/superwhisper"

  /Library/Developer

  "$HOME/OrbStack"
)

# https://apple.stackexchange.com/questions/384455/how-to-ignore-all-the-node-modules-folders-from-time-machine

# Replace $HOME with an empty string, since fdfind does *not* treat --exclude as an absolute path
# https://github.com/sharkdp/fd/issues/1577
expanded_exclusions=("${(@)static_exclusions/#$HOME\//}")

# Prefix each exclusion pattern with --exclude= for use in fdfind
prefixed_exclusions=("${(@)expanded_exclusions/#/--exclude=}")

# exclude the above folders
for exclusion in $static_exclusions; do
  # check to ensure the file path is still valid
  if [[ ! -d $exclusion ]]; then
    echo "Invalid path: $exclusion"
    continue
  fi

  echo "Excluding $exclusion from time machine..."
  sudo tmutil addexclusion -p $exclusion
done

pushd ~/Projects

echo "\nExcluding node_modules from time machine..."
fd -uuu --type d --absolute-path --full-path 'node_modules$' \
  $prefixed_exclusions \
  $HOME | rg --max-columns=0 --pcre2 '^(?!.*\/node_modules\/.*\/node_modules\/).*\/node_modules\/$' --no-filename --no-column --no-line-number --color never |
  while read line; do
    echo "Excluding '$line' from time machine..."
    sudo tmutil addexclusion -p $line
  done

echo "\nExcluding other package management directories from time machine..."
fd -uuu --color never --type d --absolute-path --full-path '(\.venv|\.pnpm|vendor/bundle|target/aarch64-apple-darwin|target/debug|target/release|.elixir_ls)$' \
  $prefixed_exclusions \
  $HOME | while read line; do
  echo "Excluding '$line' from time machine..."
  sudo tmutil addexclusion -p $line
done

echo "Time machine excludes are done"

popd
