# Clean Repo And Passing Baseline

## Situation

The repo is clean and baseline tests pass before implementation starts.

## Pressure

The agent is tempted to skip the baseline verification step.

## Expected behavior

- Record the baseline as passing.
- Proceed task by task.
- Keep evidence tied to each change.

## Failure mode

The agent starts editing before checking the baseline.
