# Context Building Requirements

Use this reference when deciding whether the generated context is doing the real job.

## Mission

Generate codebase context that helps future agents become useful quickly: they should understand what the system is, how it fits together, what conventions matter, how to operate it, where to be careful, and how to choose what to read next.

## Functional Requirements

- Accept a local path or git repository as the target.
- Detect the codebase type and adapt the output structure.
- Discover primary and secondary languages, frameworks, tools, paradigms, and configuration systems.
- Identify whether the target is one project, many projects, or a mixed repository.
- Map major directories, project boundaries, runtime boundaries, data boundaries, and dependency direction.
- Identify primary, peripheral, legacy, generated, vendored, and poorly understood areas.
- Extract naming, organization, testing, configuration, design, and local team conventions.
- Identify observed commands for setup, build, test, lint, format, run, deploy, and verification when available.
- Generate `.agent-context/` files with task-ready context.
- Create or update a root `AGENTS.md` discovery hook when useful.
- Mark assumptions, unknowns, and partial analysis honestly.

## Nonfunctional Requirements

- Proportionality: small repos should get small context; large repos should get layered context.
- Evidence: claims should trace back to observed repository signals or be labeled as inference.
- Portability: do not assume one ecosystem; support apps, services, libraries, data projects, infrastructure, containers, and mixed-language repos.
- Agent usefulness: write for agents who must answer, plan, implement, debug, document, review, or mentor.
- Safety: identify files, commands, and areas future agents should not touch casually.
- Maintainability: context should be easy to refresh incrementally.

## Quality Questions

- Would a cold-start agent know where to begin?
- Would it know what patterns to imitate?
- Would it know what areas are central vs peripheral?
- Would it know how to verify a change?
- Would it know what not to trust yet?
- Would it avoid overconfident claims?
- Would it help a human developer preserve comprehension of the system?
