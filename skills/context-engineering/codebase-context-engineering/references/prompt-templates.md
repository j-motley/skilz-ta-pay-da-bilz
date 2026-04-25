# Prompt Templates

Use these only as small reusable snippets. For the full context-builder prompt, read `context-builder-prompt.md`.

## Minimal User Prompt

```text
Use $codebase-context-engineering to analyze this repository and generate `.agent-context/` files for future AI development agents. Create or update `AGENTS.md` only if it is useful as a discovery hook.
```

## Path-Or-Repo Prompt

```text
Use $codebase-context-engineering on <path-or-repo-url>.

Generate durable context files that help future agents answer questions, plan changes, implement features, debug issues, document the system, and mentor a human developer through the codebase.

Keep the output proportional to the codebase. Adapt the context file structure to what the repository actually is.
```

## AGENTS.md Discovery Hook

```md
# Agent Instructions

Before answering questions or changing code in this repository, read `.agent-context/README.md`.

The `.agent-context/` directory contains the codebase map, conventions, architecture notes, workflows, and task guides generated for AI development agents.
```

## Context Refresh Prompt

```text
Use $codebase-context-engineering to refresh the existing `.agent-context/` files after recent codebase changes.

Preserve accurate existing context, remove stale claims, add newly discovered patterns or commands, and mark uncertainty clearly. Do not rewrite everything if an incremental update is enough.
```

## Context Audit Prompt

```text
Use $codebase-context-engineering to audit the existing `.agent-context/` files.

Check whether a future agent could quickly understand what this codebase does, how it is organized, what patterns to follow, how to verify work, and what areas are risky or uncertain. Report gaps and propose targeted updates.
```
