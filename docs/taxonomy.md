# Skill Taxonomy

This repository groups skills by the kind of agent capability they create.

## Context Engineering

Context engineering skills produce reusable, task-ready context artifacts for agents. They do more than summarize information: they decide what an agent needs to know, what it should avoid, how it should act, how it should verify work, and when the context should be refreshed.

Use `skills/context-engineering/` for skills that create or maintain:

- codebase context packs
- product or domain context
- architecture maps
- team operating context
- PR, incident, or research context
- durable project memory
- role-specific agent prompts grounded in a context artifact

Context engineering skills should usually be multistage:

1. Define the goal and target users or agents.
2. Gather source evidence.
3. Extract durable context.
4. Generate one or more artifacts.
5. Validate the artifacts against realistic agent tasks.
6. Define a refresh protocol.

## Web Automation

Web automation skills let agents act on websites that have no usable API: they keep authenticated sessions alive, map how pages load their data, and move documents or data out reliably and on a schedule.

Use `skills/web-automation/` for skills that:

- establish and maintain logins (MFA, device trust, bot protection)
- inspect authenticated pages before scraping
- download statements, bills, invoices, or transaction exports
- fill or submit forms on a recurring basis

Web automation skills should:

1. Prefer official APIs or exports when they exist, and say so.
2. Separate authentication from the task, so the task code always receives an authenticated page.
3. Validate every artifact (bytes, headers), and write atomically and idempotently.
4. Never hang unattended; report "needs a human" instead.
5. Keep credentials in the OS keychain, and keep account data out of repositories.

## Current Categories

- `context-engineering/`: skills for producing high-signal context that helps agents work safely and effectively.
- `web-automation/`: skills for durable authenticated sessions, page reconnaissance, and scheduled document and transaction collection from portals such as banks and credit cards.

## Naming

Use lowercase hyphen-case for skill folders. Prefer names that describe the artifact or context being engineered, such as `codebase-context-engineering`, `product-context-engineering`, or `incident-context-engineering`.
