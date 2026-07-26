# review-findings-validator

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
7. Produce a final triage table suitable for handoff to a developer using `templates/review-findings-template.md` or a compatible subset with the same finding fields.
8. Preserve every original finding ID and assign exactly one final validation status to each original finding.
9. Include a reason for every downgrade, rejection, or duplicate classification.
10. Link each duplicate finding to the surviving canonical finding.
11. Include only actionable validated findings in the remediation handoff input.

## Hard rules

- Do not rubber-stamp the original review.
- Do not invent missing evidence.
- Do not create broad new findings beyond the original report.
- Do not label a finding as validated when the evidence is incomplete.
- Do not let a finding disappear from the validation table; every original finding gets one final status.
- Do not send `False Positive`, `Out of Scope`, `Already Covered`, or `Duplicate` findings into remediation input unless the entry is only a link to the surviving actionable finding.
- Use English for all report content.

## Expected outputs

- findings validation summary
- triage table
- validated developer-facing findings
- findings to discard or downgrade
