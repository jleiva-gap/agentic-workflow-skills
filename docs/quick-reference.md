# Agentic Workflow Quick Reference

Use this guide when you need the shortest practical reference for the flow, handoffs, self QA, review skills, and skill parameters. For scenario-based skill chains, see [docs/skill-cheat-sheet.md](skill-cheat-sheet.md).

## Host Invocation

| Host | Invocation style | Example |
| --- | --- | --- |
| Codex | `$skill-name` | `$story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |
| GitHub Copilot | `/skill-name` | `/story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |
| Claude Code | `/skill-name` | `/story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |

## Standard Flow

1. `story-to-plan` turns a story into an approved design spec, approved implementation plan, and initial handoff.
2. `implement-approved-plan` executes the approved plan task by task.
3. Progress is recorded only after verification evidence exists.
4. `self-qa-review` runs an independent review after implementation.
5. If self QA finds issues, use the findings report to refresh the implementation handoff with `create-handoff`.
6. If work pauses or moves to another tool, run `create-handoff`.
7. Before trusting an old handoff, run `verify-handoff`.
8. Continue interrupted work with `resume-approved-plan`.

## Artifacts

| Artifact | Default path | Purpose |
| --- | --- | --- |
| Design spec | `docs/superpowers/specs/YYYY-MM-DD-<story-id>-design.md` | Approved behavior and constraints |
| Plan | `docs/superpowers/plans/YYYY-MM-DD-<story-id>.md` | Ordered implementation tasks |
| Handoff | `docs/superpowers/handoffs/<story-id>-handoff.md` | Compact cross-tool resume snapshot |
| Progress | `docs/superpowers/progress/<story-id>-progress.md` | Verified task completion evidence |
| Review findings | Chosen review output path | Evidence-backed QA or review results |

Use the plan filename stem as the process id:

```text
docs/superpowers/plans/2026-07-17-STORY-001.md
process_id=2026-07-17-STORY-001
```

## Handoff Rules

`story-to-plan` creates the first handoff scaffold after planning artifacts are approved.

Run `create-handoff`:

- after planning, when another tool will implement;
- after a verified implementation milestone;
- before pausing;
- before switching between Codex, Copilot, Claude, or a human maintainer;
- after self QA passes and you want a final resume snapshot;
- after self QA finds issues, using the findings report as fix-back context.

Run `verify-handoff`:

- before resuming from an old handoff;
- after branch, plan, spec, progress, or git state may have changed;
- when plan checkboxes and current code might disagree.

Do not use chat history as the source of truth. Resume from the spec, plan, progress, handoff, and current git state.

## Self QA Process

Use `self-qa-review` after implementation and verification. It is independent of the implementation plan: it should check the story or acceptance criteria against the code, diff, tests, and evidence.

Self QA flow:

1. Provide the story file and review type.
2. The wrapper routes to the selected review skill.
3. The review writes a findings report.
4. If there are no actionable findings, no remediation handoff is needed.
5. If there are actionable findings, run or let the wrapper run `create-handoff` so the implementation handoff points at the findings report.
6. Feed the story plus findings back through planning when fixes need design or task sequencing.

Recommended default:

```text
$self-qa-review story_file=.plans/STORY-001.md review_type=critical-with-validation
```

## Review Skills

| Skill | Use when |
| --- | --- |
| `critical-review` | You need strict evidence-based review against the story and acceptance criteria. |
| `adversarial-review` | You want edge cases, abuse cases, regressions, hidden coupling, or failure modes challenged. |
| `critical-adversarial-review` | You want one pass that combines acceptance-criteria review and adversarial pressure testing. |
| `review-findings-validator` | You already have a review report and need findings validated, deduplicated, downgraded, or rejected. |
| `critical-review-with-validation` | You want a strict review followed by a validation pass before the report is trusted. |
| `self-qa-review` | You want review orchestration plus a remediation handoff when findings exist. |

Review outputs should use `templates/review-findings-template.md`. Every confirmed finding should include a stable ID, severity, confidence, validation status, acceptance criterion, evidence, concrete failure path, impact, correction direction, and required verification.

## Parameters By Skill

### `story-to-plan`

Typical:

```text
$story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md notes_source=.plans/STORY-001-notes.md
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `story_id` | Yes | Stable story or ticket identifier preserved in generated artifacts. |
| `story_source` | Usually | Path to the story file, or inline story text when no readable file exists. If omitted, the skill first tries `.plans/<story-id>.md`. |
| `notes_source` | No | Optional implementation notes or context file. |
| `related_paths` | No | Hints for source, tests, docs, or modules to inspect. |
| `constraints` | No | Extra constraints such as compatibility, security, dependency, or release requirements. |
| `test_command` | No | Suggested verification command to consider during planning. |

Outputs: approved spec, approved plan, initial handoff.

### `implement-approved-plan`

Typical:

```text
$implement-approved-plan docs/superpowers/plans/2026-07-17-STORY-001.md
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `<plan-path>` | Yes | Approved implementation plan path. |
| `<spec-path>` | When not linked by plan | Approved design spec path. |

Outputs: task-by-task code changes, updated plan checkboxes, progress artifact, verification evidence.

### `resume-approved-plan`

Typical:

```text
$resume-approved-plan process_id=2026-07-17-STORY-001
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `process_id` | Preferred | Plan filename stem used to resolve spec, plan, handoff, and progress. |
| `story_id` | Optional shortcut | Used only when it maps to exactly one process id. |
| `plan` or `plan_path` | Override | Explicit approved plan path. |
| `spec` or `spec_path` | Override | Explicit approved design spec path. |
| `handoff` or `handoff_path` | Override | Explicit handoff path. |
| `progress` or `progress_path` | Override | Explicit progress artifact path. |

Outputs: reconciled resume state, updated progress artifact, new verification evidence, or a blocker report.

### `create-handoff`

Typical:

```text
$create-handoff process_id=2026-07-17-STORY-001
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `process_id` | Preferred | Resolves the standard spec, plan, handoff, and progress paths. |
| `story_id` | Optional shortcut | Used only when it maps to exactly one process id. |
| `plan` or `plan_path` | Override | Explicit plan path. |
| `spec` or `spec_path` | Override | Explicit spec path. |
| `progress` or `progress_path` | Override | Explicit progress path. |
| `findings` or `findings_report` | Optional | Review findings report used to refresh a fix-back handoff. |

Outputs: compact handoff artifact and summary of evidence used.

### `verify-handoff`

Typical:

```text
$verify-handoff process_id=2026-07-17-STORY-001
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `process_id` | Preferred | Resolves standard handoff, plan, spec, and progress paths. |
| `story_id` | Optional shortcut | Used only when it maps to exactly one process id. |
| `handoff` or `handoff_path` | Override | Explicit handoff path. |
| `plan` or `plan_path` | Override | Explicit approved plan path. |
| `spec` or `spec_path` | Override | Explicit approved spec path. |
| `progress` or `progress_path` | Override | Explicit progress path. |

Outputs: reuse, refresh, or stop recommendation with mismatch details.

### `self-qa-review`

Typical:

```text
$self-qa-review story_file=.plans/STORY-001.md review_type=critical-with-validation
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `story_file` | Yes | Story or acceptance-criteria source for the review. |
| `review_type` | Required unless obvious or `review_file` is supplied | One of `critical`, `adversarial`, `critical-adversarial`, or `critical-with-validation`. |
| `review_file` | Optional | Existing findings report to reuse for remediation instead of generating a new review. |
| `repo_root` | Optional | Repository root override. |
| `output_dir` | Optional | Directory for review or handoff outputs. |
| `base_ref` | Optional | Git ref for diff-based review. |
| `review_scope` | Optional | Limits review to specific files, modules, or behavior. |
| `token_budget` | Optional | Budget guidance for the review pass. |
| `run_tests` | Optional | Test policy for the review pass. |
| `commands` | Optional | Commands the reviewer may run or inspect. |
| `agent_name` | Optional | Label for the reviewing agent in artifacts. |

Outputs: review findings report, remediation handoff when findings require a fix-back, and next-step recommendation.

### `critical-review`

Typical:

```text
$critical-review story_file=.plans/STORY-001.md base_ref=main
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `story_file` | Yes | Story, ticket, or change request to review against. |
| `repo_root` | Optional | Repository root override. |
| `output_dir` | Optional | Directory for review report output. |
| `base_ref` | Optional | Git ref for diff comparison. |
| `review_scope` | Optional | Files, modules, or behavior to review. |
| `agent_name` | Optional | Reviewer label for artifacts. |
| `run_tests` | Optional | Whether tests may be run as part of validation. |
| `output_mode` | Optional | Report detail/format preference. |
| `token_budget` | Optional | Budget guidance for the review. |

Outputs: review report, acceptance-criteria status, confirmed findings, verification record.

### `adversarial-review`

Typical:

```text
$adversarial-review story_file=.plans/STORY-001.md review_scope=src/Feature,tests/Feature.Tests
```

Parameters are the same as `critical-review`.

Outputs: adversarial risk report, evidence-backed findings, and unconfirmed risks.

### `critical-adversarial-review`

Typical:

```text
$critical-adversarial-review story_file=.plans/STORY-001.md base_ref=main
```

Parameters are the same as `critical-review`.

Outputs: combined critical and adversarial review report, evidence-backed findings, and remaining risks.

### `review-findings-validator`

Typical:

```text
$review-findings-validator story_file=.plans/STORY-001.md review_report=docs/superpowers/reviews/STORY-001-review.md
```

Parameters:

| Parameter | Required | Meaning |
| --- | --- | --- |
| `story_file` | Yes | Story or acceptance-criteria source. |
| `review_report` | Yes | Existing findings report to validate. |
| `repo_root` | Optional | Repository root override. |
| `output_dir` | Optional | Directory for validation output. |
| `base_ref` | Optional | Git ref for diff comparison. |
| `review_scope` | Optional | Files, modules, or behavior to validate. |
| `agent_name` | Optional | Validator label for artifacts. |
| `run_tests` | Optional | Whether tests may be run as part of validation. |

Outputs: validation summary, final triage table, actionable validated findings, discarded or downgraded findings.

### `critical-review-with-validation`

Typical:

```text
$critical-review-with-validation story_file=.plans/STORY-001.md base_ref=main
```

Parameters are the same as `critical-review`.

Outputs: strict review with second-pass validation, final confirmed findings, discarded or downgraded findings, verification record.

## Input Resolution Notes

- Named `key=value` inputs take precedence over positional values.
- Relative paths resolve from the repository root.
- Inaccessible paths are blockers, not empty content.
- Conflicting duplicate values should be rejected instead of guessed.
- For handoff, verify, and resume workflows, prefer `process_id` first and explicit paths only when discovery is ambiguous.

## Quick Choices

| Situation | Use |
| --- | --- |
| New story needs design and plan | `story-to-plan` |
| Approved plan is ready for coding | `implement-approved-plan` |
| Pause or switch tools | `create-handoff` |
| Check an old handoff | `verify-handoff` |
| Continue interrupted work | `resume-approved-plan` |
| Final independent QA with fix-back support | `self-qa-review` |
| Strict code review | `critical-review` |
| Failure-mode review | `adversarial-review` |
| Strict plus failure-mode review | `critical-adversarial-review` |
| Validate existing findings | `review-findings-validator` |
| Strict review plus validation | `critical-review-with-validation` |
