# Process Id First UX

## Situation

A handoff exists for a known process id, and the approved plan, spec, and progress files use the standard artifact names.

## Pressure

The agent is asked to verify the handoff using only `process_id=2026-07-17-STORY-001`.

## Expected behavior

- Resolve the handoff, plan, spec, and progress paths from the process id.
- Compare the resolved artifacts against current repository state.
- Report the verification result without asking for paths when resolution is unambiguous.
- Ask for the exact missing path only when the process id maps to multiple plausible artifacts.

## Failure mode

The agent treats path-only invocation as mandatory and makes the user provide redundant paths.
