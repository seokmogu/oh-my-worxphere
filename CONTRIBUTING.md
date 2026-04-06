# Contributing to oh-my-worxphere

Worxphere 팀원 누구나 이 플러그인에 기여할 수 있습니다.

## 기여 방법

### 1. 새로운 스킬 추가

사내 도구 연동, 자동화 워크플로우 등을 스킬로 추가할 수 있습니다.

```
skills/
└── <your-skill-name>/
    └── SKILL.md
```

**SKILL.md 형식:**

```yaml
---
name: your-skill-name
description: "스킬 설명 (한 줄)"
triggers:
  - "트리거 키워드 1"
  - "트리거 키워드 2"
allowed-tools: Bash, Read, Write, Edit
---

# 스킬 제목

스킬의 동작을 단계별로 기술합니다.

## Step 1: ...
## Step 2: ...
```

### 2. 사내 도구 연동 추가

사내 시스템을 연동하려면 `skills/worx-<tool>/SKILL.md`로 추가합니다.

예시:
- `skills/worx-jira/SKILL.md` — Jira 연동
- `skills/worx-confluence/SKILL.md` — Confluence 연동
- `skills/worx-hr-portal/SKILL.md` — HR 포털 연동

**연동 방식 선택 가이드:**

| 사내 도구 상태 | 권장 연동 방식 |
|-------------|-------------|
| REST API 있음 | 커스텀 MCP 서버 개발 |
| 웹 UI만 있음 | Chrome 브라우저 자동화 (claude-in-chrome) |
| CLI 도구 있음 | Bash 스크립트 래핑 |
| API 없음 | 스크래핑 or API 개발 요청 |

### 3. 거버넌스 규칙 추가

사내 정책이나 코딩 표준을 추가하려면 CLAUDE.md를 수정합니다.

## 개발 환경

### 로컬 테스트

플러그인을 로컬에서 테스트하려면:

```bash
cd ~/project/oh-my-worxphere
claude --plugin-dir .
```

### 기본 검증

```bash
# JSON 파일 검증
python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('OK')"

# Node.js 스크립트 검증
node --check scripts/session-start.mjs

# Bash 스크립트 검증
bash -n scripts/install-claude.sh
```

## Git 워크플로우

### GitHub (배포용)

```bash
git clone https://github.com/seokmogu/oh-my-worxphere.git
cd oh-my-worxphere
# 변경 후
git add <files>
git commit -m "feat: add worx-jira skill"
git push origin main
```

### 사내 GitLab (미러)

GitHub를 primary로 사용하고, 사내 GitLab에 미러링합니다:

```bash
# 사내 GitLab remote 추가
git remote add gitlab https://<INTERNAL_GITLAB>/ai/oh-my-worxphere.git

# 양쪽에 push
git push origin main
git push gitlab main
```

## 스킬 생태계

### 2-tier 구조

```
GitHub (seokmogu/oh-my-worxphere)              ← 코어 플러그인
  └── skills/worx-*/                            ← 핵심 스킬만

GitLab (<INTERNAL_GITLAB>/ai/worxphere-skills) ← 사내 커뮤니티
  └── skills/                                    ← 팀원들이 자유롭게 추가
```

### 빠른 시작: 스킬 추가하기

```bash
# 1. 템플릿 생성
/worx-skills add jira

# 2. 내용 편집 (SKILL.md 수정)

# 3. 검증
bash scripts/validate-skill.sh .worxphere/skills/worx-jira/SKILL.md

# 4. 제출
/worx-skills submit worx-jira
```

### 스킬 동기화

다른 팀원이 만든 스킬을 내려받으려면:

```bash
/worx-skills sync
```

GitLab `ai/worxphere-skills` 레포에서 최신 스킬을 `.worxphere/skills/`로 동기화합니다.

### 스킬 검증 CI

GitLab에 스킬을 제출하면 CI가 자동으로 검증합니다:
- YAML frontmatter 존재 여부
- 필수 필드 (name, description) 확인
- name kebab-case 규칙 확인
- 본문 content 존재 여부

## 네이밍 규칙

- 스킬 이름: `kebab-case` (예: `worx-jira`, `worx-hr-portal`)
- 사내 도구 스킬: `worx-` 접두사 필수
- 범용 스킬: 접두사 없음

## 커밋 메시지

Conventional Commits 형식:

```
feat: add worx-jira integration skill
fix: correct GitLab token validation in worx-portal
docs: update MCP setup guide for Notion
```

## 질문 및 지원

- Slack: 사내 AI팀 채널 (내부 문서 참조) 채널
- GitLab Issues: <INTERNAL_GITLAB>/ai/oh-my-worxphere/-/issues
