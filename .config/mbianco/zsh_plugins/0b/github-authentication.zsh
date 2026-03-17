local github_auth_token=$(gh auth token 2>/dev/null)

if [[ -n "$github_auth_token" ]]; then
  export MISE_GITHUB_TOKEN="$github_auth_token"
  export GITHUB_MCP_PAT="$github_auth_token"
else
  # log warning
  echo "Warning: GitHub authentication token not found." >&2
fi