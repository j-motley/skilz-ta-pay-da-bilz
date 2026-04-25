# Validation Rubric

Score each area from 0 to 2.

## Coverage

- 0: Missing major repo areas or commands.
- 1: Covers main areas but leaves important gaps.
- 2: Covers the architecture, workflows, commands, conventions, and risk areas agents need.

## Evidence

- 0: Mostly generic or invented.
- 1: Mix of observed facts and assumptions.
- 2: Grounded in files, configs, docs, commands, or clearly marked assumptions.

## Actionability

- 0: Interesting but not usable for development work.
- 1: Helps with orientation but lacks clear operating rules.
- 2: Enables agents to inspect, edit, verify, and report safely.

## Safety

- 0: Omits worktree, destructive actions, secrets, generated files, or escalation rules.
- 1: Mentions safety but lacks concrete rules.
- 2: Gives explicit safe-editing, escalation, and protected-area guidance.

## Verification

- 0: Does not explain how to verify changes.
- 1: Lists generic verification commands.
- 2: Maps commands and checks to repo-specific change types.

## Multi-Agent Readiness

- 0: No ownership or handoff guidance.
- 1: Mentions roles without coordination rules.
- 2: Defines roles, ownership boundaries, handoffs, and integration responsibilities.

## Passing Bar

A context pack is ready when:

- total score is at least 9 out of 12
- Safety is 2
- Evidence is at least 1
- Verification is at least 1

If Safety is below 2, revise before using the pack for code edits.
