<!-- Generated file. Do not edit. -->
---
name: "resume-approved-plan"
description: "Use when implementation of an approved plan must resume after interruption, context loss, or transfer to another coding agent."
argumentHint: "<plan-path>"
allowImplicitInvocation: false
---
# resume-approved-plan

## Overview

Resume an approved plan safely after interruption, context loss, or transfer to another coding agent. Reconstruct state from artifacts and git, not from chat history.

## Required inputs

- approved plan path
- approved design path when not already linked by the plan
- handoff artifact
- progress artifact

## Required flow

1. Read repository instructions, the approved design, the approved plan, the handoff, and the progress artifact.
2. Inspect git status, branch, recent commits, and current diff.
3. Compare plan checkboxes with actual code and tests.
4. Identify the last verified completed task, any partially implemented task, the first genuinely pending task, and any plan divergence.
5. Run the smallest relevant test set first.
6. Do not trust progress text or checkboxes without evidence.
7. Preserve prior verification evidence and add new evidence instead of rewriting history.
8. Continue through the same execution mechanism as `implement-approved-plan`.
9. Stop if the current state cannot be reconciled safely.
10. Run `verification-before-completion` before final completion.

## Hard rules

- Do not repeat verified completed work.
- Do not discard uncommitted work without explicit approval.
- Do not assume chat history is available.
- Do not claim a task is complete if evidence contradicts it.
- Do not hide plan divergence.
- Use English for resumed-state analysis, blockers, progress updates, and summaries.

## Expected outputs

- resumed execution state
- updated progress artifact
- new verification evidence
- blocker report when safe reconciliation is not possible


