# oh-my-worxphere (OMX)

Worxphere 전용 Claude Code 플러그인. omc(실행 엔진) 위에 사내 거버넌스와 품질 규칙을 적용합니다.

## 핵심 원칙

- 사용자 언어로 응답 (한국어)
- 독립 작업은 병렬 실행
- XML 태그를 사용자에게 노출하지 않음
- 복잡한 작업은 전문 에이전트에 위임

## 품질 게이트 (TRUST 5)

모든 코드 변경은 TRUST 5 검증을 통과해야 합니다:

- **T**ested: 85%+ 커버리지, 기존 코드는 characterization test
- **R**eadable: 명확한 네이밍, 영문 코드 코멘트
- **U**nified: 일관된 스타일, ruff/black/prettier 포매팅
- **S**ecured: OWASP 준수, 입력 검증
- **T**rackable: Conventional commits, 이슈 참조

## 사내 엔터프라이즈 정책

### 데이터 분류

| Level | 예시 | 처리 방법 |
|---|---|---|
| Public | 공개 문서, 오픈소스 | 자유롭게 사용 |
| Internal | 사내 문서, 미팅 노트 | 승인된 환경에서만 |
| Confidential | 고객 계약, 소스코드 | 민감 필드 마스킹 |
| Restricted | 주민번호, 결제 정보 | 익명화 또는 합성 데이터 |

### 비밀 관리

- `.env` + `.gitignore`로 로컬 관리
- 소스코드에 시크릿 하드코딩 금지
- `os.environ["KEY"]` 또는 환경변수 사용
- `.env`, `*.pem`, `*.key` 파일 커밋 금지

### 보안 기본

- SQL 파라미터화 쿼리 필수
- HTML 출력 XSS 방지 (DOMPurify 등)
- 외부 입력은 시스템 경계에서 검증
- 프로덕션 호스트명/IP 직접 임베드 금지

### 금지 사항

- 비인가 외부 서비스에 회사 코드/데이터 업로드
- 프로덕션 시스템 자동 쓰기/삭제 (명시적 승인 없이)
- 인증/접근 제어 우회
- AI 생성 콘텐츠를 사람의 판단으로 위장

### 컨테이너

- docker 대신 `podman` 사용
- `--privileged` 사용 금지
- 읽기 전용 마운트 선호 (`-v /data:/data:ro`)

### Git 규칙

- push 전 현재 브랜치 확인 필수
- 대부분 `main` 브랜치 사용, 별도 브랜치 함부로 생성 금지
- `.env` 등 설정 파일 무단 수정 금지

## 사내 서비스 정보

| 서비스 | URL | 비고 |
|--------|-----|------|
| GitLab | <INTERNAL_GITLAB> | 사내 코드 저장소 |
| Metabase | <INTERNAL_BI> | 사내망 전용 BI |
| Slack | 사내 워크스페이스 | MCP로 연동 가능 |

## 워크플로우

### Notion 도구 원칙

로컬 워크스페이스에서는 `/Users/seokmogu/project/NOTION_PUBLISHING.md`를 따른다. 대화형 Notion 연결은 OAuth 기반 Hosted Notion MCP (`https://mcp.notion.com/mcp`)가 기본이며, 토큰을 받는 로컬 npm MCP를 설치하지 않는다. batch/headless 배포는 공식 enhanced Markdown/API를 사용하고, 사내 커스텀 도구는 공식 표면에 없는 기능에만 한정한다.

### 스킬 사용법

- `/worx-onboarding` — 신규 입사자 통합 온보딩
- `/worx-mcp-config` — Slack, Hosted Notion, GitHub, GitLab MCP 설정
- `/worx-portal` — 사내 GitLab CLI, direnv 연동

### 사내 도구 추가

사내 구성원이 새 도구 연동을 추가하려면:
1. `skills/` 디렉토리에 `<tool-name>/SKILL.md` 생성
2. YAML frontmatter에 name, description, triggers 기재
3. PR 또는 MR로 제출

자세한 내용은 CONTRIBUTING.md 참조.

## 에러 대응

- 에러는 사용자 언어로 보고
- 복구 옵션 제안
- 작업당 최대 3회 재시도
- 반복 실패 시 사용자에게 개입 요청

## 설정

omx 설정은 `/omx-setup` 으로 실행합니다.
사내 포털 연동은 `/worx-portal` 으로 실행합니다.
