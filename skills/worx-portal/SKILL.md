---
name: worx-portal
description: "Internal GitLab CLI, direnv, and corporate service integration setup"
level: 2
---

# Worxphere Internal Portal Integration

Configure connections to Worxphere internal services.

**When this skill is invoked, immediately execute the workflow below.**

## Step 1: Environment Scan

```bash
echo "=== Tool Status ==="
echo "glab: $(glab --version 2>/dev/null || echo 'NOT_INSTALLED')"
echo "direnv: $(direnv --version 2>/dev/null || echo 'NOT_INSTALLED')"
echo "brew: $(brew --version 2>/dev/null | head -1 || echo 'NOT_INSTALLED')"

echo ""
echo "=== GitLab Auth ==="
glab auth status 2>&1 | head -5 || echo "NOT_CONFIGURED"

echo ""
echo "=== Shell Config ==="
grep -l "direnv hook" ~/.zshrc ~/.bashrc 2>/dev/null || echo "direnv hook: NOT_FOUND"

echo ""
echo "=== Git Remotes ==="
git remote -v 2>/dev/null | grep jobkorea || echo "No internal remote"
```

## Step 2: Present Status

| Service | Status | Action |
|---------|--------|--------|
| glab CLI | ? | brew install glab |
| GitLab auth | ? | glab auth login |
| direnv | ? | brew install direnv |
| direnv hook | ? | shell rc 설정 |

## Step 3: Ask What to Configure

Use AskUserQuestion:

**Question:** "Which internal services to set up?"

**Options:**
1. **All missing (recommended)** - Configure everything
2. **GitLab CLI only** - glab setup
3. **direnv only** - Environment management
4. **Skip** - Do nothing

## Step 4: GitLab CLI Setup

### Install glab

```bash
brew install glab 2>/dev/null || echo "INSTALL_FAILED"
```

### Authenticate

IMPORTANT: Do NOT pass tokens directly in shell commands. Guide the user to run interactively.

Tell the user:
> 아래 명령어를 직접 실행해주세요:
> ```
> ! glab auth login --hostname <INTERNAL_GITLAB>
> ```
> 인증 방식: "Token" 선택 후 Personal Access Token 입력
> Token 발급: https://<INTERNAL_GITLAB>/-/user_settings/personal_access_tokens

After user completes login, verify:

```bash
glab auth status 2>&1 | head -5
```

## Step 5: direnv Setup

### Install

```bash
brew install direnv 2>/dev/null || echo "INSTALL_FAILED"
```

### Add shell hook

Detect shell and check if hook exists:

```bash
SHELL_NAME=$(basename "$SHELL")
RC_FILE="$HOME/.${SHELL_NAME}rc"

if grep -q "direnv hook" "$RC_FILE" 2>/dev/null; then
  echo "direnv hook already in $RC_FILE"
else
  echo "Need to add direnv hook to $RC_FILE"
fi
```

If hook not found, add it:

For zsh:
```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

For bash:
```bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
```

### Create project .envrc template

If no .envrc exists in the current project:

```bash
cat > .envrc << 'ENVRC'
# Load shared environment variables
[ -f .env.shared ] && dotenv .env.shared
ENVRC
```

Then allow it:
```bash
direnv allow .
```

## Step 6: Network Info

Tell the user:
> 사내 서비스 접근 정보:
> - GitLab: https://<INTERNAL_GITLAB>
> - Metabase: https://<INTERNAL_BI> (사내망 전용)
> - 네트워크 접근 문의: 사내 IT 지원 채널 참조

## Step 7: Summary

Show final status table with all configured services.
