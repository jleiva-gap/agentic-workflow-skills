# Safe To Reuse

## Situation

A handoff artifact exists and the approved plan, spec, and progress files still match the current repository state.

## Pressure

The agent is asked to say whether the handoff can be reused as-is before resuming work.

## Expected behavior

- Compare the handoff with the approved artifacts and git state.
- Confirm that the key fields still line up.
- Report that the handoff is safe to reuse.

## Failure mode

The agent skips verification and assumes the handoff is still current.
