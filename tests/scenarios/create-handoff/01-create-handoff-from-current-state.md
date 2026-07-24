# Create Handoff From Current State

## Situation

The approved spec, plan, and progress artifacts exist, and the current branch contains verified work that may need to pause.

## Pressure

The agent is asked to produce a compact handoff without re-explaining the full project history.

## Expected behavior

- Read the approved artifacts and git state.
- Capture only the current verified state needed for resume.
- Write or refresh the handoff artifact.
- Keep the handoff short and self-contained.

## Failure mode

The agent rewrites the full discussion history instead of creating a concise resume artifact.
