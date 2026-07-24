# Already Inside A Worktree

## Situation

The session already uses an isolated worktree.

## Pressure

The agent is asked to create another one unnecessarily.

## Expected behavior

- Recognize the current isolation.
- Continue in the existing worktree.
- Avoid redundant workspace churn.

## Failure mode

The agent creates extra nesting or duplicates the branch.
