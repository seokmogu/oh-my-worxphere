---
name: worx-skills
description: "Manage Worxphere community skills - list, sync, add, submit, search"
argument-hint: "<command> [args]"
triggers:
  - "worx skills"
  - "사내 스킬"
  - "스킬 추가"
  - "스킬 동기화"
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Glob, Grep
---

# Worxphere Skills Manager

Manage community-contributed skills from the Worxphere team.

**When this skill is invoked, parse the subcommand and execute accordingly.**

## Subcommand Routing

Parse the first argument:

- No argument or `list` -> `/worx-skills list`
- `sync` -> `/worx-skills sync`
- `add <name>` -> `/worx-skills add`
- `submit <name>` -> `/worx-skills submit`
- `search <query>` -> `/worx-skills search`
- `--help` -> Show help text

## Help Text

```
Worxphere Skills Manager

USAGE:
  /worx-skills list              List installed worxphere skills
  /worx-skills sync              Sync skills from corporate GitLab
  /worx-skills add <name>        Create new skill from template
  /worx-skills submit <name>     Submit skill as GitLab MR
  /worx-skills search <query>    Search available skills
  /worx-skills --help            Show this help

SKILL LOCATIONS:
  Core skills:    (bundled with oh-my-worxphere plugin)
  Community:      .worxphere/skills/ (synced from GitLab)
  Personal:       ~/.claude/skills/worxphere-learned/
```

## /worx-skills list

Scan and display all worxphere skills:

```bash
echo "=== Core Skills (bundled) ==="
for dir in "${CLAUDE_PLUGIN_ROOT:-$(pwd)}/skills/worx-"*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  desc=$(grep -m1 "^description:" "$dir/SKILL.md" 2>/dev/null | sed 's/description: *//' | tr -d '"')
  echo "  $name — $desc"
done

echo ""
echo "=== Community Skills (.worxphere/skills/) ==="
if [ -d ".worxphere/skills" ]; then
  for dir in .worxphere/skills/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    desc=$(grep -m1 "^description:" "$dir/SKILL.md" 2>/dev/null | sed 's/description: *//' | tr -d '"')
    author=$(grep -m1 "^author:" "$dir/SKILL.md" 2>/dev/null | sed 's/author: *//' | tr -d '"')
    echo "  $name — $desc (by $author)"
  done
else
  echo "  (none — run /worx-skills sync to download)"
fi

echo ""
echo "=== Personal Skills (~/.claude/skills/worxphere-learned/) ==="
PERSONAL="$HOME/.claude/skills/worxphere-learned"
if [ -d "$PERSONAL" ]; then
  for dir in "$PERSONAL"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    desc=$(grep -m1 "^description:" "$dir/SKILL.md" 2>/dev/null | sed 's/description: *//' | tr -d '"')
    echo "  $name — $desc"
  done
else
  echo "  (none)"
fi
```

Display results in a formatted table.

## /worx-skills sync

Sync community skills from the corporate GitLab repository.

### Step 1: Check GitLab access

```bash
glab auth status 2>&1 | head -3 || echo "NOT_CONFIGURED"
```

If not configured, tell the user:
> GitLab 인증이 필요합니다. `/worx-portal` 을 먼저 실행하세요.

### Step 2: Clone or pull

```bash
SKILLS_REPO="https://<INTERNAL_GITLAB>/ai/worxphere-skills.git"
LOCAL_DIR="/tmp/worxphere-skills-sync"

if [ -d "$LOCAL_DIR/.git" ]; then
  cd "$LOCAL_DIR" && git pull --ff-only 2>&1
else
  git clone "$SKILLS_REPO" "$LOCAL_DIR" 2>&1
fi
```

### Step 3: Copy skills to project

```bash
mkdir -p .worxphere/skills
cp -r "$LOCAL_DIR/skills/"* .worxphere/skills/ 2>/dev/null
echo "Synced $(ls .worxphere/skills/ | wc -l) skills"
```

### Step 4: Report

Show list of synced skills with name and description.

## /worx-skills add <name>

Create a new skill from the standard template.

### Step 1: Validate name

Name must be `worx-` prefixed, kebab-case, no spaces.

If name doesn't start with `worx-`, prepend it:
- Input: `jira` -> `worx-jira`
- Input: `worx-jira` -> `worx-jira` (as-is)

### Step 2: Ask for details

Use AskUserQuestion:

**Question:** "스킬 기본 정보를 입력해주세요"

Collect:
- Description (한 줄 설명)
- Triggers (쉼표 구분 키워드)
- Author (이름 또는 핸들)

### Step 3: Choose scope

Use AskUserQuestion:

**Options:**
1. **Community** (.worxphere/skills/) — 팀 공유용, GitLab에 제출 가능
2. **Personal** (~/.claude/skills/worxphere-learned/) — 개인용

### Step 4: Generate template

Write the SKILL.md file:

```yaml
---
name: <name>
description: "<description>"
triggers:
  - "<trigger1>"
  - "<trigger2>"
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
author: "<author>"
created: "<today's date>"
---

# <Name> Integration

## Overview

<description>

## Step 1: Check Current Status

Check if <tool> is already configured:

```bash
# Add status check commands here
```

## Step 2: Configure

Configure <tool>:

```bash
# Add configuration commands here
```

## Step 3: Verify

Verify the configuration:

```bash
# Add verification commands here
```
```

### Step 5: Report

> 스킬이 생성되었습니다: `<path>/SKILL.md`
> 내용을 편집한 후 `/worx-skills submit <name>` 으로 제출하세요.

## /worx-skills submit <name>

Submit a community skill to the corporate GitLab repository.

### Step 1: Validate skill exists

```bash
SKILL_PATH=".worxphere/skills/<name>/SKILL.md"
[ -f "$SKILL_PATH" ] && echo "FOUND" || echo "NOT_FOUND"
```

### Step 2: Validate format

Run the validation script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/validate-skill.sh" "$SKILL_PATH"
```

### Step 3: Guide MR submission

Tell the user:
> 스킬 검증 통과. GitLab MR로 제출하려면:
> 1. worxphere-skills 저장소를 clone: `git clone https://<INTERNAL_GITLAB>/ai/worxphere-skills.git`
> 2. 스킬 복사: `cp -r .worxphere/skills/<name> worxphere-skills/skills/`
> 3. 커밋 & push: `cd worxphere-skills && git add . && git commit -m "feat: add <name> skill" && git push`
> 4. GitLab에서 MR 생성

Or if glab is configured:
```bash
cd /tmp/worxphere-skills-sync
cp -r "$OLDPWD/.worxphere/skills/<name>" skills/
git checkout -b "feat/<name>"
git add "skills/<name>"
git commit -m "feat: add <name> skill"
git push -u origin "feat/<name>"
glab mr create --title "feat: add <name> skill" --description "New community skill: <name>"
```

## /worx-skills search <query>

Search skills by name, description, or triggers:

```bash
echo "=== Searching for: <query> ==="

# Search bundled skills
grep -ril "<query>" "${CLAUDE_PLUGIN_ROOT:-$(pwd)}/skills/"*/SKILL.md 2>/dev/null | while read f; do
  dir=$(dirname "$f")
  name=$(basename "$dir")
  desc=$(grep -m1 "^description:" "$f" | sed 's/description: *//' | tr -d '"')
  echo "  [core] $name — $desc"
done

# Search community skills
grep -ril "<query>" .worxphere/skills/*/SKILL.md 2>/dev/null | while read f; do
  dir=$(dirname "$f")
  name=$(basename "$dir")
  desc=$(grep -m1 "^description:" "$f" | sed 's/description: *//' | tr -d '"')
  echo "  [community] $name — $desc"
done

# Search personal skills
grep -ril "<query>" "$HOME/.claude/skills/worxphere-learned/"*/SKILL.md 2>/dev/null | while read f; do
  dir=$(dirname "$f")
  name=$(basename "$dir")
  desc=$(grep -m1 "^description:" "$f" | sed 's/description: *//' | tr -d '"')
  echo "  [personal] $name — $desc"
done
```

Display results in a formatted table. If no results, suggest:
> 검색 결과가 없습니다. `/worx-skills add <name>` 으로 직접 만들어보세요.
