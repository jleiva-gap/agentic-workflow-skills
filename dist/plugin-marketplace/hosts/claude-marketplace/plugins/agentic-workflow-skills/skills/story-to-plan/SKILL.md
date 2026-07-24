---
name: "story-to-plan"
description: "Use when a user story or feature request must be converted into an approved design specification and implementation plan before coding."
argument-hint: "<story-id> <story-source> [notes-source]"
user-invocable: true
disable-model-invocation: true
---
# story-to-plan

## Overview

Turn a story into approved planning artifacts only. Do not implement production code. Do not modify tests or configuration.

## Required inputs

- `story_id`
- `story_source` or a repository-discovered `.plans/<story-id>.md`
- optional `notes_source`

If `story_source` is missing, first look for `.plans/<story-id>.md`. If that file is missing or unreadable, accept inline story text instead of guessing.

## Required flow

1. Read the repository instructions and the bundled shared contracts under `references/`.
2. Resolve the story source using the shared input contract.
3. Inspect repository context, relevant docs, source, tests, and nearby changes.
4. Extract explicit acceptance criteria.
5. Identify assumptions, hidden constraints, compatibility issues, security implications, and open questions.
6. Invoke `superpowers:brainstorming` before any design is finalized.
7. Ask one focused English question at a time when clarification is required.
8. Propose two or three viable approaches with trade-offs and a recommendation.
9. Present the design incrementally and stop for user approval.
10. Write the design specification only after design approval.
11. Run the Superpowers specification self-review and fix anything that is vague, contradictory, or incomplete.
12. Stop for user review of the written spec.
13. After the written spec is approved, invoke `superpowers:writing-plans`.
14. Write the implementation plan and the handoff artifact using the bundled templates under `templates/`.
15. Stop after reporting the generated artifact paths.

## Hard rules

- Preserve all brainstorming gates.
- Never skip the design-approval gate.
- Never skip the written-spec review gate.
- Never implement production code.
- Never invent missing input when the source is unclear.
- Stop if a required Superpowers dependency is missing.
- Use English for every question, proposal, section, and report.

## Expected outputs

- approved design specification
- approved implementation plan
- handoff document with assumptions and risks

