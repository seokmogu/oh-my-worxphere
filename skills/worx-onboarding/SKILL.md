---
name: worx-onboarding
description: "Unified Worxphere onboarding - MCP setup + portal integration in phased workflow"
level: 2
---

# Worxphere Unified Onboarding

Complete onboarding for new Worxphere employees. Phased workflow with resume support.

**When this skill is invoked, immediately execute the workflow below.**

## Flag Parsing

- `--help` -> Show help and stop
- `--mcp` -> Phase 2 only (MCP config), then stop
- `--portal` -> Phase 3 only (portal setup), then stop
- `--check` -> Status check only, then stop
- No flags -> Full onboarding (Phase 1 -> 2 -> 3 -> 4)

## Help Text

When invoked with `--help`:

```
Worxphere Onboarding - Complete setup for new employees

USAGE:
  /worx-onboarding              Full onboarding wizard
  /worx-onboarding --mcp        MCP server configuration only
  /worx-onboarding --portal     Internal portal setup only
  /worx-onboarding --check      Check current configuration status
  /worx-onboarding --help       Show this help

WHAT IT DOES:
  Phase 1: Environment check (OS, tools, prerequisites)
  Phase 2: MCP server setup (Slack, official Hosted Notion with OAuth, GitHub, GitLab, Context7)
  Phase 3: Internal portal integration (glab, direnv, network)
  Phase 4: Verification and summary

INDIVIDUAL SKILLS:
  /worx-mcp-config    MCP server configuration
  /worx-portal        Internal portal integration
```

## Phase 1: Environment Check

Read `${CLAUDE_PLUGIN_ROOT}/skills/worx-onboarding/phases/01-environment-check.md` and follow its instructions.

## Phase 2: MCP Configuration

Read `${CLAUDE_PLUGIN_ROOT}/skills/worx-onboarding/phases/02-mcp-setup.md` and follow its instructions.

## Phase 3: Portal Integration

Read `${CLAUDE_PLUGIN_ROOT}/skills/worx-onboarding/phases/03-portal-setup.md` and follow its instructions.

## Phase 4: Verification

Read `${CLAUDE_PLUGIN_ROOT}/skills/worx-onboarding/phases/04-verification.md` and follow its instructions.
