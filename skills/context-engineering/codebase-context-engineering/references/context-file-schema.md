# Context File Schema

Use this reference to decide what to write inside `.agent-context/`. Adapt the file set to the repo.

## README.md

Purpose: orient future agents and route them to the right context file.

Include:

- one-paragraph summary of the codebase
- the most important files to read first
- task-specific reading paths
- context freshness date or source note
- warning if analysis was partial

## system-overview.md

Purpose: explain what the system does and why it exists.

Include:

- product, service, library, pipeline, or repo purpose
- primary users or downstream consumers when discoverable
- main capabilities
- boundaries of what this repo does and does not own

## codebase-map.md

Purpose: explain the repository layout by role, not just by name.

Include:

- major directories and what they own
- primary vs peripheral areas
- project/module/package/service boundaries
- entry points and important artifacts
- generated, vendored, or protected areas

## architecture-and-patterns.md

Purpose: reconstruct the developer mental model.

Include:

- architecture style and dependency direction
- important flows and relationships
- design patterns, inheritance, composition, templates, macros, pipelines, or layering
- foundational vs downstream components
- where the architecture is clear and where it is inconsistent

## languages-frameworks-and-tools.md

Purpose: identify the technical stack and tool surfaces.

Include:

- languages and paradigms used
- frameworks and runtimes
- package managers and build systems
- test, lint, format, typecheck, deploy, container, orchestration, and configuration tools
- observed commands and where they came from

## conventions-and-local-practices.md

Purpose: capture the habits future agents should imitate.

Include:

- naming conventions
- file organization conventions
- code style conventions visible in the repo
- testing conventions
- configuration conventions
- documentation conventions
- team-specific practices that differ from ecosystem best practice
- best practices followed, bent, or ignored

## workflows-and-commands.md

Purpose: tell agents how to operate the repo.

Include:

- setup commands
- run/dev commands
- build commands
- test commands
- lint/format/typecheck commands
- verification commands by change type
- commands that are risky, slow, environment-dependent, or unknown

## task-guides.md

Purpose: help future agents approach common work.

Include guides for relevant tasks, such as:

- answering questions
- planning changes
- implementing features
- fixing bugs
- adding new modules, services, models, or artifacts
- generating documentation
- refactoring
- reviewing impact
- mentoring a human developer

Each guide should say what to read first, what patterns to follow, how to verify, and what to avoid.

## risks-unknowns-and-open-questions.md

Purpose: prevent false confidence.

Include:

- risky or fragile areas
- stale, legacy, barely used, or ambiguous areas
- generated or protected files
- secrets and environment hazards
- gaps in docs or tests
- uncertainty that future agents should re-check

## Optional Files

Use these when they make the context clearer:

- `module-map.md`: module ownership and dependencies
- `dependency-map.md`: internal and external dependency relationships
- `data-model.md`: schemas, entities, sources, models, transformations, lineage, or storage
- `api-surface.md`: public endpoints, SDK APIs, CLIs, events, or contracts
- `deployment-runtime.md`: runtime topology, containers, jobs, environments, and release flow
- `testing-strategy.md`: test layers, fixtures, known gaps, and verification guidance
- `domain-glossary.md`: domain terms, acronyms, and business concepts
- `generated-files.md`: generated artifacts and regeneration rules
