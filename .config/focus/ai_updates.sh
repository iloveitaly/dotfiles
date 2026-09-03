#!/bin/zsh

# update all of the llms!
claude update
opencode upgrade
agy update
codex update
grok update
goose update

code --update-extensions
cursor --update-extensions
