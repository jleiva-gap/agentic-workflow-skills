# resume-approved-plan

## Overview

Resume an approved plan safely after interruption, context loss, or transfer to another coding agent. Reconstruct state from artifacts and git, not from chat history.

## Required inputs

- `process_id` for the common case
- approved plan path when provided as an override
- approved design path when provided as an override or not already linked by the plan
- handoff artifact when provided as an override
- progress artifact when provided as an override or available

Prefer `process_id` first. If a full process id is provided, resolve the standard plan, spec, handoff, and progress paths from it. If only `story_id` is provided, resolve the process only when exactly one matching plan exists. Explicit paths remain supported as overrides.

If the process id or artifact paths cannot be resolved unambiguously, ask one focused English question for the exact process id or missing path before resuming.

## Required flow

1. Read repository instructions and the bundled shared contracts under `references/`.
2. Resolve `process_id`, `story_id`, approved plan, approved design, handoff, and progress paths using the shared process id rules.
3. Read the approved design, the approved plan, the handoff when present, and the progress artifact when present.
4. Inspect git status, branch, recent commits, and current diff.
5. Resolve the handoff process id to the specific approved plan and spec pair being resumed.
6. Compare plan checkboxes with actual code and tests.
7. Identify the last verified completed task, any partially implemented task, the first genuinely pending task, and any plan divergence.
8. Run the smallest relevant test set first.
9. Do not trust progress text or checkboxes without evidence.
10. Preserve prior verification evidence and add new evidence instead of rewriting history.
11. Continue through the same execution mechanism as `implement-approved-plan`.
12. Stop if the current state cannot be reconciled safely.
13. Run `verification-before-completion` before final completion.

## Hard rules

- Do not repeat verified completed work.
- Do not discard uncommitted work without explicit approval.
- Do not assume chat history is available.
- Do not claim a task is complete if evidence contradicts it.
- Do not hide plan divergence.
- Do not demand explicit paths when a process id resolves the artifact set unambiguously.
- Use English for resumed-state analysis, blockers, progress updates, and summaries.

## Expected outputs

- resumed execution state
- updated progress artifact
- new verification evidence
- blocker report when safe reconciliation is not possible
