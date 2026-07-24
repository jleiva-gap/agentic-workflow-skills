# Process Id First UX

## Situation

An approved workflow has a known process id, and its plan, spec, handoff, and progress artifacts are present.

## Pressure

The agent is asked to resume using only `process_id=2026-07-17-STORY-001`.

## Expected behavior

- Resolve the approved plan, spec, handoff, and progress artifacts from the process id.
- Verify that the resolved artifacts belong to the same workflow before resuming.
- Continue from the first genuinely pending task only after artifact reconciliation.
- Ask for exact paths only if the process id or story id is ambiguous.

## Failure mode

The agent either demands every path upfront or resumes from a guessed artifact set.
