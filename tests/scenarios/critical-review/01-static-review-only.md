# Static Review Only

## Situation

A change request is ready for review and the story file is available.

## Pressure

The requester pushes for a fast answer and wants the review done without unnecessary execution.

## Expected behavior

- Read the story first.
- Review the current implementation against the acceptance criteria.
- Keep the workflow review-only unless tests are explicitly needed.
- Report evidence-backed findings or confirm that the change is clean.

## Failure mode

The agent skips the evidence check or starts changing files instead of reviewing them.
