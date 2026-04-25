# Agentic Dev Team Requirements

Use this reference during intake or when the user wants to define the agent team before scanning a repo.

## Mission Template

Enable AI agents to safely, efficiently, and autonomously understand, modify, test, review, and document a software codebase while preserving product behavior, architectural intent, developer trust, and long-term maintainability.

## Goals

- Shorten codebase onboarding time for agents.
- Improve correctness of agent-made code changes.
- Reduce accidental edits to unrelated or generated files.
- Make verification and review expectations explicit.
- Support both single-agent and multi-agent development workflows.
- Keep context current as the codebase evolves.

## Functional Requirements

- Discover repo structure, languages, frameworks, and package boundaries.
- Identify build, test, lint, typecheck, format, and dev-server commands.
- Locate existing docs, contribution rules, codeowners, and agent instructions.
- Infer architecture, major modules, app entry points, and data flow.
- Capture coding, error-handling, naming, state-management, and testing conventions.
- Distinguish generated files, vendored code, migrations, secrets, and fragile areas.
- Detect current worktree changes before editing.
- Decompose tasks into scoped implementation and verification steps.
- Coordinate multiple agents with explicit ownership and handoff rules.
- Produce review findings with file and line references when reviewing code.
- Report verification results and residual risk.

## Nonfunctional Requirements

- Safety: do not destroy, reset, or overwrite user work without explicit permission.
- Accuracy: ground claims in repository evidence.
- Relevance: include only context agents can act on.
- Maintainability: prefer existing repo patterns over new abstractions.
- Traceability: connect generated guidance to observed files or documented assumptions.
- Autonomy: proceed when safe, ask when blocked by real ambiguity or risk.
- Scalability: support small repos, monorepos, legacy systems, and service-oriented codebases.
- Privacy: do not expose secrets, tokens, or sensitive data discovered in files.

## Intake Questions

Ask only the questions needed to avoid bad assumptions:

- What artifacts should be produced: `AGENTS.md`, `CODEBASE_CONTEXT.md`, role prompts, or all of them?
- Should agents be allowed to edit code autonomously or only prepare recommendations?
- Which agent roles matter for this team?
- What is the highest priority: speed, safety, depth, reviewability, or maintainability?
- Are there paths, commands, services, or environments agents must not touch?
