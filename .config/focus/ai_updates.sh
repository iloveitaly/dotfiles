#!/bin/zsh

# update all of the llms!
claude update
opencode upgrade
agy update
codex update
grok update
goose update
# muse updates automatically and has no build in update step

code --update-extensions
cursor --update-extensions

pnpx skills update -g