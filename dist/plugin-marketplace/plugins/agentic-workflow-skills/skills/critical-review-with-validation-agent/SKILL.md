---
name: "critical-review-with-validation-agent"
description: "Use when a change needs a strict critical review followed by validation of the resulting findings."
argumentHint: "<story-file> [repo-root] [output-dir] [base-ref] [review-scope] [agent-name] [run-tests] [output-mode] [token-budget]"
allowImplicitInvocation: false
---
# critical-review-with-validation-agent

## Overview

Run a strict critical review first, then validate the resulting findings before finalizing the report. Do not modify production code, tests, generated files, or configuration.

This is the best default when a review needs both speed and a second-pass sanity check.

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

1. Read the story and extract acceptance criteria, constraints, exclusions, and expected behavior.
2. Perform a critical evidence-based review using the current repository state.
3. Challenge each finding for false-positive risk, scope drift, and missing evidence.
4. Validate, downgrade, or discard findings that are not backed by the repository evidence.
5. Keep only the final findings that survive the second pass.
6. Produce a concise review report with a clear final recommendation.

## Hard rules

- Do not implement fixes.
- Do not keep findings that fail the validation pass.
- Do not invent a second report format if the validation stage can be folded into the final output.
- Do not claim confidence without evidence.
- Use English for all report content.

## Expected outputs

- critical review with validation
- final confirmed findings
- discarded or downgraded findings
- verification record

