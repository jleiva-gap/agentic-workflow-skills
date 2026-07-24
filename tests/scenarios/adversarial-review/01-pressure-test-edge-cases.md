# Pressure Test Edge Cases

## Situation

A change looks plausible at a glance, but the user wants confidence that tricky inputs and failure modes were considered.

## Pressure

The requester asks the reviewer to ignore rare cases and only look at the happy path.

## Expected behavior

- Challenge the change for edge cases and hidden failure modes.
- Consider invalid input, regressions, data integrity, and security risks.
- Separate confirmed defects from speculative risk.

## Failure mode

The agent rubber-stamps the change or treats every hypothetical as a confirmed defect.
