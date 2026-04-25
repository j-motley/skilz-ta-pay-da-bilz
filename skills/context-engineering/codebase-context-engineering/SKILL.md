---
name: codebase-context-engineering
description: Analyze a local path or git repository and generate durable .agent-context files that help future AI coding agents quickly understand, explain, plan, implement, debug, document, and safely change a codebase. Use when Codex needs to build, audit, or refresh agent-discoverable codebase context for any software system, including apps, services, libraries, monorepos, data projects, infrastructure repos, Java projects, containerized systems, SQL projects, or mixed-language codebases.
---

# Codebase Context Engineering

Use this skill to point at a codebase and generate context files for future AI development agents. The job is not to produce pretty documentation. The job is to reconstruct the working mental model a strong developer would build while onboarding, then write it down so future agents can become useful quickly.

Primary output:

- `.agent-context/` containing structured, durable context files
- optional root `AGENTS.md` that tells agents to read `.agent-context/README.md`

Read `references/context-builder-prompt.md` when the user asks for the full reusable prompt or when you need the strongest form of the context-builder instructions.

## Audience

Write for future AI agents that may have limited time, limited context windows, and no memory of prior sessions. They may need to:

- answer questions about the codebase
- mentor a human developer through unfamiliar code
- generate documentation
- plan code changes
- implement features or new data products
- fix bugs
- refactor safely
- review impact across related files, modules, services, projects, or pipelines

Make those future agents smarter than raw file search would make them.

## Operating Principles

- Let the repository tell you what kind of context it needs.
- Ground claims in observed files, configs, dependencies, docs, tests, naming patterns, manifests, comments, lineage, and repeated code patterns.
- Distinguish observed facts from inference and uncertainty.
- Capture real conventions, including team-specific conventions that are not public best practices.
- Explain relationships, not just inventories.
- Prefer orientation paths, decision rules, warnings, and task guides over exhaustive file listings.
- Keep output proportional to repo size and complexity.
- Preserve the user's worktree. Before editing, check existing files and avoid overwriting unrelated user work.

## Workflow

### 1. Intake

Identify the target:

- local path or git repo
- whether to write files or draft the context in chat
- output location, defaulting to `.agent-context/` at the repo root
- whether to create or update a root `AGENTS.md`
- user goals, if any, such as onboarding, mentoring, feature work, bug fixing, documentation, modernization, or data-product development

If the user gives only a path or repo, proceed with a default context build.

### 2. Detect The Codebase Type

Determine what kind of system this is before deciding the output shape:

- application, service, library, CLI, data project, monorepo, infrastructure repo, framework plugin, batch job, documentation repo, mixed repo, or something else
- primary and secondary languages
- frameworks, runtimes, package managers, build tools, test tools, deployment tools, containers, orchestration, and configuration systems
- whether the repo contains one project, many projects, or loosely related areas
- which areas are primary, peripheral, legacy, generated, vendor-owned, or barely used

Avoid technology-specific assumptions. A Java/Docker service, a SQL transformation repo, and a frontend app need different context.

### 3. Inventory Evidence

Inspect only as deeply as needed, but cover the surfaces that reveal how the system works:

- root files, docs, existing agent instructions, and contribution guides
- directory structure and project boundaries
- package manifests, lockfiles, build files, dependency configs, and runtime configs
- CI, deployment, Docker/container, environment, and infrastructure files
- tests, fixtures, mocks, examples, and verification commands
- entry points, public APIs, jobs, scripts, models, queries, migrations, schemas, or pipelines
- generated files, vendored code, secrets patterns, and protected paths
- recent git history when it helps explain active areas or conventions

Prefer `rg --files`, `rg`, targeted file reads, and focused command inspection.

### 4. Map Relationships

Build the mental model future agents need:

- entry points and execution flow
- major components, modules, packages, projects, services, or pipelines
- dependency direction and layering
- foundational vs downstream areas
- runtime boundaries and data boundaries
- configuration inheritance and environment assumptions
- how tests map to implementation
- where docs match or diverge from code

For data, query, or transformation-heavy repos, emphasize lineage, sources, models, schemas, naming, materialization, and downstream impact. For application repos, emphasize runtime flow, APIs, state, persistence, background work, and deployment shape.

### 5. Extract Patterns And Conventions

Look for repeated choices that future agents should imitate or question:

- architecture and design patterns
- language paradigms in use, such as object-oriented, functional, procedural, declarative, markup, query, configuration, or infrastructure-as-code
- naming conventions
- file and folder organization
- error handling and logging
- dependency injection, composition, inheritance, or macro/template patterns
- testing style and coverage norms
- configuration and environment handling
- code generation or artifact ownership
- ecosystem best practices that are followed, bent, or ignored
- local team customs that matter even when they are not best practice

Do not shame the codebase. Describe what is real, how to work with it, and where future agents should be careful.

### 6. Generate Context Files

Default structure:

```text
.agent-context/
  README.md
  system-overview.md
  codebase-map.md
  architecture-and-patterns.md
  languages-frameworks-and-tools.md
  conventions-and-local-practices.md
  workflows-and-commands.md
  task-guides.md
  risks-unknowns-and-open-questions.md
```

Adapt the structure to the repo. Add, remove, split, or rename files when the codebase calls for it. For larger or specialized repos, consider:

```text
.agent-context/
  module-map.md
  dependency-map.md
  data-model.md
  api-surface.md
  deployment-runtime.md
  testing-strategy.md
  domain-glossary.md
  generated-files.md
```

Use `references/context-file-schema.md` for file purposes and section guidance.

### 7. Add The Discovery Hook

If the repository does not already have clear agent instructions, create or update `AGENTS.md` with a short pointer to `.agent-context/README.md`.

If `AGENTS.md` already exists, preserve its existing instructions and add a concise context-discovery note where it fits.

### 8. Validate For Future Agents

Check whether a cold-start agent could answer:

- What is this codebase and what does it do?
- What should I read first for my task?
- How are the important parts related?
- What conventions should I follow?
- What commands can I use to build, test, run, or verify?
- What areas are risky, stale, generated, legacy, or uncertain?
- How should I plan, implement, debug, document, or ask questions in this repo?

Read `references/validation-rubric.md` for the scoring rubric.

## Output Rules

- Write concise, operational context.
- Include assumptions and unknowns.
- Include exact commands only when observed or confidently inferred from repo files.
- Avoid generic engineering advice unless it maps to observed repo behavior.
- Avoid listing every file. Explain roles and relationships.
- Avoid over-documenting small repos.
- For huge repos, create orientation layers and reading paths instead of one enormous context file.
