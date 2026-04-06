---
name: worx-doctor
description: "Worxphere environment health check - verify installation, MCP, and portal status"
triggers:
  - "doctor"
  - "health check"
  - "환경 검증"
  - "설치 확인"
allowed-tools: Bash, Read
---

# Worxphere Doctor

Comprehensive environment health check for Worxphere Claude Code setup.

**When this skill is invoked, immediately execute all checks below.**

## Check Execution

Run ALL checks in a single bash block for speed:

```bash
echo "=== Runtime ==="
echo "node: $(node --version 2>/dev/null || echo 'MISSING')"
echo "python3: $(python3 --version 2>/dev/null | awk '{print $2}' || echo 'MISSING')"
echo "git: $(git --version 2>/dev/null | awk '{print $3}' || echo 'MISSING')"
echo "uv: $(uv --version 2>/dev/null | awk '{print $2}' || echo 'MISSING')"

echo ""
echo "=== Plugins ==="
python3 -c "
import json, os
path = os.path.expanduser('~/.claude/plugins/installed_plugins.json')
try:
    d = json.load(open(path))
    plugins = d.get('plugins', {})
    omc = any(k.startswith('oh-my-claudecode@') for k in plugins)
    omx = any(k.startswith('oh-my-worxphere@') for k in plugins)
    print(f'omc: {\"INSTALLED\" if omc else \"MISSING\"}')
    print(f'omx: {\"INSTALLED\" if omx else \"MISSING\"}')
except:
    print('omc: UNKNOWN')
    print('omx: UNKNOWN')
"

echo ""
echo "=== MCP Servers ==="
python3 -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
try:
    d = json.load(open(path))
    servers = d.get('mcpServers', {})
    for name in ['slack', 'github', 'gitlab', 'notion', 'context7']:
        status = 'CONFIGURED' if name in servers else 'MISSING'
        print(f'{name}: {status}')
except:
    print('Cannot read settings.json')
"

echo ""
echo "=== Portal ==="
echo "glab: $(glab auth status 2>&1 | head -1 || echo 'NOT_CONFIGURED')"
echo "direnv: $(direnv --version 2>/dev/null || echo 'MISSING')"

echo ""
echo "=== Editors ==="
echo "vscode: $(code --version 2>/dev/null | head -1 || echo 'MISSING')"
echo "ghostty: $(ghostty --version 2>/dev/null || echo 'MISSING')"
echo "zed: $(zed --version 2>/dev/null || echo 'MISSING')"
```

## Result Formatting

Parse the output and present a formatted report:

### Required Items (must pass)

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | Node.js 18+ | ? | version or MISSING |
| 2 | Python 3.12+ | ? | version or MISSING |
| 3 | Git | ? | version or MISSING |
| 4 | omc plugin | ? | INSTALLED or MISSING |
| 5 | omx plugin | ? | INSTALLED or MISSING |
| 6 | Slack MCP | ? | CONFIGURED or MISSING |
| 7 | GitHub MCP | ? | CONFIGURED or MISSING |

### Recommended Items (should pass)

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 8 | uv | ? | version or MISSING |
| 9 | GitLab MCP | ? | CONFIGURED or MISSING |
| 10 | Notion MCP | ? | CONFIGURED or MISSING |
| 11 | Context7 MCP | ? | CONFIGURED or MISSING |
| 12 | glab auth | ? | status |
| 13 | direnv | ? | version or MISSING |
| 14 | VSCode | ? | version or MISSING |

### Status Icons

- Pass: `[OK]`
- Warning (recommended missing): `[WARN]`
- Fail (required missing): `[FAIL]`

### Score

Calculate and display:

```
Score: X/14 (Y%)
Required: A/7 passed
Recommended: B/7 passed
```

### Remediation

For each FAIL or WARN, suggest the fix command:

| Issue | Fix |
|-------|-----|
| Node.js missing | `curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh \| bash` |
| omc missing | `claude plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode && claude plugin install oh-my-claudecode@omc` |
| omx missing | `claude plugin marketplace add https://github.com/seokmogu/oh-my-worxphere && claude plugin install oh-my-worxphere@oh-my-worxphere` |
| Slack/GitHub MCP missing | `/worx-mcp-config` |
| GitLab/Notion/Context7 MCP missing | `/worx-mcp-config` |
| glab not configured | `/worx-portal` |
| direnv missing | `/worx-portal` |
