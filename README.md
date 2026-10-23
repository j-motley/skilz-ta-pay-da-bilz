# skilz-ta-pay-da-bilz

A library of portable AI agent skills. Each skill is a folder with a `SKILL.md`: YAML front matter (`name`, `description`) followed by Markdown instructions, plus optional `references/`, `templates/`, and `agents/` files. This is the open Agent Skills layout, so the same skill works with any model or agent harness.

## Skills

| Category | Skill | What it does |
|---|---|---|
| context-engineering | [codebase-context-engineering](skills/context-engineering/codebase-context-engineering/SKILL.md) | Builds `.agent-context/` packs so agents onboard to a codebase quickly |
| web-automation | [authenticated-browser-session](skills/web-automation/authenticated-browser-session/SKILL.md) | Durable logins behind MFA and bot protection: real browser, persistent profile, auth ladder |
| web-automation | [authenticated-page-recon](skills/web-automation/authenticated-page-recon/SKILL.md) | Maps how authenticated pages load their data, then briefs an LLM to write one extraction function |
| web-automation | [financial-statement-collection](skills/web-automation/financial-statement-collection/SKILL.md) | Scheduled, de-duplicated downloads of bank and card statements and transaction exports |

See [docs/taxonomy.md](docs/taxonomy.md) for how skills are grouped.

## Using a skill

- **Claude Code**: copy or symlink the skill folder to `.claude/skills/<name>/` (for one project) or `~/.claude/skills/<name>/` (for all projects).
- **Other harnesses that read `SKILL.md`**: point them at the skill folder. `agents/openai.yaml` holds display metadata for OpenAI/Codex-style harnesses.
- **Any other model or chat**: paste `SKILL.md` into the system prompt or the conversation, and attach the `references/` files it names when the task needs them.

## Skill anatomy

```
skills/<category>/<skill-name>/
  SKILL.md          # required: front matter + the workflow an agent follows
  references/       # loaded on demand: detailed algorithms, schemas, checklists
  templates/        # files to copy and fill in
  agents/           # optional harness-specific metadata
```

## Writing skills here

- `description` decides when an agent loads the skill. Say what it does **and** when to use it, with the trigger words a user would actually type.
- Keep `SKILL.md` short and operational. Push depth into `references/` and say when to read each file.
- Stay model- and vendor-neutral. Where a skill has a reference implementation, describe the pattern well enough to rebuild it without that implementation.
- Never commit credentials, account data, recon dumps, or personal paths.
