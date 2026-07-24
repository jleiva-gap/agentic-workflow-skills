# Agentic Workflow Skills

`agentic-workflow-skills` is a PowerShell-first package for eleven reusable workflow skills:

- `story-to-plan`
- `implement-approved-plan`
- `resume-approved-plan`
- `create-handoff`
- `verify-handoff`
- `self-qa-review`
- `critical-review`
- `adversarial-review`
- `critical-adversarial-review`
- `review-findings-validator`
- `critical-review-with-validation`

The package keeps the canonical workflow behavior in `src/`, generates self-contained host-specific packages into `dist/`, and uses approved artifacts instead of chat history as the handoff between stages.

For a practical guide to choosing among the review skills, see [docs/review-strategy.md](docs/review-strategy.md).

When work crosses tools, the handoff record is the portability boundary. The next executor should be able to continue from the spec, plan, handoff, and progress files alone.

The independent QA review packet is separate from the implementation handoff. QA should use the story or acceptance criteria, the code, and the evidence, then decide whether the work is story-complete or needs a fix-back handoff.
If QA finds issues, the review findings report should be used to refresh the implementation handoff before the next fix pass.

The review logic itself stays in the review skill family shipped with this package. The `self-qa-review` wrapper routes to those review skills instead of copying their behavior.

## Workflow

```text
story -> approved design -> approved plan -> implementation -> self QA review -> handoff -> resume when needed
```

When the self-QA pass finds issues, the flow branches through a remediation handoff before planning the fix.

The implementation handoff is artifact-driven because chat context is not a reliable source of truth for approval state, implementation progress, or resume decisions.

## What is included

- canonical skill bodies and metadata under `src/`
- shared references and templates that are bundled into every generated skill
- host metadata overlays under `platform/`
- deterministic rendering scripts under `scripts/`
- package validation scaffolding under `tests/`
- behavioral evaluation scenarios under `tests/scenarios/`
- supporting documentation under `docs/`
- developer manual under `docs/agentic-workflow-manual.md`
- diagram reference under `docs/agentic-workflow-diagrams.md`

## Skill boundary

`agentic-workflow-skills` is the right home for workflow orchestration skills that create, verify, or refresh approved artifacts, plus the dedicated review skills that the self-QA wrapper routes through.

The review skills stay narrower than the orchestration layer because they are reusable from multiple wrapper skills and do not manage artifact lifecycle state themselves.

If a new self-QA flow needs to route between critical, adversarial, or validation variants, keep that routing thin and let the workflow skill call the dedicated review skill rather than embedding the review logic twice.

## Repository layout

```text
agentic-workflow-skills/
├── AGENTS.md
├── CHANGELOG.md
├── LICENSE
├── README.md
├── artifacts/
├── docs/
├── dist/
├── platform/
├── scripts/
├── src/
└── tests/
```

## Prerequisite

The package is designed for PowerShell 7+ on Windows. All mandatory automation uses PowerShell.

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

## Validation

Run the package validator:

```powershell
pwsh ./scripts/Test-SkillPackage.ps1
```

The validator writes `artifacts/validation-report.md` and reports required files, scenario coverage, metadata shape, and optional distribution drift checks.

## Installation

You can install the package in two ways:

- skill folders: copy generated skills directly into each host's skill root;
- plugin bundle: install the generated local plugin bundle, with Codex using a real plugin marketplace and Claude/Copilot receiving the matching host skill folders.

Use plugin installation when you want the Codex plugin flow or a single generated bundle that includes all host surfaces. Use skill-folder installation when you only need the direct skill files.

### Install Skill Folders

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

### Install Plugin Bundle

The plugin bundle is generated under:

```text
dist/plugin-marketplace/
```

It contains:

- `marketplace.json` for Codex local marketplace registration;
- `plugins/agentic-workflow-skills/.codex-plugin/plugin.json`;
- `plugins/agentic-workflow-skills/skills/` with all eleven Codex skills;
- `plugins/agentic-workflow-skills/hosts/copilot/.github/skills/`;
- `plugins/agentic-workflow-skills/hosts/claude/.claude/skills/`.
- `hosts/claude-marketplace/` for Claude Code plugin marketplace installation;
- `hosts/copilot-marketplace/` for GitHub Copilot CLI plugin marketplace installation.

The bundle includes `self-qa-review` and the dedicated review skill family.

Review skills are intentionally split by purpose:

- `critical-review` for strict evidence-based review and defect detection
- `adversarial-review` for challenge-oriented review that looks for edge cases, regressions, and hidden coupling
- `critical-adversarial-review` when you want both strictness and adversarial pressure in one pass
- `critical-review-with-validation` when you want the review findings validated by a second pass before you act on them
- `review-findings-validator` when you only need to validate or de-duplicate findings from an existing review report

If your host uses optional aliases, you can keep the skill name readable with a prefix such as `orion:<skill>`.

You can install it in two ways:

- local bundle mode, which copies the generated files into a workspace or user folder;
- marketplace mode, which points the host plugin manager at a GitHub repository URL or other marketplace source.

#### Step 1: Build Everything

Run both build scripts from `agentic-workflow-skills/`:

```powershell
pwsh ./scripts/Build-SkillDistributions.ps1
pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1
```

#### Step 2: Validate the Bundle

```powershell
pwsh ./scripts/Test-SkillPackage.ps1 -Check
```

#### Step 3: Install for Codex

Install the local Codex plugin marketplace bundle into the current project:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform codex -Scope project
```

That copies the marketplace bundle to:

```text
<project>/.agents/plugins/agentic-workflow-skills/
```

Then register and install it with Codex:

```powershell
codex plugin marketplace add "<project>/.agents/plugins/agentic-workflow-skills"
codex plugin add agentic-workflow-skills@agentic-workflow-skills-local
```

Start a new Codex thread after installation so the plugin skills are loaded.

If your Codex surface supports marketplace import from a GitHub source, you can use the same installer in marketplace mode:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform codex -Source marketplace -MarketplaceSource https://github.com/jleiva-gap/agentic-workflow-skills
```

That prints the Codex marketplace registration commands for the GitHub source instead of copying the local bundle.

For user-scope Codex installation:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform codex -Scope user
codex plugin marketplace add "$HOME/.agents/plugins/agentic-workflow-skills"
codex plugin add agentic-workflow-skills@agentic-workflow-skills-local
```

#### Step 4: Install for Claude Code

Claude Code supports the plugin marketplace pattern. Use this option when you want namespaced plugin skills such as `/orion:story-to-plan` when the host exposes the Orion namespace.

Install the generated plugin bundle into the current project:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform claude -Scope project
```

That copies all eleven direct skills to:

```text
<project>/.claude/skills/
```

It also leaves a Claude-compatible local marketplace in the generated bundle. To install through Claude's plugin manager from this repository, run these commands from inside Claude Code:

```text
/plugin marketplace add ./dist/plugin-marketplace/hosts/claude-marketplace
/plugin install agentic-workflow-skills@agentic-workflow-skills-local
/reload-plugins
```

Or use the non-interactive Claude CLI:

```powershell
claude plugin marketplace add .\dist\plugin-marketplace\hosts\claude-marketplace --scope project
claude plugin install agentic-workflow-skills@agentic-workflow-skills-local --scope project
```

Or install from the GitHub repository URL:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform claude -Source marketplace -MarketplaceSource https://github.com/jleiva-gap/agentic-workflow-skills -Scope project
```

For user scope:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform claude -Scope user
```

#### Step 5: Install for GitHub Copilot

GitHub Copilot CLI supports a plugin marketplace pattern too. Copilot's command is `plugin install`, not `plugin add`.

Install the generated plugin bundle into the current project:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform copilot -Scope project
```

That copies all eleven direct skills to:

```text
<project>/.github/skills/
```

To install through Copilot's plugin manager from this repository, run:

```powershell
copilot plugin marketplace add .\dist\plugin-marketplace\hosts\copilot-marketplace
copilot plugin install agentic-workflow-skills@agentic-workflow-skills-local
```

You can also install the Copilot plugin directly from the local plugin directory:

```powershell
copilot plugin install .\dist\plugin-marketplace\hosts\copilot-marketplace\plugins\agentic-workflow-skills
```

Or install from the GitHub repository URL:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform copilot -Source marketplace -MarketplaceSource https://github.com/jleiva-gap/agentic-workflow-skills -Scope project
```

For user scope:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform copilot -Scope user
```

#### Step 6: Install All Host Bundles

To install Codex, Claude, and Copilot surfaces in one pass:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform all -Scope project
```

Then complete the Codex registration commands printed by the script.

#### Updating an Existing Plugin Install

1. Rebuild the generated outputs:

```powershell
pwsh ./scripts/Build-SkillDistributions.ps1
pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1
```

2. Reinstall the plugin bundle:

```powershell
pwsh ./scripts/Install-AgenticWorkflowPlugin.ps1 -Platform all -Scope project -Force
```

3. Re-run Codex install if the Codex app needs to pick up the refreshed local plugin:

```powershell
codex plugin add agentic-workflow-skills@agentic-workflow-skills-local
```

4. Start a new Codex, Claude, or Copilot session so the refreshed skills are loaded.

## Skills

### `story-to-plan`

Use when a story or feature request must be converted into an approved design specification and implementation plan before coding.

Typical usage:

```text
$story-to-plan story_id=DMS-1228 story_source=.plans/DMS-1228.md
```

This workflow:

- resolves the story input using the shared input contract;
- explores the space before finalizing a design;
- writes the design spec, implementation plan, and handoff artifact;
- stops for approval gates instead of guessing.

### `implement-approved-plan`

Use when an approved plan is ready for task-by-task implementation and verification.

Typical usage:

```text
$implement-approved-plan docs/superpowers/plans/2026-07-17-DMS-1228.md
```

This workflow:

- reads the approved design and plan;
- checks repository state before editing;
- uses baseline verification and test-first implementation;
- updates progress only after evidence exists.

### `resume-approved-plan`

Use when implementation must resume after interruption, context loss, or transfer.

Typical usage:

```text
$resume-approved-plan process_id=2026-07-17-DMS-1228
```

This workflow:

- reconstructs state from artifacts and git;
- resolves the plan, spec, handoff, and progress files from the process id when possible;
- compares plan checkboxes against the code;
- preserves verified work;
- continues safely from the first genuinely pending task.

### `create-handoff`

Use when you need to turn the current approved state into a compact handoff artifact or refresh an existing one before pausing.

Typical usage:

```text
$create-handoff process_id=2026-07-17-DMS-1228
```

This workflow:

- reads the approved spec, plan, progress artifact, and git state;
- resolves standard artifact paths from a process id when possible;
- writes or refreshes the handoff artifact;
- keeps the handoff short enough for a later session to resume quickly;
- avoids repeating background that already belongs in the spec or plan.
- can infer the spec, plan, and progress paths when the current context makes them unambiguous;
- asks for the missing path(s) only when more than one plausible artifact exists.

### `verify-handoff`

Use when you want to confirm that a handoff is still safe to reuse before resuming work.

Typical usage:

```text
$verify-handoff process_id=2026-07-17-DMS-1228
```

This workflow:

- compares the handoff against the plan, spec, progress file, and git state;
- resolves the handoff and approved artifacts from the process id when possible;
- flags stale or contradictory fields before resume starts;
- recommends reuse, refresh, or stop;
- avoids rewriting the handoff unless explicitly asked.

Explicit path mode is still supported when the process id is ambiguous or when you want to pin exact artifacts:

```text
$verify-handoff process_id=2026-07-17-DMS-1228 handoff=docs/superpowers/handoffs/DMS-1228-handoff.md plan=docs/superpowers/plans/2026-07-17-DMS-1228.md
```

### `self-qa-review`

Use when a finished implementation needs an independent review plus a remediation handoff when findings exist.

Typical usage:

```text
$self-qa-review story_file=.plans/DMS-1228.md review_type=critical-with-validation
```

This workflow:

- asks for the review variant when it is not already clear;
- reuses the dedicated review skills shipped in this package for the review pass;
- captures the findings report path;
- refreshes the handoff from the findings report when fixes are needed;
- points the next planning step at `story-to-plan` with the findings report as remediation context.

### `critical-review`

Use when a story or change needs a strict evidence-based review before it is sent to a developer.

Typical usage:

```text
$critical-review story_file=.plans/DMS-1234.md
```

This workflow:

- checks the implementation against the story and repo evidence;
- stays review-only by default;
- keeps tests off unless they are explicitly needed;
- writes a concise evidence-backed report.

### `adversarial-review`

Use when a review needs pressure testing for edge cases, regressions, and hidden failure modes.

Typical usage:

```text
$adversarial-review story_file=.plans/DMS-1234.md
```

This workflow:

- challenges the change from a failure-oriented perspective;
- looks for invalid input, security, data integrity, and performance issues;
- separates confirmed defects from plausible but unconfirmed risks.

### `critical-adversarial-review`

Use when you want one pass that combines strict acceptance-criteria review with adversarial pressure testing.

Typical usage:

```text
$critical-adversarial-review story_file=.plans/DMS-1234.md
```

This workflow:

- verifies each acceptance criterion;
- challenges the same change for boundary conditions and regressions;
- deduplicates overlapping findings.

### `review-findings-validator`

Use when a review report already exists and you need to validate or challenge its findings before sending them onward.

Typical usage:

```text
$review-findings-validator story_file=.plans/DMS-1234.md review_report=.wi/reviews/20260724_120000_codex_critical_review.md
```

This workflow:

- reads the original review and story;
- classifies each finding as validated, duplicated, out of scope, or needing more evidence;
- avoids inventing new findings unless they are necessary to explain a severe issue.

### `critical-review-with-validation`

Use when a review needs a strict first pass and a validation pass before the final report is accepted.

Typical usage:

```text
$critical-review-with-validation story_file=.plans/DMS-1234.md
```

This workflow:

- performs a critical evidence-based review;
- re-checks findings for false positives and weak evidence;
- keeps only the findings that survive validation.

## Host usage

### Codex

Codex renders the generated skill files under `.agents/skills/`.

Use the `$skill-name` invocation style shown in the skill metadata examples.

### Copilot

Copilot renders the generated skill files under `.github/skills/`.

Use the `/skill-name` invocation style shown in the skill metadata examples.

### Claude Code

Claude renders the generated skill files under `.claude/skills/`.

Use the `/skill-name` invocation style shown in the skill metadata examples.

## Input examples

Named input takes precedence over positional input when both are present.

Story file example:

```text
$story-to-plan story_id=DMS-1228 story_source=.plans/DMS-1228.md notes_source=.plans/DMS-1228-notes.md
```

Inline story example:

```text
$story-to-plan story_id=DMS-1228 story_source="Add retry logic for the API client"
```

## Generated artifacts

The canonical workflows write approved artifacts under `docs/superpowers/`, including:

- design specs
- implementation plans
- handoff records
- implementation progress notes

For cross-tool continuity, the canonical handoff payload lives at [`src/shared/templates/cross-tool-handoff-template.md`](src/shared/templates/cross-tool-handoff-template.md). Generated skills also include it under `templates/cross-tool-handoff-template.md` so installed skills can run without the source package.

For step-by-step guidance, see [docs/workflow-handoff.md](docs/workflow-handoff.md).
For the full developer guide and scenario cookbook, see [docs/agentic-workflow-manual.md](docs/agentic-workflow-manual.md).
For a visual overview of the flow, see [docs/agentic-workflow-diagrams.md](docs/agentic-workflow-diagrams.md).

## Approval gates

The package preserves these gates:

- brainstorming before design finalization;
- written design approval before planning;
- plan approval before implementation;
- baseline verification before coding continues;
- verification before completion;
- self QA review before the handoff is treated as final;
- artifact-based resume decisions instead of chat-memory guesses.

The QA review itself is independent. It should evaluate the story against the code and evidence, not the implementation plan.
When QA reports findings, the implementation handoff should be refreshed from that report rather than inventing a separate handoff type.

## Blocking behavior

When a required input, dependency, or repository condition is missing, the workflows stop and ask for the specific missing piece instead of inventing one.

## Resume workflow

`resume-approved-plan` is the safe continuation path when a task was interrupted, progress is stale, or the current state no longer matches the latest chat context.

Use the handoff artifact when resuming:

- read the approved plan, handoff, and progress files first;
- compare the plan to the actual code and tests;
- trust the latest verified evidence over chat summaries;
- continue from the first incomplete task that still needs work.

If the handoff is stale, run `create-handoff` again before resuming.

If the work has not yet passed self QA review, run that review before treating the handoff as final.

If the skill asks for a specific plan, spec, or progress path, provide the exact approved artifact path and rerun it.

For the handoff, verify, and resume workflows, prefer `process_id=<YYYY-MM-DD-story-id>` first. Use explicit paths only when you need to override artifact discovery or disambiguate multiple matching plans.

## Behavioral evaluation

Use the scenario files under `tests/scenarios/` together with:

```powershell
pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill story-to-plan -Scenario 01-minimal-valid-story-and-file-path
```

The runner records an evaluation artifact under `artifacts/evaluations/`.

## Troubleshooting

- If the validator reports missing files, restore the canonical source or docs under this package root.
- If distribution drift is reported, rebuild `dist/` from `src/` instead of editing generated files.
- If a workflow stops for a blocker, resolve the missing input or dependency and rerun from the approved artifact.

## Security and permissions

- Do not add unrestricted tool permissions.
- Do not log secrets.
- Do not embed machine-specific absolute paths in repository prose.
- Keep generated content in English unless source material is being quoted verbatim as data.

## Limitations

- The behavioral evaluator records scaffolding for pressure tests, but does not automatically invoke a model.
- Distribution files are generated output and should not be edited manually.
- The package currently focuses on eleven workflow skills used for planning, implementation, resumption, handoff capture, handoff verification, and review.

## Development

1. Edit canonical files under `src/`.
2. Regenerate distributions with the build script.
3. Run the package validator.
4. Review the generated artifacts before shipping.

## License

See [LICENSE](LICENSE).
