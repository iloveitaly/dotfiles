#!/usr/bin/env zsh
# Description: exclude node_modules and other noisy directories from time machine

static_exclusions=(
  "~/.cache/whisper"
  "~/.ollama"
  "~/.orbstack"
  "~/.docker"
  "~/.asdf"
  "~/.Trash"
  "~/.cache"

  /var/lib/docker
  /OrbStack
  "~/OrbStack/"
)

# https://apple.stackexchange.com/questions/384455/how-to-ignore-all-the-node-modules-folders-from-time-machine

# exclude the above folders
for exclusion in $static_exclusions; do
  echo "Excluding $exclusion from time machine..."
  sudo tmutil addexclusion -p $exclusion
done

pushd ~/Projects

fd -uuu --type d --absolute-path --full-path 'node_modules$' |
  rg --max-columns=0 --pcre2 '^(?!.*\/node_modules\/.*\/node_modules\/).*\/node_modules\/$' --no-filename --no-column --no-line-number --color never |
  while read line; do
    echo "Excluding '$line' from time machine..."
    sudo tmutil addexclusion -p $line
  done

fd -uuu --color never --type d --absolute-path --full-path '(\.venv|\.pnpm|vendor/bundle|target/aarch64-apple-darwin|target/debug|target/release|.elixir_ls)$' ~ | while read line; do
  echo "Excluding '$line' from time machine..."
  sudo tmutil addexclusion -p $line
done

popd
