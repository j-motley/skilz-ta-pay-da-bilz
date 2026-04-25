# Context Pack Schema

Use this schema when generating `CODEBASE_CONTEXT.md`, `AGENTS.md`, or a combined context pack.

## CODEBASE_CONTEXT.md

Recommended sections:

1. Purpose and product summary
2. Tech stack
3. Repository layout
4. Architecture and module boundaries
5. Runtime and developer workflows
6. Build, lint, test, typecheck, and format commands
7. Key domain concepts
8. Data model and integrations
9. Coding conventions
10. Testing conventions
11. Generated files and protected areas
12. Known hazards and stale assumptions
13. How to verify common change types
14. Open questions

## AGENTS.md

Recommended sections:

1. Agent mission
2. Before editing
3. How to inspect the codebase
4. Implementation rules
5. Testing and verification rules
6. Review and reporting rules
7. Safety and escalation rules
8. Multi-agent coordination rules, if relevant

## AI_DEV_TEAM_OPERATING_GUIDE.md

Recommended sections:

1. Team roles
2. Task intake
3. Planning and decomposition
4. Ownership boundaries
5. Handoff format
6. Integration process
7. Review gates
8. Context refresh protocol

## Role Prompt Fields

Each role prompt should include:

- role mission
- inputs needed
- allowed actions
- required outputs
- handoff format
- escalation triggers
- verification expectations
