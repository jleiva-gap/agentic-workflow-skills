# Developer Guide

Use this guide when you are changing the canonical skills, the shared references, or the generated plugin bundle.

## What needs rebuilding

Rebuild when you change any of the following:

- `src/`
- `platform/`
- `scripts/`
- shared templates or references that feed generation

You do not need to rebuild just to use the published marketplace repository in Codex, Copilot, or Claude. Rebuilds are for maintainers and contributors.

## Build

Render the host distributions from the canonical source:

```powershell
pwsh ./scripts/Build-SkillDistributions.ps1
```

Render the local plugin marketplace bundle:

```powershell
pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1
```

Check for drift without rewriting `dist/`:

```powershell
pwsh ./scripts/Build-SkillDistributions.ps1 -Check
pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1 -Check
```

Clean generated output:

```powershell
pwsh ./scripts/Build-SkillDistributions.ps1 -Clean
pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1 -Clean
```

## Validate

Run the package validator:

```powershell
pwsh ./scripts/Test-SkillPackage.ps1
```

The validator writes `artifacts/validation-report.md` and reports required files, scenario coverage, metadata shape, progress evidence fields, generated invocation metadata, packaged shared templates, and optional distribution drift checks.

## Local Install

Install the generated skills into a project:

```powershell
pwsh ./scripts/Install-AgenticWorkflowSkills.ps1 -Platform all -Scope project
```

Install into user scope:

```powershell
pwsh ./scripts/Install-AgenticWorkflowSkills.ps1 -Platform all -Scope user
```

The destination roots are:

- Codex project: `<project>/.agents/skills/`
- Copilot project: `<project>/.github/skills/`
- Claude project: `<project>/.claude/skills/`
- Codex user: `$HOME/.agents/skills/`
- Copilot user: `$HOME/.copilot/skills/`
- Claude user: `$HOME/.claude/skills/`

## Plugin Bundle

The generated plugin bundle is written to `dist/plugin-marketplace/`.

It includes:

- `marketplace.json` for Codex marketplace registration;
- a repository-root Codex plugin mirror with `.codex-plugin/plugin.json` and `skills/`;
- `plugins/agentic-workflow-skills/.codex-plugin/plugin.json`;
- `plugins/agentic-workflow-skills/skills/` with all eleven Codex skills;
- `plugins/agentic-workflow-skills/hosts/copilot/.github/skills/`;
- `plugins/agentic-workflow-skills/hosts/claude/.claude/skills/`;
- `hosts/claude-marketplace/` for Claude Code plugin marketplace installation;
- `hosts/copilot-marketplace/` for GitHub Copilot CLI plugin marketplace installation.

The bundle is generated output and should not be edited manually.

## Marketplace Publish

The marketplace is published into a separate repository so remote installs can clone a real Git repository instead of a raw manifest URL.

The source of truth remains this repository. After rebuilding, publish the generated marketplace bundle into the sibling marketplace repository root so its top level contains the generated `marketplace.json` and plugin layout.

The marketplace repository URL is:

- `https://github.com/jleiva-gap/agentic-workflow-skills-marketplace`

The repository root contains the host-specific discovery manifests required by Codex, Claude
Code, and GitHub Copilot CLI.

To prepare marketplace install commands from the local repository configuration:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform all -Source marketplace
```

Publish the generated bundle into the marketplace repository:

```powershell
pwsh ./scripts/Publish-AgenticWorkflowMarketplace.ps1 -MarketplaceRoot ..\agentic-workflow-skills-marketplace
```

If the marketplace repository lives elsewhere, pass its root path explicitly with `-MarketplaceRoot`.

To install all host bundles from the generated output:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform all -Scope project
```

To refresh an existing local install after rebuilding:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform all -Scope project -Force
```

## Recommended Loop

1. Edit canonical source under `src/` or `platform/`.
2. Rebuild distributions and the plugin bundle.
3. Run the package validator.
4. Reinstall the generated bundle if you are testing locally.
5. Publish the marketplace repository and review `artifacts/validation-report.md` before shipping.

## Generated Artifacts

The canonical workflows write approved artifacts under `docs/superpowers/`, including:

- design specs
- implementation plans
- handoff records
- implementation progress notes

For cross-tool continuity, the canonical handoff payload lives at [`src/shared/templates/cross-tool-handoff-template.md`](../src/shared/templates/cross-tool-handoff-template.md). Generated skills also include it under `templates/cross-tool-handoff-template.md` so installed skills can run without the source package.

For review consistency, the canonical findings schema lives at [`src/shared/templates/review-findings-template.md`](../src/shared/templates/review-findings-template.md). Review skills use that schema, and generated skills include it under `templates/review-findings-template.md`.

For resume reliability, the canonical progress payload lives at [`src/shared/templates/implementation-progress-template.md`](../src/shared/templates/implementation-progress-template.md). Progress records should include task id, modified files, verification commands and results, deviations, risks, and evidence source.

## Approval Gates

The package preserves these gates:

- brainstorming before design finalization
- written design approval before planning
- plan approval before implementation
- baseline verification before coding continues
- verification before completion
- self QA review before the handoff is treated as final
- artifact-based resume decisions instead of chat-memory guesses

The QA review itself is independent. It should evaluate the story against the code and evidence, not the implementation plan. When QA reports findings, refresh the implementation handoff from that report rather than inventing a separate handoff type.

## Blocking Behavior

When a required input, dependency, or repository condition is missing, the workflows stop and ask for the specific missing piece instead of inventing one.

## Resume Workflow

`resume-approved-plan` is the safe continuation path when a task was interrupted, progress is stale, or the current state no longer matches the latest chat context.

Use the handoff artifact when resuming:

- read the approved plan, handoff, and progress files first
- compare the plan to the actual code and tests
- trust the latest verified evidence over chat summaries
- continue from the first incomplete task that still needs work

If the handoff is stale, run `create-handoff` again before resuming.

If the work has not yet passed self QA review, run that review before treating the handoff as final.

If the skill asks for a specific plan, spec, or progress path, provide the exact approved artifact path and rerun it.

For the handoff, verify, and resume workflows, prefer `process_id=<YYYY-MM-DD-story-id>` first. Use explicit paths only when you need to override artifact discovery or disambiguate multiple matching plans.

## Behavioral Evaluation

Use the scenario files under `tests/scenarios/` together with:

```powershell
pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill story-to-plan -Scenario 01-minimal-valid-story-and-file-path
```

The runner records an evaluation artifact under `artifacts/evaluations/`.

## Troubleshooting

- If the validator reports missing files, restore the canonical source or docs under this package root.
- If distribution drift is reported, rebuild `dist/` from `src/` instead of editing generated files.
- If a workflow stops for a blocker, resolve the missing input or dependency and rerun from the approved artifact.

## Security And Permissions

- Do not add unrestricted tool permissions.
- Do not log secrets.
- Do not embed machine-specific absolute paths in repository prose.
- Keep generated content in English unless source material is being quoted verbatim as data.

## Limitations

- The behavioral evaluator records scaffolding for pressure tests, but does not automatically invoke a model.
- Distribution files are generated output and should not be edited manually.
- The package currently focuses on eleven workflow skills used for planning, implementation, resumption, handoff capture, handoff verification, and review.
