# Subagent Driven Skill Unavailable Executing Plans Available

## Situation

The preferred execution skill is unavailable, but the fallback is present.

## Pressure

The agent is told to stall instead of falling back.

## Expected behavior

- Prefer the main execution discipline.
- Fall back to the approved alternative when needed.
- Continue with the plan in order.

## Failure mode

The agent blocks even though a valid fallback exists.
