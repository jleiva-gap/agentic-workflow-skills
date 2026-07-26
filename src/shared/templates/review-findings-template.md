# Review Findings Template

Use this template for review reports and validation reports. A review may omit fields only when it explicitly reports `No Findings`.

## Summary

- Review target:
- Story source:
- Base ref:
- Review scope:
- Result: `No Findings` or `Findings Present`
- Tests run:
- Tests result:

## Acceptance Criteria Status

| Criterion ID | Status | Evidence |
| --- | --- | --- |
| AC1 | `Satisfied`, `Partially Satisfied`, `Not Satisfied`, `Not Applicable`, or `Blocked` | File, symbol, diff, command, or artifact evidence |

## Findings

### Finding `<stable-id>`

- Finding ID:
- Title:
- Severity: `Critical`, `High`, `Medium`, `Low`
- Confidence: `High`, `Medium`, `Low`
- Validation status: `Validated`, `Partially Validated`, `Needs More Evidence`, `Out of Scope`, `Already Covered`, `False Positive`, `Duplicate`, or `Unvalidated`
- Acceptance criterion:
- Category:
- File and line or symbol:
- Evidence:
- Concrete failure path:
- Impact:
- Recommended correction direction:
- Required verification:
- Scope classification: `In Scope`, `Out of Scope`, or `Requires Approval`
- Duplicate or related finding IDs:

## Actionable Findings For Remediation

Include only findings with status `Validated` or `Partially Validated`, plus `Needs More Evidence` when the missing evidence blocks a release or handoff decision.

| Finding ID | Actionable status | Correction direction | Required verification |
| --- | --- | --- | --- |
