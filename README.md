# oh-my-worxphere (OMX)

Worxphere 신규 입사자를 위한 Claude Code 온보딩 & 멀티에이전트 오케스트레이션 플러그인.

oh-my-claudecode(omc)를 기반으로, Worxphere 맞춤 온보딩/MCP 자동설정/사내 포털 연동을 추가한 올인원 플러그인입니다.

---

## 설치 순서

### Step 0: Claude Code가 없는 경우 (만능 설치 스크립트)

**macOS / Linux / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh | bash
```

**Windows (PowerShell 관리자):**
```powershell
irm https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-windows.ps1 | iex
```

> 이 스크립트가 아래 1~5를 자동으로 수행합니다. 이미 Claude Code가 설치되어 있다면 Step 1부터 시작하세요.

### Step 1: 플러그인 설치

```bash
claude plugin marketplace add https://github.com/seokmogu/oh-my-worxphere
claude plugin install oh-my-worxphere@oh-my-worxphere
```

### Step 2: 초기 설정

Claude Code 실행 후:
```
/omx-setup
```

### Step 3: MCP 서버 설정 (Slack, Notion, GitHub, GitLab)

```
/worx-mcp-config
```

### Step 4: 사내 포털 연동 (GitLab CLI, direnv)

```
/worx-portal
```

### Step 5: 전체 온보딩 (Step 3 + 4를 한번에)

```
/worx-onboarding
```

### Step 6: 설치 검증

```
/worx-doctor
```

---

## 만능 설치 스크립트가 설치하는 것들

| Step | macOS/Linux | Windows |
|------|------------|---------|
| 1 | Homebrew, Node.js 22, Git, Python 3.12+, uv | WSL2 + Ubuntu 24.04 |
| 2 | VSCode, Ghostty, Zed | VSCode, Ghostty, Zed (Windows-side) |
| 3 | Claude Code CLI | WSL 내부에서 Claude Code CLI |
| 4 | Claude Code 로그인 | Claude Code 로그인 |
| 5 | oh-my-worxphere 플러그인 설치 | oh-my-worxphere 플러그인 설치 |
| 6 | Chrome Claude 확장 안내 | Chrome Claude 확장 안내 |

---

## Skills (31개)

### Worxphere 전용

| Skill | 설명 |
|-------|------|
| `/worx-onboarding` | 통합 온보딩 (MCP + 포털 한번에, phased) |
| `/worx-mcp-config` | Slack, Notion, GitHub, GitLab, Context7 MCP 자동 설정 |
| `/worx-portal` | 사내 GitLab CLI, direnv, 내부 서비스 연동 |
| `/worx-doctor` | 환경 건강 검진 (14개 항목, 스코어 표시) |
| `/worx-skills` | 사내 스킬 생태계 관리 (list/sync/add/submit/search) |

### 워크플로우

| Skill | 설명 |
|-------|------|
| `/autopilot` | 아이디어에서 코드까지 자율 실행 |
| `/ralph` | 작업 완료까지 자기 참조 루프 |
| `/ultrawork` | 고처리량 병렬 실행 엔진 |
| `/team` | N명 에이전트 협업 |
| `/ccg` | Claude-Codex-Gemini 3모델 오케스트레이션 |
| `/ultraqa` | QA 반복 (테스트-검증-수정 루프) |
| `/plan` | 전략적 기획 + 인터뷰 워크플로우 |
| `/ralplan` | 합의 기반 기획 |
| `/sciomc` | 병렬 분석 에이전트 오케스트레이션 |
| `/deep-dive` | 원인 추적 + 요구사항 결정화 파이프라인 |
| `/deep-interview` | 소크라틱 딥 인터뷰 |
| `/trace` | 증거 기반 추적 |

### 유틸리티

| Skill | 설명 |
|-------|------|
| `/omx-setup` | 초기 설정 마법사 |
| `/omx-doctor` | 설치 진단/복구 |
| `/omx-teams` | tmux 기반 멀티 CLI 워커 |
| `/mcp-setup` | 범용 MCP 서버 설정 |
| `/setup` | 통합 설정 엔트리포인트 |
| `/hud` | HUD 디스플레이 설정 |
| `/skill` | 스킬 관리 (추가/제거/검색) |
| `/learner` | 대화에서 스킬 자동 추출 |
| `/ask` | Claude/Codex/Gemini 질의 |
| `/cancel` | 활성 모드 취소 |
| `/deepinit` | 코드베이스 AGENTS.md 생성 |
| `/external-context` | 외부 문서 검색 |
| `/ai-slop-cleaner` | AI 생성 코드 정리 |
| `/configure-notifications` | Slack/Discord/Telegram 알림 설정 |
| `/project-session-manager` | Git worktree 기반 세션 관리 |
| `/writer-memory` | 작가용 기억 시스템 |

---

## Agents (19개)

| Agent | Model | 역할 |
|-------|-------|------|
| explore | haiku | 코드베이스 탐색 |
| analyst | opus | 요구사항 분석 |
| planner | opus | 기획 |
| architect | opus | 아키텍처 설계 |
| critic | opus | 리뷰 |
| code-reviewer | opus | 코드 리뷰 |
| code-simplifier | opus | 코드 간소화 |
| executor | sonnet | 구현 |
| debugger | sonnet | 디버깅 |
| designer | sonnet | UI/UX 디자인 |
| verifier | sonnet | 검증 |
| tracer | sonnet | 원인 추적 |
| security-reviewer | sonnet | 보안 리뷰 |
| test-engineer | sonnet | 테스트 |
| qa-tester | sonnet | QA |
| scientist | sonnet | 데이터 분석 |
| document-specialist | sonnet | 문서화 |
| git-master | sonnet | Git 관리 |
| writer | haiku | 기술 문서 작성 |

---

## 자동 감지 (SessionStart Hook)

Claude Code 시작 시 미설정 MCP 서버를 자동 감지하여 알려줍니다.

---

## moai에서 마이그레이션

기존에 moai를 사용 중이라면, omx가 moai의 품질 규칙(TRUST 5)과 거버넌스를 흡수했으므로 moai를 제거할 수 있습니다.

### Step 1: omx 플러그인 설치

```bash
claude plugin marketplace add https://github.com/seokmogu/oh-my-worxphere
claude plugin install oh-my-worxphere@oh-my-worxphere
```

### Step 2: moai 프로젝트 규칙 제거

```bash
# moai 규칙 디렉토리 제거
rm -rf .claude/rules/moai/

# moai 스킬 제거
rm -rf .claude/skills/moai/

# moai 설정 제거
rm -rf .moai/
```

### Step 3: 프로젝트 CLAUDE.md 정리

프로젝트 CLAUDE.md에서 moai 관련 내용을 제거합니다. omx CLAUDE.md가 사내 거버넌스와 품질 규칙을 담당합니다.

### 유지되는 것

- **omc 플러그인** — 그대로 유지 (omx의 실행 엔진)
- **omc의 에이전트, 훅, HUD** — 그대로 동작
- **사내 엔터프라이즈 정책** — omx CLAUDE.md에 포함

### 제거되는 것

- `.claude/rules/moai/` — omx CLAUDE.md로 대체
- `.claude/skills/moai/` — omc + omx 스킬로 대체
- `.moai/config/` — 더 이상 불필요

---

## 기여하기

사내 팀원이라면 누구나 스킬/도구 연동을 추가할 수 있습니다. [CONTRIBUTING.md](CONTRIBUTING.md) 참조.

---

## 요구사항

- Claude Code 2.1.0+
- Node.js 18+

## License

MIT
