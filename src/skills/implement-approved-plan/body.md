# implement-approved-plan

## Overview

Implement an approved plan task by task with isolation, test-first execution, and verifiable progress. Do not expand scope and do not redesign approved behavior silently.

## Required inputs

- approved implementation plan path
- approved design path when not already linked by the plan

## Required flow

1. Read repository instructions, the bundled shared contracts under `references/`, the approved design, and the approved implementation plan.
2. Inspect git status, branch, recent commits, and current diff.
3. Invoke `using-git-worktrees` unless the session is already isolated.
4. Detect project setup and the correct test command.
5. Run baseline tests before making changes.
6. Stop and report if baseline tests fail.
7. Identify the first incomplete task in plan order.
8. Prefer `subagent-driven-development`.
9. Fall back to `executing-plans` only when the preferred skill is unavailable.
10. Use `test-driven-development` for each implementation task.
11. For each task, write the failing test first, verify the failure, implement the minimum change, rerun the relevant tests, inspect the diff, and update the progress artifact only after verification.
12. Update plan checkboxes only after evidence exists.
13. Commit when permitted by the plan and task state.
14. Run `verification-before-completion` before declaring completion.

## Hard rules

- Do not begin implementation before baseline verification.
- Do not continue past a design or plan contradiction.
- Do not skip tests because the user wants speed.
- Do not mark a task complete without verification evidence.
- Do not rely on stale progress text when current evidence disagrees.
- Do not silently replace the approved plan with a different approach.
- Use English for progress notes, blocker reports, and final summaries.

## Expected outputs

- task-by-task code changes
- updated plan checkboxes
- progress artifact with verification evidence
- final verification record
