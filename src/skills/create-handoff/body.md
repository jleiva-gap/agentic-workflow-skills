# create-handoff

## Overview

Capture the current approved state into a compact handoff that another tool or later session can resume from without re-reading chat history. This workflow reads artifacts and repository state, then writes or refreshes the handoff artifact only.

## Required inputs

- `process_id` for the common case
- approved implementation plan path when provided as an override
- approved design path when provided as an override
- current progress artifact when provided as an override or available
- current repository state from git

Prefer `process_id` first. If a full process id is provided, resolve the standard plan, spec, handoff, and progress paths from it. If only `story_id` is provided, resolve the process only when there is exactly one plausible matching plan. If explicit paths are provided, use them as overrides for those artifacts.

If neither `process_id` nor enough paths are provided, infer from the current repository state and existing approved artifacts only when the match is unambiguous. If more than one plausible spec or plan exists, stop and ask one focused English clarification question for the exact process id or missing path.

If the user asks to refresh from review findings and there is one obvious current findings report, the skill may infer that report path from the current repository state. If more than one plausible findings report exists, the skill must ask for the exact report path instead of guessing.

The process id should normally be the approved plan filename stem `YYYY-MM-DD-<story-id>` so the exact spec/plan pair can be referenced quickly in later sessions.

## Required flow

1. Read repository instructions and the bundled shared contracts under `references/`.
2. Resolve `process_id`, `story_id`, approved plan, approved design, handoff, and progress paths using the shared process id rules.
3. Read the approved design if present, the approved plan if present, the existing handoff if present, and the progress artifact if present.
4. Inspect git status, branch, recent commits, and current diff.
5. Identify the canonical process id, story id, approved artifact paths, baseline commit, and current working tree state.
6. Find the first genuinely pending task and the last verified task record, command, result, and evidence source.
7. Extract only the assumptions, risks, blockers, and entrypoint details needed to resume without re-explaining the project.
8. Write or refresh `docs/superpowers/handoffs/<story-id>-handoff.md` from the bundled `templates/cross-tool-handoff-template.md`.
9. Keep the handoff short, current, and readable on its own.
10. If the handoff already exists and the user did not request replacement, report the existing artifact and update only the fields supported by the current evidence.
11. If the needed process id, spec, plan, or progress path cannot be inferred unambiguously, stop and ask for the missing path(s) or artifact(s) instead of inventing them.

## Hard rules

- Do not modify production code.
- Do not overwrite an existing approved handoff without explicit user approval when the current evidence would replace verified content.
- Do not rely on chat history to reconstruct task status.
- Do not include long rationale that belongs in the spec or plan.
- Do not add unverified progress.
- Do not copy full progress history into the handoff; include the first pending task and the latest evidence needed to resume.
- Do not demand explicit paths when a process id resolves the artifact set unambiguously.
- Use English for all artifacts, reports, and blocker messages.

## Expected outputs

- compact handoff artifact
- summary of the files and state used to create it
- clear note if the handoff was refreshed rather than created
