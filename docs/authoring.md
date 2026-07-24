# Authoring Guide

Use this guide when changing the canonical skills or the shared contracts.

## Editing rules

- Edit canonical workflow behavior only under `src/`.
- Edit host-specific metadata only under `platform/`.
- Treat `dist/` as generated output; do not edit bundled references or templates there.
- Keep prose, prompts, and reports in English.
- Preserve approval gates, test-first sequencing, isolation, and verification requirements.

## Canonical source layout

- `src/shared/references/` contains contracts and rule definitions.
- `src/shared/templates/` contains reusable artifact templates.
- `src/skills/story-to-plan/` contains the planning skill.
- `src/skills/implement-approved-plan/` contains the implementation skill.
- `src/skills/resume-approved-plan/` contains the resume skill.
- `src/skills/create-handoff/` contains the handoff capture skill.
- `src/skills/verify-handoff/` contains the handoff verification skill.
- `src/skills/self-qa-review/` contains the self-QA and remediation handoff skill.
- `src/skills/critical-review/` contains the strict review skill.
- `src/skills/adversarial-review/` contains the pressure-test review skill.
- `src/skills/critical-adversarial-review/` contains the combined review skill.
- `src/skills/review-findings-validator/` contains the findings validator skill.
- `src/skills/critical-review-with-validation/` contains the two-pass critical review skill.

## When to update shared references

Update the shared references when you change:

- input precedence or resolution;
- artifact paths or naming conventions;
- blocker categories or escalation language;
- dependency requirements for Superpowers skills;
- the standard progress or handoff artifact structure.
- the cross-tool handoff template.

## When to update skill bodies

Update a skill body when you change:

- the required flow;
- the approval gates;
- the evidence requirements;
- the task sequencing;
- the safety constraints for that workflow.

## When to update metadata

Update skill metadata when you change:

- the canonical skill name;
- the description;
- the argument hint;
- the host support flags in `platform/`.

## Build and verification loop

After editing canonical source:

1. Run `pwsh ./scripts/Build-SkillDistributions.ps1`.
2. Run `pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1`.
3. Run `pwsh ./scripts/Test-SkillPackage.ps1 -Check`.
4. Review the generated `dist/` tree and validation report.

If the generated output differs from expectation, change the canonical source rather than hand-editing `dist/`. Shared files under `src/shared/` are copied into each generated skill directory during the build. The plugin marketplace bundle is generated output too.

## Authoring conventions

- Prefer explicit steps over implied behavior.
- Describe blockers in plain English.
- Use filename-safe normalized paths inside generated artifact names.
- Keep the original story id intact inside artifact content.
- Avoid machine-specific paths in checked-in prose.

## Adding a new workflow

This package currently ships eleven workflows. If a new workflow is added later, update:

- the canonical source tree;
- the host overlays;
- the generator;
- the installer;
- the validation script;
- the README;
- the behavioral scenarios.
