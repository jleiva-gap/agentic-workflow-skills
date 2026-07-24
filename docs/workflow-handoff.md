# Workflow Handoff and Resume

This package uses approved artifacts, not chat history, as the boundary between workflow stages and between different AI tools.

## When to use a handoff

Use a handoff when any of the following is true:

- work will move from Codex to Copilot, Claude, or another reviewer;
- the current session may be interrupted;
- implementation needs to pause after planning or partial progress;
- you want a clean checkpoint between stages, such as after spec approval, plan approval, implementation, or self QA review;
- you want a separate artifact that can be opened later without reading the full chat.

This handoff is for implementation continuation and fix-back work. It is not the same thing as the independent QA review packet, which only needs the story, code, and evidence.
There is not a separate built-in fix-back handoff type; when QA finds issues, refresh the implementation handoff from the findings report and current repository state.
If the current context has one obvious review findings report, the handoff skill can infer it when you ask to refresh from findings. If there is more than one plausible report, it should ask for the exact path.

If you want a dedicated fix-back planning entrypoint, keep it thin and let it reuse the existing planning workflow rather than introducing a second planning engine. The handoff should point at the findings report and the next planning step, not duplicate the review findings.
The `self-qa-review` workflow is the wrapper that should drive that review-and-handoff sequence.

## Create the handoff

Use the `create-handoff` skill when you want the current session state turned into a compact resume-ready artifact.

Typical usage:

```text
$create-handoff process_id=2026-07-17-DMS-1228
```

The skill should:

- read the approved artifacts and current git state;
- capture only the evidence needed to resume;
- write or refresh `docs/superpowers/handoffs/<story-id>-handoff.md`;
- include a process id that identifies the exact plan/spec pair;
- avoid duplicating long explanations already present in the spec or plan.

If the process id is not obvious from the current context, the skill should ask a single focused English clarification question for the exact process id or missing path instead of guessing.

## Verify the handoff

Use the `verify-handoff` skill before resuming if you want to confirm the handoff still matches the repo state.

Typical usage:

```text
$verify-handoff process_id=2026-07-17-DMS-1228
```

The skill should:

- compare the handoff against the approved artifacts and git state;
- report stale, missing, or contradictory fields;
- say whether the handoff is safe to reuse, needs refresh, or cannot be reconciled;
- avoid rewriting the handoff unless you explicitly ask it to refresh.

## What the handoff should contain

Create the handoff from the bundled `templates/cross-tool-handoff-template.md`. In source, the canonical template lives at `src/shared/templates/cross-tool-handoff-template.md`.

At minimum, fill in:

- process id;
- story id and source;
- approved spec path;
- approved plan path;
- branch name;
- baseline commit;
- working tree state;
- first pending task;
- required skills;
- the next command or entrypoint the other tool should use;
- assumptions and risks;
- last verified command and result.

The handoff should be readable on its own. Do not depend on chat context to explain missing facts.

## Recommended workflow

1. Use `story-to-plan` to create the approved spec, approved plan, and handoff artifact.
2. Review the written spec and plan before implementation starts.
3. Use `implement-approved-plan` to begin task-by-task execution.
4. Update the progress artifact as tasks are verified.
5. Run the self QA review packet if you want an external-style review pass.
6. If the review finds issues, use the findings report to refresh the implementation handoff before resuming fixes.
7. If work pauses, or you want to move between stages or tools, leave the implementation handoff artifact intact and capture the latest verified state in the progress artifact.

## How to resume

To resume a paused process:

1. Start from the process id, for example `process_id=2026-07-17-DMS-1228`.
2. Resolve the approved plan, spec, handoff artifact, and progress artifact from that id.
3. Check git status and the current branch.
4. Compare the plan checkboxes with the actual code and tests.
5. Identify the first genuinely incomplete task.
6. Confirm the last verified command and result in the progress or handoff record.
7. Continue with `resume-approved-plan`.

If the handoff looks stale or incomplete, rerun `create-handoff` first so the next session starts from the latest verified state. If you want a safety check before resuming, run `verify-handoff` first. If either skill asks for a path, provide the exact approved artifact path and rerun it.

When you need a quick reference in chat, use the process id first. Add the handoff or plan path only when artifact discovery is ambiguous.

## What `resume-approved-plan` should do

The resume workflow should:

- reconstruct state from artifacts and git;
- ignore stale chat summaries when they conflict with the files;
- preserve verified work;
- continue from the first pending task that is not already done in code;
- stop if the plan and code cannot be reconciled safely.

## Practical rule

If the handoff does not let a new tool continue without asking for the whole story again, it is incomplete.
