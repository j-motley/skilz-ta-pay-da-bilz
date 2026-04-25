# Validation Rubric

Score each area from 0 to 2.

## Codebase Understanding

- 0: Does not explain what the codebase is or does.
- 1: Gives a basic summary but misses important system boundaries.
- 2: Clearly explains purpose, ownership boundaries, primary areas, and peripheral or unrelated areas.

## Relationship Mapping

- 0: Mostly lists files or folders without explaining relationships.
- 1: Identifies major areas but leaves dependency direction or runtime/data flow unclear.
- 2: Explains how important components, projects, modules, services, models, pipelines, or artifacts relate.

## Stack And Paradigms

- 0: Misses major languages, tools, frameworks, or paradigms.
- 1: Lists stack elements but does not explain their role.
- 2: Identifies languages, frameworks, tools, configuration systems, containers, and relevant programming or modeling paradigms by role.

## Conventions And Local Practices

- 0: Generic advice with little repo-specific convention detail.
- 1: Captures obvious conventions but misses team-specific or non-obvious patterns.
- 2: Captures naming, organization, testing, configuration, design, and local practices future agents should imitate or question.

## Evidence And Uncertainty

- 0: Mostly invented or unsupported claims.
- 1: Mix of observed facts and assumptions.
- 2: Grounded in files, configs, docs, commands, dependencies, naming patterns, or clearly marked inference and unknowns.

## Task Usefulness

- 0: Not useful for a future agent doing real work.
- 1: Helps with orientation but lacks task-specific guidance.
- 2: Gives clear reading paths and task guidance for answering questions, planning, implementing, debugging, documenting, or mentoring.

## Safety And Risk

- 0: Omits generated files, secrets, fragile areas, stale areas, or protected paths.
- 1: Mentions risk generally.
- 2: Gives concrete warnings about risky, stale, generated, legacy, environment-dependent, or poorly understood areas.

## Verification

- 0: Does not explain how to verify work.
- 1: Lists generic or incomplete commands.
- 2: Maps observed or inferred commands/checks to common change types and marks unknown or environment-dependent verification honestly.

## Passing Bar

A context pack is ready when:

- total score is at least 12 out of 16
- Evidence And Uncertainty is at least 1
- Task Usefulness is at least 2
- Safety And Risk is at least 1

If Task Usefulness is below 2, revise before relying on the context for agent onboarding.
