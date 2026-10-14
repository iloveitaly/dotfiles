# mise can read gh's hosts.yml itself; bridge only when it still has no token
# (typical on macOS when gh keeps the token in the keyring).

if (( $+commands[mise] )) && mise token github --raw &>/dev/null; then
  return
fi

if (( ! $+commands[gh] )); then
  return
fi

local github_auth_token
github_auth_token=$(gh auth token 2>/dev/null)

if [[ -n "$github_auth_token" ]]; then
  export MISE_GITHUB_TOKEN="$github_auth_token"
  export GITHUB_MCP_PAT="$github_auth_token"
else
  echo "Warning: GitHub authentication token not found." >&2
fi
