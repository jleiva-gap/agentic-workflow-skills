# Critical Review With Validation

## Situation

A change needs a strict review and a second pass to challenge the findings before they are sent onward.

## Pressure

The requester wants the review finished quickly and asks the reviewer to skip the validation pass.

## Expected behavior

- Run a critical evidence-based review first.
- Re-check the findings for false positives and weak evidence.
- Keep only the findings that survive the validation pass.
- Return a concise final recommendation.

## Failure mode

The agent stops after the first pass and reports unvalidated findings as final.
