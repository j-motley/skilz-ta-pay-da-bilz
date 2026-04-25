---
name: codebase-context-engineering
description: Create, audit, refresh, or improve AI-agent operating context for software codebases. Use when Codex needs to produce an AGENTS.md, CODEBASE_CONTEXT.md, role-specific coding-agent prompts, agentic development-team requirements, repo reconnaissance workflow, context-pack schema, validation rubric, or a multistage prompt that helps AI agents safely understand, modify, test, review, and maintain a codebase.
---

# Codebase Context Engineering

Use this skill to turn a repository or codebase idea into an agent-ready operating context. Prefer a staged process over one giant prompt: define the agent team's job, inspect the repo, extract durable context, generate artifacts, then validate them against realistic development work.

## Operating Principles

- Optimize for safe autonomy: agents should act decisively when context is sufficient and escalate when requirements, permissions, or risk are unclear.
- Preserve the user's worktree: identify uncommitted changes before editing and never overwrite unrelated user work.
- Ground claims in observed repo evidence: files, commands, configs, docs, tests, and git history when available.
- Capture conventions, not preferences invented during analysis.
- Keep generated context concise enough to be used, with references for deeper details.
- Treat verification as part of the artifact: every context pack should say how agents prove changes are correct.

## Workflow

### 1. Intake

Clarify or infer the operating target:

- repo type and primary languages/frameworks
- expected agent roles
- autonomy level
- allowed tools
- target artifacts
- risk tolerance
- success criteria

If the user has not chosen artifacts, default to:

- `AGENTS.md` for agent operating rules
- `CODEBASE_CONTEXT.md` for repo-specific context
- role prompts only when multi-agent coordination is explicitly useful

For detailed requirements prompts, read `references/agentic-dev-team-requirements.md`.

### 2. Repository Recon

Inspect only as deeply as the task requires. Start with:

- root files and directory structure
- package/build/test configs
- docs, contribution guides, and existing agent instructions
- test layout and CI workflows
- app entry points and major modules
- dependency manifests and lockfiles
- git status and recent history when available

Prefer fast local discovery commands such as `rg --files`, `rg`, `git status --short`, and targeted file reads. Record uncertainty instead of filling gaps with guesses.

### 3. Context Extraction

Extract the durable information agents need before changing code:

- product/domain summary
- architecture and module boundaries
- runtime, build, lint, test, and dev-server commands
- coding conventions and established patterns
- testing strategy and fixtures
- data models, APIs, jobs, queues, migrations, and external integrations
- generated files and files that need special care
- known hazards, flaky tests, legacy areas, and performance/security-sensitive paths
- task execution, escalation, and review expectations

Use `references/context-pack-schema.md` when drafting the output structure.

### 4. Agent Operating Model

Define roles only when they help. Common roles:

- Planner: decomposes work and tracks assumptions
- Explorer: maps relevant code and conventions
- Implementer: makes scoped changes
- Tester: verifies behavior and expands coverage
- Reviewer: finds regressions, risks, and missing tests
- Documentarian: updates user-facing or contributor docs

For multi-agent work, specify ownership boundaries, handoff format, conflict avoidance, and when the lead agent integrates results.

### 5. Generate Artifacts

Produce the smallest artifact set that satisfies the goal.

Use these defaults:

- `AGENTS.md`: rules agents must follow while working in the repo
- `CODEBASE_CONTEXT.md`: repository map and operational context
- `AI_DEV_TEAM_OPERATING_GUIDE.md`: optional team process for multi-agent workflows
- `prompts/*.md`: optional role-specific prompts

For reusable prompt text and artifact templates, read `references/prompt-templates.md`.

### 6. Validate

Validate the context pack against concrete questions:

- Can an agent identify where to make a likely feature change?
- Can an agent run the right verification commands?
- Can an agent avoid generated files, secrets, migrations, and unrelated user changes?
- Can an agent explain what it changed and why?
- Can multiple agents work without overlapping ownership?

Read `references/validation-rubric.md` for the scoring rubric.

### 7. Maintain

Tell future agents when to refresh the context:

- build, test, or deployment commands change
- architecture, routing, data model, or package boundaries change
- major dependencies or frameworks change
- new generated-file patterns appear
- context contradicts observed repo behavior

Prefer incremental refreshes over full rewrites unless the repo has changed substantially.

## Output Rules

- Include assumptions and unknowns.
- Include exact commands only when observed or confidently inferred from repo files.
- Separate stable repo context from task-specific instructions.
- Keep role prompts short and role-bound.
- Avoid generic engineering advice unless it maps to this repo's actual patterns.
