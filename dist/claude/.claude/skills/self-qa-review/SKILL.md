---
name: "self-qa-review"
description: "Use when a completed implementation needs a self-QA review and a remediation handoff based on the findings."
argument-hint: "<story-file> [review-type] [review-file] [repo-root] [output-dir]"
user-invocable: true
disable-model-invocation: true
---
# self-qa-review

## Overview

Run a self-QA review against the current implementation, then turn any findings into a remediation handoff that can feed the next planning step. Do not modify production code.

This workflow is a thin orchestrator. It uses the review skills shipped in this package for the actual review heuristics and uses `create-handoff` to capture the fix-back checkpoint when the review produces findings.

## Required inputs

- `story_file`
- `review_type` when the desired review variant is not obvious
- `review_file` when an existing findings report should be reused for remediation
- optional `repo_root`
- optional `output_dir`
- optional `base_ref`
- optional `review_scope`
- optional `token_budget`
- optional `run_tests`
- optional `commands`
- optional `agent_name`

## Review variants

Resolve `review_type` to one of the existing review skill packs:

- `critical` -> `critical-review`
- `adversarial` -> `adversarial-review`
- `critical-adversarial` -> `critical-adversarial-review`
- `critical-with-validation` -> `critical-review-with-validation`

If `review_type` is missing and `review_file` is not supplied, ask one focused English question that offers those four choices. Do not guess.

## Required flow

1. Read the repository instructions, the bundled shared contracts under `references/`, the story source, the current git state, and the bundled review skills.
2. If the story source is missing, ask for it before doing anything else.
3. If `review_file` is supplied, skip review generation and treat it as the remediation source.
4. If `review_file` is not supplied, ask for `review_type` when needed, resolve the matching review skill, and run that skill with the shared review inputs.
5. Capture the resulting review findings report path.
6. Inspect the findings report and identify whether it contains actionable findings.
7. If the review is clean and the user did not ask for a checkpoint, report that no remediation handoff is needed and stop.
8. If the review produced findings, or if the user explicitly asked to prepare a fix-back checkpoint, run `create-handoff` to refresh the implementation handoff from the findings report and current repository state.
9. Use the refreshed handoff to point the next planning step at the reviewed story plus the findings report as remediation context.
10. If the fix requires replanning, tell the user to feed the story plus findings into `story-to-plan` rather than inventing a second planning engine.
11. Stop after reporting the review findings report path and the remediation handoff path.

## Hard rules

- Do not implement production fixes in this workflow.
- Do not silently replace the requested review variant.
- Do not invent a dedicated remediation engine when the existing planning and handoff workflows already cover the need.
- Do not skip asking for a review type when the user did not provide one and the report path cannot be reused.
- Use English for questions, status updates, artifact content, and final reporting.

## Expected outputs

- review findings report
- remediation handoff when findings require a fix-back
- next-step recommendation for `story-to-plan` or the future `remediate-story` wrapper

