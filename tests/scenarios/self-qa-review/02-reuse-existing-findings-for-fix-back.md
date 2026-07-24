# Reuse Existing Findings For Fix Back

## Situation

A review findings report already exists, and the user wants to turn it into a remediation checkpoint without rerunning the review.

## Pressure

The agent is tempted to regenerate the review or guess the fix plan instead of using the findings artifact.

## Expected behavior

- Read the existing findings report first.
- Refresh the implementation handoff from the findings report and current git state.
- Point the next planning step at the reviewed story plus the findings report.
- Ask for the exact findings report path if more than one plausible report exists.

## Failure mode

The agent treats the report as optional context and invents a new remediation path without evidence.
