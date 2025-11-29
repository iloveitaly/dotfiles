#!/bin/bash

# This script acts as a wrapper for the git pager.
# It detects if git is being run by an AI agent (like Gemini, Cursor, or VS Code's agent)
# or a human user.
# - If an agent is detected, it pipes output to `cat` to avoid blocking.
# - If a human is detected, it uses the configured interactive pager (diff-so-fancy | ov).

# Agent detection logic
IS_AGENT=0

# Check specifically for VS Code agent
if [[ "${TERM_PROGRAM:-}" == "vscode" && "${VSCODE_AGENT:-}" == "1" ]]; then
  IS_AGENT=1
# Check for dumb terminal
elif [[ "${TERM:-}" == "dumb" ]]; then
  IS_AGENT=1
# Check for other known agents
elif [[ -n "${CURSOR_AGENT:-}" || "${CLAUDECODE:-}" == "1" || "${GEMINI_CLI:-}" == "1" ]]; then
  IS_AGENT=1
fi

if [[ "$IS_AGENT" == "1" ]]; then
  # AI Agent: Use cat to avoid blocking/paging
  cat
else
  # Human: Use the interactive pager
  diff-so-fancy | ov --section-delimiter '^(Date|added|deleted|modified): '
fi
