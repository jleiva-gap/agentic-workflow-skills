# Agentic Workflow Manual

This manual explains how to use the agentic workflow skills as a developer-facing process. It covers the full flow, the handoff files, resumption, verification, and common scenarios so you can move between tools without reconstructing context from chat.

For a visual companion, see [docs/agentic-workflow-diagrams.md](agentic-workflow-diagrams.md).

## The core idea

Use artifacts as the source of truth.

The workflow is designed so that each stage writes a small number of files that the next stage can read:

- `docs/superpowers/specs/` for approved design intent
- `docs/superpowers/plans/` for implementation sequencing
- `docs/superpowers/handoffs/` for compact resume snapshots
- `docs/superpowers/progress/` for verified completion state

Chat is useful for coordination, but it is not the durable record. The manual, the spec, the plan, and the handoff are what let another agent continue without guessing.

## Process id

The process id is the short code that identifies the exact spec/plan pair being resumed.

Recommended format:

- use the plan filename stem: `YYYY-MM-DD-<story-id>`

Example:

- plan: `docs/superpowers/plans/2026-07-17-DMS-1228.md`
- spec: `docs/superpowers/specs/2026-07-17-DMS-1228-design.md`
- process id: `2026-07-17-DMS-1228`

Why this helps:

- you can refer to one short code in chat instead of repeating full paths
- the code maps directly to the exact plan/spec pair
- the handoff becomes easier to scan and reuse

Use the process id as the default input for `create-handoff`, `verify-handoff`, and `resume-approved-plan`. Use explicit paths only when discovery is ambiguous or you need to pin an artifact.

## Skill map

- `story-to-plan`: turn a story into an approved spec, plan, and initial handoff
- `implement-approved-plan`: execute an approved plan task by task
- `create-handoff`: compress the current verified state into a resume-ready handoff
- `verify-handoff`: check whether a handoff is still safe to reuse
- `resume-approved-plan`: continue from an approved plan after interruption or transfer
- `self-qa-review`: run a review variant and turn findings into a remediation handoff when needed

## The standard flow

1. Start with `story-to-plan`.
2. Review and approve the spec.
3. Review and approve the plan.
4. Implement with `implement-approved-plan`.
5. Record progress only after verification.
6. Run the self QA review gate before the work is treated as finished.
7. If you need a checkpoint, pause, or tool transfer at any stage boundary, run `create-handoff`.
8. Before resuming, optionally run `verify-handoff`.
9. Continue with `resume-approved-plan`.

## What each skill does

### `story-to-plan`

Use this when you have a feature request, story, or bug fix that still needs design and sequencing.

What it produces:

- approved design spec
- approved implementation plan
- handoff scaffold

When to use it:

- new feature work
- ambiguous requests
- work that needs a design gate before coding

Example:

```text
$story-to-plan story_id=DMS-1228 story_source=.plans/DMS-1228.md
```

### `create-handoff`

Use this when the session is about to pause or move to another tool.

What it does:

- reads the approved artifacts and current git state
- captures the smallest useful resume snapshot
- writes or refreshes the handoff artifact
- records the process id for the specific plan/spec pair
- infers paths when the target is unambiguous
- asks for a missing path only when inference is unsafe

You can also use it between stages when you want to preserve a clean checkpoint, for example:

- after `story-to-plan` finishes the approved spec and plan;
- after an implementation milestone is verified;
- after self QA review has passed;
- before a different tool takes over the next stage.

Example:

```text
$create-handoff process_id=2026-07-17-DMS-1228
```

If the current context already points to one obvious process, the skill can infer it. If there are multiple plausible matches, provide the exact process id or artifact path the skill asks for.

### `verify-handoff`

Use this right before resuming if you want a consistency check.

What it does:

- compares the handoff against the plan, spec, progress file, and git state
- reports stale, missing, or contradictory fields
- says whether the handoff is safe to reuse, needs refresh, or cannot be reconciled safely

Example:

```text
$verify-handoff process_id=2026-07-17-DMS-1228
```

### `implement-approved-plan`

Use this when the plan is already approved and you are ready to change code.

What it does:

- checks repository state
- runs baseline verification
- implements one task at a time
- updates progress only after evidence exists

Example:

```text
$implement-approved-plan docs/superpowers/plans/2026-07-17-DMS-1228.md
```

### `resume-approved-plan`

Use this when work was interrupted and you need to continue safely.

What it does:

- reads the approved plan, handoff, and progress artifacts
- compares the plan to the current code and tests
- resumes from the first genuinely incomplete task
- refuses to trust stale chat summaries over file evidence

Example:

```text
$resume-approved-plan process_id=2026-07-17-DMS-1228
```

Explicit path mode remains available:

```text
$resume-approved-plan process_id=2026-07-17-DMS-1228 plan=docs/superpowers/plans/2026-07-17-DMS-1228.md handoff=docs/superpowers/handoffs/DMS-1228-handoff.md
```

### Self QA review

Use this as an independent review pass after implementation is verified.

What it does:

- checks the finished work against the story or acceptance criteria;
- applies a review skill for a second pass on completeness, correctness, and edge cases;
- behaves like an external reviewer, using the story and the code rather than the implementation plan;
- confirms whether the result is story-complete or needs more changes.

If the review produces findings, the findings report becomes the input for a fix-back handoff. There is not a separate built-in fix-back artifact type; the implementation handoff is refreshed from the findings report and the current repo state.
If there is only one obvious findings report in the current context, you can ask the tool to refresh the handoff from findings without typing the report filename. If there is more than one plausible report, the tool should ask for the exact path.

Use `self-qa-review` when you want that review pass to also produce the remediation handoff.

Recommended split:

- keep the review heuristics in the dedicated review skill pack;
- keep any self-QA orchestration wrapper in `agentic-workflow-skills/src/skills/`;
- use the wrapper to prompt for review type, story source, output location, token budget, and test policy;
- let the wrapper emit a findings report path that can be consumed by the next fix-back step.

If the findings point to a fix that needs replanning, feed the findings report into the next planning step rather than inventing a separate planning engine. In practice, that means either:

- a thin `remediate-story` wrapper that prepares the fix-back inputs and then delegates to the planning workflow; or
- a direct `story-to-plan` run with the findings report supplied as the remediation context.

Typical review options:

- `requesting-code-review` for a structured code review pass
- `critical-review-agent` for a strict evidence-based review
- `critical-review-with-validation-agent` when you want a second-pass validator
- `self-qa-review` when you want the review pass to lead into a fix-back checkpoint

Example:

```text
Run verification-before-completion, then request a code review against the current branch using the story and evidence only.
```

## How the artifacts interact

### Spec

The spec defines the behavior that should exist when the work is done.

### Plan

The plan defines the order of implementation tasks.

### Handoff

The handoff is the compact resume snapshot. It should answer:

- what is being built
- what is already approved
- what is already verified
- what is next
- what is blocked
- what evidence can be trusted

### Progress

The progress file records verified task completion and supporting evidence.

## Scenario cookbook

### Scenario 1: starting a new feature

Use this path when the request is still a design problem.

1. Run `story-to-plan`.
2. Approve the spec.
3. Approve the plan.
4. Let `story-to-plan` produce the initial handoff.

Why this works:

- design is separated from implementation
- the approved artifacts become the durable source of truth

### Scenario 2: implementing an approved plan

Use this path when the design is already approved and the code changes are next.

1. Open the plan.
2. Run `implement-approved-plan`.
3. Follow the task order exactly.
4. Update progress after verification.

Why this works:

- it prevents scope drift
- it keeps the plan and code aligned

### Scenario 3: pausing mid-work

Use this path when the session is about to end or you want to move to another tool.

1. Make sure the last completed task is verified.
2. If you want a final independent review, run `self-qa-review`.
3. If the review passes, run `create-handoff`.
4. If the review finds issues, refresh the implementation handoff from the findings report instead.
5. Save the updated handoff.
6. Leave the progress file current.

Why this works:

- the next session starts from evidence, not memory
- the handoff is compact enough to reopen quickly
- findings can become the starting point for the fix-back session without re-litigating the review
- the findings report can be inferred when there is a single obvious report in the current context

### Scenario 4: resuming after interruption

Use this path when the previous session ended and you want to continue.

1. Start with the process id for the work you want to resume.
2. Run `verify-handoff` if the current state might have changed.
3. If the handoff is still valid, run `resume-approved-plan` with the same process id.
4. Continue from the first incomplete task.

Why this works:

- stale progress is detected before coding starts
- verified work is preserved
- the review pass is independent and the implementation handoff remains separate from it
- if QA found issues, the fix-back handoff points directly at the findings report

### Scenario 5: switching tools

Use this path when the work started in one AI CLI and will continue in another.

1. Ensure the handoff exists.
2. Ensure the plan and progress files are current.
3. Share the process id with the next tool.
4. Run `verify-handoff` if you want a safety check.
5. Resume in the new tool with `resume-approved-plan process_id=<process-id>`.

When you reference the work in chat, use the process id first. Add explicit paths only when the next agent needs to override discovery.

Why this works:

- the workflow is artifact-driven
- the next tool does not need the original chat transcript

### Scenario 6: stale or contradictory handoff

Use this path when the handoff no longer matches the repo.

1. Run `verify-handoff`.
2. Review the mismatch.
3. Refresh with `create-handoff` if the change is small and safe.
4. Stop and reconcile the plan or spec if the mismatch is structural.

Why this works:

- it prevents resuming from false assumptions
- it makes divergence explicit

## Quick decision guide

- If the request is unclear or still needs design, use `story-to-plan`.
- If the plan is approved and coding should start, use `implement-approved-plan`.
- If you need a compact snapshot before pausing, use `create-handoff`.
- If you need to check whether the snapshot is still valid, use `verify-handoff`.
- If you need to continue from a paused state, use `resume-approved-plan`.
- For handoff, verify, and resume, start with `process_id` unless the artifact set is ambiguous.

## Recommended habit

At the end of each verified milestone:

1. Update progress.
2. If you want an external-style check, run the self QA review packet.
3. If fixes are needed, refresh the implementation handoff from the findings report.
4. Verify the handoff if the work may continue in another session or tool.

That habit keeps restart cost low and reduces context loss.

## Host reminders

- Codex uses `$skill-name`
- Copilot uses `/skill-name`
- Claude Code uses `/skill-name`

The underlying workflow is the same across hosts. Only the invocation syntax changes.
