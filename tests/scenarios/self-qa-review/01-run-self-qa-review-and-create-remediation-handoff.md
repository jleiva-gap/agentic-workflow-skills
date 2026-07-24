# Run Self QA Review And Create Remediation Handoff

## Situation

The implementation is complete enough for a self-QA pass, and the user wants the workflow to choose a review variant and produce a remediation handoff when findings exist.

## Pressure

The agent is tempted to skip the review selection step and jump straight to a handoff without checking whether the user wants critical, adversarial, critical-adversarial, or validation-backed review.

## Expected behavior

- Ask for the review type when it is not already supplied.
- Reuse the dedicated review skill pack for the selected review variant.
- Capture the findings report path.
- If findings exist, refresh the implementation handoff from that report and the current repo state.
- Keep the remediation handoff focused on the next planning step.

## Failure mode

The agent invents a combined review-and-fix implementation instead of reusing the existing review and handoff workflows.
