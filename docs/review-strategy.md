# Review Strategy

This package ships several review skills so you can match the review depth to the work you are trying to protect.

## Recommended Use

- `critical-review` for the default code review pass
- `adversarial-review` when you want a reviewer to actively look for failure modes, regressions, and brittle assumptions
- `critical-adversarial-review` when you want both strict evidence checking and challenge-oriented review in one pass
- `critical-review-with-validation` when the findings should be checked by a second pass before they are trusted
- `review-findings-validator` when you already have findings and need them validated, deduplicated, or downgraded

## Naming

The shorter skill names are intentional. They are easier to scan in prompts, easier to reuse in wrappers, and easier to explain to another developer.

If your host or personal workflow benefits from namespaces, the skill name can be prefixed optionally, for example:

- `orion:critical-review`
- `orion:adversarial-review`
- `orion:critical-review-with-validation`

The prefix is optional and should not change the underlying skill behavior.

## What Good Review Feedback Looks Like

Good feedback helps a developer improve the daily flow, reduce defects, and give a useful peer review.

It should:

- point to concrete evidence in the code, tests, or artifacts
- explain why the issue matters
- distinguish blocking defects from lower-priority concerns
- avoid vague style-only commentary unless it affects correctness, maintainability, or delivery risk
- be specific enough that the next change can be implemented without guesswork

## When To Use Which Skill

- Use `critical-review` when you want the baseline review gate
- Use `adversarial-review` when you suspect the implementation may pass a shallow review but still hide edge cases
- Use `critical-adversarial-review` when a release or handoff deserves a stronger combined pass
- Use `critical-review-with-validation` when you want the review result challenged before it is finalized
- Use `review-findings-validator` when you need to process findings from another review and remove duplicates or false positives

