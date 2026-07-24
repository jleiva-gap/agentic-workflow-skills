# Input Contract

The workflows accept inputs in this order:

1. named `key=value` fields;
2. positional values;
3. repository discovery;
4. inline story text;
5. one focused English question only if the workflow still cannot proceed safely.

## Named input

Preferred format:

```text
story_id=DMS-1228
story_source=.plans/DMS-1228.md
notes_source=.plans/DMS-1228-implementation-notes.md
related_paths=src/ModuleA,tests/ModuleA.Tests
constraints=.NET 10; preserve API compatibility
test_command=dotnet test
```

## Positional fallback

```text
<story-id> <story-source> [notes-source]
```

For handoff, verification, and resume workflows, the preferred positional value is:

```text
<process-id>
```

Use explicit paths after the process id only when the user wants to override discovery.

Friendly artifact aliases are accepted for override mode:

```text
plan=<path> or plan_path=<path>
spec=<path> or spec_path=<path>
handoff=<path> or handoff_path=<path>
progress=<path> or progress_path=<path>
findings=<path> or findings_report=<path>
```

## Required resolution rules

- `story_id` is required for new planning.
- `story_source` is required when a readable file path is provided.
- If `story_source` is missing and `story_id` is present, look for `.plans/<story-id>.md`.
- If the file is missing or unreadable, accept inline story text instead of treating the source as empty.
- `notes_source` is optional.
- Relative paths are resolved from the repository root.
- Never interpret an inaccessible path as empty content.
- Reject conflicting duplicate values rather than guessing.
- Preserve the exact story identifier and source paths in generated artifacts.

## Process id resolution

Use `process_id` as the friendly input for existing workflow artifacts.

Resolution order:

1. named `process_id`;
2. first positional value when it looks like `YYYY-MM-DD-<story-id>`;
3. named `story_id` as a convenience shortcut;
4. first positional value as a `story_id` shortcut only when it does not look like a path.

When a full process id is available, resolve standard artifacts from these defaults:

```text
docs/superpowers/specs/<process-id>-design.md
docs/superpowers/plans/<process-id>.md
docs/superpowers/handoffs/<story-id>-handoff.md
docs/superpowers/progress/<story-id>-progress.md
```

For a `story_id` shortcut, find matching plan files under `docs/superpowers/plans/`. If exactly one plan matches the story id, use that plan filename stem as the process id. If multiple plans match, ask for the exact process id or plan path.

Explicit artifact paths always override process id discovery for that artifact. Reject conflicts when an explicit path belongs to a different process id unless the user confirms the override.

## English-only rule

All prompts, questions, artifacts, and reports are written in English, even when the input material is in another language, unless the user explicitly requests otherwise.
