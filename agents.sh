#!/bin/bash

####################
# AI Configuration #
####################

# playwright-style browser automation
uv tool install 'camoufox[gui,geoip]'

# all of the cli coding tools
bun install -g @github/copilot@latest
bun add -g opencode-ai
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
# macOS: brew install codex (Brewfile); Linux: standalone installer
[[ "$(uname -s)" != "Darwin" ]] && curl -fsSL https://chatgpt.com/codex/install.sh | sh
curl -fsSL https://x.ai/cli/install.sh | bash
curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash
curl -fsSL https://dev.meta.ai/install.sh | bash

pnpm approve-builds -g

# Antigravity global skills directory bridge
mkdir -p ~/.gemini/config/skills ~/.gemini/antigravity-cli ~/.gemini/antigravity
ln -sfn ~/.gemini/config/skills ~/.gemini/antigravity-cli/skills
ln -sfn ~/.gemini/config/skills ~/.gemini/antigravity/skills
echo "{\"entries\":[{\"path\":\"$HOME/.agents/skills\"}]}" > ~/.gemini/config/skills.json

SKILLS_AGENTS=(claude-code cursor codex opencode github-copilot gemini-cli antigravity-cli antigravity)

pnpx skills@latest add ast-grep/agent-skill -g --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add https://github.com/iloveitaly/ai-skills -g --skill '*' --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add blader/humanizer -g --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add https://github.com/railwayapp/railway-skills -g --skill railway-docs --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add https://github.com/github/awesome-copilot -g --skill gh-cli --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add github/gh-stack -g --agent "${SKILLS_AGENTS[@]}" -y
pnpm dlx skills add shadcn/ui -g --agent "${SKILLS_AGENTS[@]}" -y
pnpx skills add https://github.com/anthropics/claude-plugins-official -g --skill skill-creator --agent "${SKILLS_AGENTS[@]}" -y

# we want to be careful about mcps and only globally install (a) what is not included by default and (b) what is geniunely globally useful 
# claude doesn't support dynamic ENV vars?
claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $(gh auth token)"
claude mcp add --transport http grep https://mcp.grep.app

codex mcp add github --url https://api.githubcopilot.com/mcp --bearer-token-env-var GITHUB_TOKEN
codex mcp add chrome-devtools -- pnpx -y chrome-devtools-mcp@latest
codex mcp add grep --url https://mcp.grep.app

pnpx ~/Projects/javascript/mcp-add --name chrome-mcp --command "pnpx -y chrome-devtools-mcp@latest" --type studio --scope global --clients antigravity
pnpx ~/Projects/javascript/mcp-add --name grep --url https://mcp.grep.app --type http --scope global --clients antigravity

# cursor-agent has it's own browser

mcp-add --name grep --type http --url https://mcp.grep.app --scope global --clients opencode,codex,claude,cursor

