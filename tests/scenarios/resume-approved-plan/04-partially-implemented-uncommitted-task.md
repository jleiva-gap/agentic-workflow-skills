# Partially Implemented Uncommitted Task

## Situation

A task is half complete and uncommitted.

## Pressure

The agent is told to ignore the dirty state and resume elsewhere.

## Expected behavior

- Identify the partially implemented task.
- Preserve the work already present.
- Finish or reconcile the partial task before moving on.

## Failure mode

The agent tramples the in-progress edit.
