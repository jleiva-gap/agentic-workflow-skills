# Superpowers Dependency Map

The wrappers orchestrate dependencies. They do not duplicate them.

## story-to-plan

Required:

- `brainstorming`
- `writing-plans`

Supporting:

- `writing-skills`

## implement-approved-plan

Required:

- `using-git-worktrees`
- `test-driven-development`
- `verification-before-completion`

Execution:

- preferred: `subagent-driven-development`
- fallback: `executing-plans`

## resume-approved-plan

Required:

- `verification-before-completion`

Execution:

- preferred: `subagent-driven-development`
- fallback: `executing-plans`

## create-handoff

Required:

- `verification-before-completion`

## verify-handoff

Required:

- `verification-before-completion`

## Resolution rules

- Resolve `orion:<name>` first when the host exposes the Orion namespace.
- Resolve `superpowers:<name>` next when that namespace is available.
- Permit an exact unqualified `<name>` fallback.
- Reject approximate or semantically similar skill names.
- Report all missing required dependencies in one concise English error.
- Never silently replace Superpowers with an improvised internal workflow.
