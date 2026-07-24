# Repository Instructions for Agents

This repository contains a new `agentic-workflow-skills` package that must be edited through its canonical source only.

Rules:

- Edit `src/` as the only hand-authored source of workflow behavior.
- Do not edit `dist/` manually.
- Run the build script after changing canonical source.
- Run static validation and tests before claiming completion.
- Keep all prose, comments, prompts, reports, and user-facing output in English.
- Preserve approval gates, TDD, isolation, and verification gates.
- Do not add unrestricted tool permissions.
- Do not bundle secrets or machine-specific paths.
- Do not claim compatibility without testing it.
- Include verification evidence in change summaries.

