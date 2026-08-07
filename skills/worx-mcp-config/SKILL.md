---
name: worx-mcp-config
description: "Slack, official Hosted Notion, GitHub, and GitLab MCP configuration using claude mcp add CLI"
level: 2
---

# Worxphere MCP Auto-Configuration

Configure MCP servers for Worxphere employees using the `claude mcp add` CLI.

**When this skill is invoked, immediately execute the workflow below.**

## Step 1: Check Current MCP Configuration

Scan existing MCP servers:

```bash
claude mcp list 2>/dev/null || echo "NO_MCP_LIST_SUPPORT"
```

Fallback: read settings directly:
```bash
cat ~/.claude/settings.json 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    servers = d.get('mcpServers', {})
    if not servers:
        print('No MCP servers configured')
    for name in servers:
        print(f'  {name}: configured')
except:
    print('Cannot read settings')
"
```

## Step 2: Present Status

Show current status table:

| MCP Server | Status | Required |
|-----------|--------|----------|
| Slack     | ?      | Required |
| GitHub    | ?      | Required |
| Notion    | ?      | Recommended |
| GitLab (internal) | ? | Recommended |
| Context7  | ?      | Recommended |

## Step 3: Ask Which to Configure

Use AskUserQuestion:

**Question:** "Which MCP servers to configure?"

**Options:**
1. **All missing (recommended)** - Configure all unconfigured servers
2. **Required only** - Slack + GitHub only
3. **Select individually** - Choose specific servers

## Step 4: Configure Selected Servers

### Context7 (no key required)

```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

### Slack

Requires: Bot Token + Team ID

Guide the user:
> Slack Bot Token 발급 방법:
> 1. https://api.slack.com/apps 접속
> 2. "Create New App" > "From scratch"
> 3. 워크스페이스 선택 후 앱 생성
> 4. "OAuth & Permissions"에서 Bot Token Scopes 추가:
>    - channels:history, channels:read, chat:write, users:read
> 5. "Install to Workspace" 후 Bot User OAuth Token (xoxb-...) 복사
>
> Team ID 확인: Slack 앱 하단 워크스페이스 이름 클릭

After user provides token and team ID:

```bash
claude mcp add -e SLACK_BOT_TOKEN=<token> -e SLACK_TEAM_ID=<team_id> slack -- npx -y @anthropic-ai/claude-code-slack-mcp
```

### GitHub

Requires: Personal Access Token

Guide the user:
> GitHub Token 발급:
> 1. https://github.com/settings/tokens > "Generate new token (classic)"
> 2. Scopes: repo, read:org
> 3. Token 복사 (ghp_...)

```bash
claude mcp add -e GITHUB_TOKEN=<token> github -- npx -y @anthropic-ai/claude-code-github-mcp
```

### Notion

Use Notion's official hosted remote MCP. Do not ask for an integration token and do not install a local npm Notion MCP server.

```bash
claude mcp add --transport http --scope user notion https://mcp.notion.com/mcp
```

Complete the OAuth connection in Claude Code when prompted. This MCP is the interactive search/fetch/narrow-edit surface. Markdown batch deployment is not part of this onboarding skill and follows `/Users/seokmogu/project/NOTION_PUBLISHING.md`.

### GitLab (Internal - <INTERNAL_GITLAB>)

Requires: Personal Access Token

Guide the user:
> 사내 GitLab Token 발급:
> 1. https://<INTERNAL_GITLAB>/-/user_settings/personal_access_tokens
> 2. Scopes: api, read_repository, write_repository
> 3. Token 복사

```bash
claude mcp add -e GITLAB_TOKEN=<token> -e GITLAB_URL=https://<INTERNAL_GITLAB> gitlab -- npx -y @anthropic-ai/claude-code-gitlab-mcp
```

## Step 5: Verify

```bash
claude mcp list 2>/dev/null
```

Tell the user:
> MCP 설정 완료. Claude Code를 재시작하면 적용됩니다.
> 재시작: Ctrl+C 후 `claude` 다시 실행

Show final summary table with configured/skipped status for each server.
