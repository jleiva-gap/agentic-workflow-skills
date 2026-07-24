# Architecture

The `agentic-workflow-skills` package is organized around one rule: canonical workflow behavior is authored once, and host-specific packaging is generated from that source.

## Package layout

- `src/` contains the canonical skills and shared contracts.
- `platform/` contains host metadata overlays.
- `dist/` contains generated, self-contained host distributions and the generated plugin marketplace bundle.
- `scripts/` contains PowerShell automation for build, install, validation, and behavioral evaluation.
- `tests/` contains validation scripts and scenario markdown files.
- `docs/` contains supporting authoring, compatibility, and evaluation guidance.

## Canonical source

The canonical workflow behavior lives in:

- `src/skills/story-to-plan/`
- `src/skills/implement-approved-plan/`
- `src/skills/resume-approved-plan/`
- `src/skills/create-handoff/`
- `src/skills/verify-handoff/`
- `src/skills/self-qa-review/`
- `src/skills/critical-review-agent/`
- `src/skills/adversarial-review-agent/`
- `src/skills/critical-adversarial-review-agent/`
- `src/skills/review-findings-validator-agent/`
- `src/skills/critical-review-with-validation-agent/`

Shared support material lives in:

- `src/shared/references/`
- `src/shared/templates/`

These files define the input contract, artifact contract, dependency rules, blocker language, and reusable artifact templates used by every skill.

`create-handoff` is the compact resume-capture skill. It reads the current approved state and writes the handoff artifact without changing production code.
`verify-handoff` is the pre-resume consistency check. It compares the handoff against the current approved artifacts and git state before a session is resumed.

Workflow orchestration skills belong here when they manage artifacts, routing, or handoff state. Review heuristics belong in the review skill packs, which keeps the orchestration layer thin and avoids duplicating review behavior in two places.

If you add a self-QA wrapper, it should live in `src/skills/`, prompt for the review variant and output path, and then reuse the bundled review skills instead of copying their implementation details.

The handoff and resume guidance is documented in [docs/workflow-handoff.md](workflow-handoff.md) and uses the shared cross-tool handoff template.
For a visual walkthrough of the same flow, see [docs/agentic-workflow-diagrams.md](agentic-workflow-diagrams.md).

## Host overlays

`platform/codex/metadata.json`, `platform/copilot/metadata.json`, and `platform/claude/metadata.json` keep the host-specific differences small and explicit.

The generator reads canonical metadata and bodies from `src/`, combines them with the host overlay, renders host-specific `SKILL.md` files into the matching distribution tree, and bundles shared `references/` and `templates/` into each generated skill directory.

This host-specific metadata is the adapter layer for the package. It changes the invocation surface and frontmatter, not the canonical workflow behavior.

## Generated output

Generated skills are written under:

- `dist/codex/.agents/skills/`
- `dist/copilot/.github/skills/`
- `dist/claude/.claude/skills/`
- `dist/plugin-marketplace/`

The build script owns these files. Manual edits under `dist/` are treated as drift.

Each generated skill directory is self-contained:

- `SKILL.md`
- `references/`
- `templates/`

The plugin bundle is also generated from the same source. It contains a Codex `.codex-plugin/plugin.json`, a local marketplace file, host-specific Claude/Copilot direct skill trees, and host-specific Claude/Copilot marketplace roots for plugin-manager installation.

## Script responsibilities

- `Build-SkillDistributions.ps1` renders deterministic host packages from canonical source.
- `Build-AgenticWorkflowPlugin.ps1` renders the Codex local plugin marketplace bundle and host plugin skill trees from generated distributions.
- `Install-AgenticWorkflowSkills.ps1` copies generated skills into a project or user destination.
- `Install-AgenticWorkflowPlugin.ps1` installs the generated plugin bundle for Codex, Claude, Copilot, or all hosts, and can also print marketplace install commands from a GitHub source URL.
- `Test-SkillPackage.ps1` checks package shape, metadata, docs, and validation scaffolding.
- `Invoke-BehavioralEvaluation.ps1` records pressure-test runs and writes artifacts under `artifacts/evaluations/`.

## Workflow data flow

1. A user provides a story or approved plan.
2. The appropriate skill resolves inputs using the shared contract.
3. The skill reads repository context and supporting contracts.
4. The workflow writes or updates approved artifacts under `docs/superpowers/`.
5. The implementation workflow verifies state through tests and progress records.
6. The self QA review gate checks the finished work before the handoff is treated as final.
7. The build script renders host distributions from the canonical source.
8. Validation scripts compare the current tree against the expected package shape.

For cross-tool continuation, the artifact handoff is the portability boundary. The same approved spec, plan, and handoff files should work whether the next executor is Codex, Copilot, Claude, or a human reviewer.

## Design boundaries

The package avoids cross-cutting behavior in generated files. If a change affects skill behavior, the canonical source is updated first, then the distribution is regenerated.

This keeps the host packages consistent and makes review focused on a single source of truth.
