# critical-adversarial-review-agent

## Overview

Run one review pass that covers both acceptance-criteria correctness and adversarial failure analysis. Do not modify production code, tests, generated files, or configuration.

This workflow is useful when the user wants a single, strict review result instead of separate critical and adversarial passes.

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

1. Read the story first and extract acceptance criteria, non-goals, constraints, and expected behavior.
2. Inspect repository guidance and the current diff.
3. Review the implementation against each criterion.
4. Challenge the implementation for edge cases, abuse cases, regression paths, and hidden dependencies.
5. Deduplicate findings that overlap the same root cause.
6. Keep only actionable, evidence-backed findings.
7. Report both satisfaction gaps and adversarial risks in a single concise output.

## Hard rules

- Do not implement fixes.
- Do not duplicate findings that describe the same issue.
- Do not report speculative risks as confirmed defects.
- Do not omit evidence when a finding is confirmed.
- Use English for all report content.

## Expected outputs

- combined critical and adversarial review report
- evidence-backed findings
- remaining risks, if any
