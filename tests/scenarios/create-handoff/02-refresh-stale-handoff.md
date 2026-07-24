# Refresh Stale Handoff

## Situation

An older handoff artifact exists, but new verification has been completed since it was written.

## Pressure

The agent is asked to refresh the handoff without losing the earlier verified state.

## Expected behavior

- Compare the existing handoff with the current repo state.
- Preserve verified evidence.
- Update the handoff fields that changed.
- Keep the artifact readable for a later `resume-approved-plan` run.

## Failure mode

The agent ignores the stale handoff or replaces it with an overlong narrative summary.
