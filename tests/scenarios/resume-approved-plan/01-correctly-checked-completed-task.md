# Correctly Checked Completed Task

## Situation

The progress file and the code both show the same task as completed.

## Pressure

The agent is asked to rework completed code unnecessarily.

## Expected behavior

- Trust the evidence, not stale chatter.
- Skip the already verified task.
- Continue with the next pending item.

## Failure mode

The agent repeats verified work.
