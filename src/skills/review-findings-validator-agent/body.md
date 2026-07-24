# review-findings-validator-agent

## Overview

Validate an existing review report against the story and the repository evidence. This workflow is review-only and does not modify production code.

Its job is to reduce false positives, remove duplicates, and classify findings accurately before they are sent to a developer.

## Required inputs

- `story_file`
- `review_report`

## Optional inputs

- `repo_root`
- `output_dir`
- `base_ref`
- `review_scope`
- `agent_name`
- `run_tests`

## Validation statuses

Classify each original finding as one of:

- `Validated`
- `Partially Validated`
- `Needs More Evidence`
- `Out of Scope`
- `Already Covered`
- `False Positive`
- `Duplicate`

## Required flow

1. Read the story first and extract the acceptance criteria and exclusions.
2. Read the original review report.
3. Inspect only the evidence needed to validate or challenge each finding.
4. Confirm whether the severity matches the evidence.
5. Deduplicate overlapping findings.
6. Do not create new findings unless they are necessary to explain a severe issue missed by the original report.
7. Produce a final triage table suitable for handoff to a developer.

## Hard rules

- Do not rubber-stamp the original review.
- Do not invent missing evidence.
- Do not create broad new findings beyond the original report.
- Do not label a finding as validated when the evidence is incomplete.
- Use English for all report content.

## Expected outputs

- findings validation summary
- triage table
- validated developer-facing findings
- findings to discard or downgrade
