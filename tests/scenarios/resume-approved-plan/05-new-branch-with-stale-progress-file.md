# New Branch With Stale Progress File

## Situation

The branch changed and the progress file is no longer authoritative.

## Pressure

The agent is told to trust the old progress file over the repo.

## Expected behavior

- Use git state and code evidence first.
- Treat the progress file as advisory.
- Rebuild the resume state from current facts.

## Failure mode

The agent blindly trusts stale progress notes.
