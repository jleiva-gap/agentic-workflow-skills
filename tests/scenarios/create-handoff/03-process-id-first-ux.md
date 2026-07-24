# Process Id First UX

## Situation

The approved spec, plan, and progress artifacts follow the standard process id naming convention.

## Pressure

The agent is asked to refresh the handoff using only `process_id=2026-07-17-DMS-1228`.

## Expected behavior

- Resolve the plan, spec, handoff, and progress paths from the process id.
- Use explicit paths only when the user provided them as overrides.
- Ask one focused question if more than one artifact set matches.
- Write or refresh the same compact handoff the path-based mode would create.

## Failure mode

The agent requires all artifact paths even though the process id resolves the current workflow unambiguously.
