# verify-handoff

## Overview

Verify that a handoff artifact still matches the approved plan, spec, progress, and repository state before a session is resumed. This workflow does not change production code.

## Required inputs

- `process_id` for the common case
- handoff artifact path when provided as an override
- approved implementation plan path when provided as an override
- approved design path when provided as an override
- current progress artifact when provided as an override or available
- current repository state from git

Prefer `process_id` first. If a full process id is provided, resolve the standard handoff, plan, spec, and progress paths from it. If only `story_id` is provided, resolve the process only when exactly one matching plan exists. Explicit paths remain supported as overrides.

If the specific handoff, plan, spec, or progress path is not provided and cannot be inferred unambiguously from the process id or current repository state, ask a single focused English clarification question instead of guessing.

The process id should normally match the approved plan filename stem `YYYY-MM-DD-<story-id>` so the handoff can be mapped back to the exact spec/plan pair.

## Required flow

1. Read repository instructions and the bundled shared contracts under `references/`.
2. Resolve `process_id`, `story_id`, handoff, approved plan, approved design, and progress paths using the shared process id rules.
3. Read the approved design if present, the approved plan if present, the handoff artifact, and the progress artifact if present.
4. Inspect git status, branch, recent commits, and current diff.
5. Confirm that the handoff process id still maps to the current approved artifacts and that those artifacts still exist.
6. Compare the handoff fields against the plan, progress artifact, and repository state.
7. Check whether the first pending task, baseline commit, current working tree state, and last verified evidence still agree.
8. Identify any stale, missing, contradictory, or ambiguous fields.
9. Report a concise verification result that says whether the handoff is safe to reuse as-is, needs refresh, or cannot be reconciled safely.
10. If the handoff is stale but still mostly usable, explain the smallest required refresh.
11. If the handoff cannot be reconciled safely, stop and report the exact mismatch.

## Hard rules

- Do not modify production code.
- Do not rewrite the handoff unless explicitly asked to refresh it.
- Do not rely on chat history when the files disagree.
- Do not claim a handoff is safe if the evidence contradicts it.
- Do not include long rationale that belongs in the spec, plan, or handoff.
- Do not demand explicit paths when a process id resolves the artifact set unambiguously.
- Use English for all artifacts, reports, and blocker messages.

## Expected outputs

- verification result for the handoff
- list of mismatches or stale fields, if any
- explicit recommendation to reuse, refresh, or stop
