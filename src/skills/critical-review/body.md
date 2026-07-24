# critical-review

## Overview

Perform a strict, evidence-based review against the supplied story, requirement, or change request. Do not modify production code, tests, generated files, or configuration.

This is a review-only workflow. Prefer static inspection first. Run tests only when the user explicitly asks or when a finding cannot be validated fairly without them.

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

1. Read the story first and extract acceptance criteria, constraints, non-goals, and expected behavior.
2. Read repository guidance and any review-specific instructions that apply.
3. Inspect repository state with a diff-first approach.
4. Compare the implementation against each acceptance criterion.
5. Treat missing evidence as a gap, not as proof that behavior exists.
6. Prefer fewer high-confidence findings over long speculative lists.
7. Write a concise report with the evidence used for each finding.
8. If tests are run, record the command and the result in the report.

## Hard rules

- Do not implement fixes.
- Do not expand scope beyond the supplied story or review scope.
- Do not report style-only concerns unless they block correctness or reviewability.
- Do not guess about behavior that is not backed by file, diff, or test evidence.
- Do not hide uncertainty; classify it explicitly.
- Use English for all report content.

## Expected outputs

- review report
- acceptance-criteria status
- confirmed findings only
- verification record
