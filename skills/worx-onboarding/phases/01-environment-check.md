# Phase 1: Environment Check

Scan the user's environment and report status.

## Execute

```bash
echo "=== OS ==="
uname -s
sw_vers 2>/dev/null || cat /etc/os-release 2>/dev/null | head -3

echo "=== Shell ==="
echo "$SHELL"

echo "=== Core Tools ==="
echo "node: $(node --version 2>/dev/null || echo 'MISSING')"
echo "npm: $(npm --version 2>/dev/null || echo 'MISSING')"
echo "git: $(git --version 2>/dev/null || echo 'MISSING')"
echo "python3: $(python3 --version 2>/dev/null || echo 'MISSING')"
echo "brew: $(brew --version 2>/dev/null | head -1 || echo 'MISSING')"

echo "=== Dev Tools ==="
echo "glab: $(glab --version 2>/dev/null || echo 'MISSING')"
echo "direnv: $(direnv --version 2>/dev/null || echo 'MISSING')"
echo "uv: $(uv --version 2>/dev/null || echo 'MISSING')"

echo "=== Claude Code ==="
echo "claude: $(claude --version 2>/dev/null || echo 'MISSING')"
```

## Report

Show a table:

| Category | Tool | Version | Status |
|----------|------|---------|--------|
| Core | Node.js | ? | ? |
| Core | npm | ? | ? |
| Core | Git | ? | ? |
| Core | Python 3 | ? | ? |
| Dev | glab | ? | ? |
| Dev | direnv | ? | ? |
| Dev | uv | ? | ? |

If any Core tools are MISSING, warn the user:
> 필수 도구가 누락되었습니다. 설치 스크립트를 실행하세요:
> ```
> curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh | bash
> ```

If all Core tools are present, proceed to Phase 2.
