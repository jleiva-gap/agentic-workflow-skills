# Review Checklist Remediation Design

## Purpose

Implement the review feedback that materially improves `agentic-workflow-skills` without adding unverified model-evaluation claims or process-heavy scaffolding.

## Scope

This change covers three improvements:

- Per-skill invocation metadata for Copilot and Claude generated skill frontmatter.
- A canonical review findings template used by review-producing and review-validating skills.
- Stronger implementation progress evidence for reliable resume and handoff decisions.

Live model execution, cross-model benchmarks, token measurement claims, and broad evaluator rewrites are deferred because they require external execution evidence that cannot be validated locally in this repository change.

## Architecture

Canonical behavior remains under `src/`. Skill metadata becomes the source of truth for host frontmatter values, shared templates gain a reusable review findings schema, and validation checks semantic package consistency. Generated `dist/` and marketplace bundles are rebuilt from canonical source only.

## Requirements

- Preserve all existing approval, TDD, verification, and artifact gates.
- Do not edit generated `dist/` files manually.
- Keep all generated prose in English.
- Keep review skills review-only.
- Keep handoffs compact and progress evidence specific enough for resume.
- Package shared templates with every generated skill.

## Acceptance Criteria

- AC1: Copilot and Claude generated frontmatter uses each skill's canonical invocation metadata instead of one global hard-coded value.
- AC2: Internal orchestration helpers can be marked model-invocable while user-facing skills remain directly invocable.
- AC3: Review skills reference a shared findings template with stable IDs, severity, confidence, validation status, evidence, failure path, correction direction, and verification fields.
- AC4: `review-findings-validator` preserves original finding IDs, assigns exactly one final status to every original finding, and keeps remediation input limited to actionable validated findings.
- AC5: Progress artifacts record task id, files modified, commit evidence, targeted and regression verification, deviations, risks, and evidence source.
- AC6: Build and package validation fail when required shared templates are not packaged or when generated invocation metadata drifts.
- AC7: Generated distributions and the plugin marketplace rebuild without drift.

## Deferred Items

- Executable model evaluation mode.
- Cross-model benchmark matrix.
- Token-efficiency measurement by planning profile.
- Executor profile and planning-depth inputs.

These are deferred until the repository can execute and archive real host/model runs.
