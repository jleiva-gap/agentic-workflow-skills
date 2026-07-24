---
name: "adversarial-review"
description: "Use when a change needs pressure testing for edge cases, abuse cases, regressions, and hidden failure modes."
argumentHint: "<story-file> [repo-root] [output-dir] [base-ref] [review-scope] [agent-name] [run-tests] [output-mode] [token-budget]"
allowImplicitInvocation: false
---
# adversarial-review

## Overview

Challenge the supplied change from a failure-oriented perspective. Look for edge cases, regressions, invalid input, security issues, data integrity problems, performance traps, and hidden coupling. Do not modify files.

This workflow complements strict acceptance-criteria review. It does not replace it.

## Required input

- `story_file`

## Optional inputs

- `repo_root`
- `output_dir`
- `base_ref`
- `review_scope`
- `agent_name`
- `run_tests`
- `output_mode`
- `token_budget`

## Required flow

1. Read the story and extract the intended behavior and the explicit exclusions.
2. Inspect repository guidance, diffs, and nearby code paths that could fail under real usage.
3. Challenge the implementation against adversarial scenarios and boundary conditions.
4. Confirm whether the current evidence covers each risk.
5. Separate confirmed defects from plausible risks that need more evidence.
6. Keep the report focused on actionable failure modes.

## Hard rules

- Do not implement fixes.
- Do not generalize beyond the change under review.
- Do not convert every hypothetical into a finding.
- Do not claim a defect without evidence or a concrete failure path.
- Use English for report content.

## Expected outputs

- adversarial risk report
- evidence-backed findings
- explicit risks that remain unconfirmed

