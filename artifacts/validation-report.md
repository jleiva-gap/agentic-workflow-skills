# Package Validation Report

Generated: 2026-07-24T17:59:37.4334688-06:00
Git commit: 8772a8b
PowerShell: 7.6.3

| Check | Status | Details |
| --- | --- | --- |
| package root | PASS | Located |
| docs\architecture.md | PASS | Present |
| docs\compatibility.md | PASS | Present |
| docs\authoring.md | PASS | Present |
| docs\evaluation.md | PASS | Present |
| docs\workflow-handoff.md | PASS | Present |
| docs\agentic-workflow-manual.md | PASS | Present |
| docs\agentic-workflow-diagrams.md | PASS | Present |
| scripts\Build-SkillDistributions.ps1 | PASS | Present |
| scripts\Install-AgenticWorkflowSkills.ps1 | PASS | Present |
| scripts\Build-AgenticWorkflowPlugin.ps1 | PASS | Present |
| scripts\Install-AgenticWorkflowPlugin.ps1 | PASS | Present |
| scripts\Test-SkillPackage.ps1 | PASS | Present |
| scripts\Invoke-BehavioralEvaluation.ps1 | PASS | Present |
| src\shared\references\input-contract.md | PASS | Present |
| src\shared\references\artifact-contract.md | PASS | Present |
| src\shared\references\superpowers-dependencies.md | PASS | Present |
| src\shared\references\blocking-conditions.md | PASS | Present |
| src\shared\templates\cross-tool-handoff-template.md | PASS | Present |
| src\shared\templates\design-handoff-template.md | PASS | Present |
| src\shared\templates\implementation-progress-template.md | PASS | Present |
| src\skills\story-to-plan\body.md | PASS | Present |
| src\skills\story-to-plan\metadata.json | PASS | Present |
| src\skills\implement-approved-plan\body.md | PASS | Present |
| src\skills\implement-approved-plan\metadata.json | PASS | Present |
| src\skills\resume-approved-plan\body.md | PASS | Present |
| src\skills\resume-approved-plan\metadata.json | PASS | Present |
| src\skills\create-handoff\body.md | PASS | Present |
| src\skills\create-handoff\metadata.json | PASS | Present |
| src\skills\verify-handoff\body.md | PASS | Present |
| src\skills\verify-handoff\metadata.json | PASS | Present |
| src\skills\self-qa-review\body.md | PASS | Present |
| src\skills\self-qa-review\metadata.json | PASS | Present |
| src\skills\critical-review\body.md | PASS | Present |
| src\skills\critical-review\metadata.json | PASS | Present |
| src\skills\adversarial-review\body.md | PASS | Present |
| src\skills\adversarial-review\metadata.json | PASS | Present |
| src\skills\critical-adversarial-review\body.md | PASS | Present |
| src\skills\critical-adversarial-review\metadata.json | PASS | Present |
| src\skills\review-findings-validator\body.md | PASS | Present |
| src\skills\review-findings-validator\metadata.json | PASS | Present |
| src\skills\critical-review-with-validation\body.md | PASS | Present |
| src\skills\critical-review-with-validation\metadata.json | PASS | Present |
| tests\scenarios\story-to-plan\01-minimal-valid-story-and-file-path.md | PASS | Present |
| tests\scenarios\story-to-plan\02-inline-story-with-no-file.md | PASS | Present |
| tests\scenarios\story-to-plan\03-missing-story-source.md | PASS | Present |
| tests\scenarios\story-to-plan\04-ambiguous-acceptance-criterion.md | PASS | Present |
| tests\scenarios\story-to-plan\05-user-demands-immediate-implementation.md | PASS | Present |
| tests\scenarios\story-to-plan\06-existing-spec-and-plan-already-present.md | PASS | Present |
| tests\scenarios\story-to-plan\07-contradictory-story-and-notes.md | PASS | Present |
| tests\scenarios\story-to-plan\08-missing-brainstorming.md | PASS | Present |
| tests\scenarios\story-to-plan\09-missing-writing-plans.md | PASS | Present |
| tests\scenarios\story-to-plan\10-approved-design-but-no-written-spec-approval.md | PASS | Present |
| tests\scenarios\story-to-plan\11-skip-alternative-analysis.md | PASS | Present |
| tests\scenarios\story-to-plan\12-attempt-to-write-code-during-planning.md | PASS | Present |
| tests\scenarios\implement-approved-plan\01-clean-repo-and-passing-baseline.md | PASS | Present |
| tests\scenarios\implement-approved-plan\02-dirty-repo-with-unrelated-changes.md | PASS | Present |
| tests\scenarios\implement-approved-plan\03-already-inside-a-worktree.md | PASS | Present |
| tests\scenarios\implement-approved-plan\04-failing-baseline-tests.md | PASS | Present |
| tests\scenarios\implement-approved-plan\05-plan-spec-contradiction.md | PASS | Present |
| tests\scenarios\implement-approved-plan\06-missing-file-referenced-by-plan.md | PASS | Present |
| tests\scenarios\implement-approved-plan\07-user-asks-to-skip-tests.md | PASS | Present |
| tests\scenarios\implement-approved-plan\08-mark-task-complete-without-evidence.md | PASS | Present |
| tests\scenarios\implement-approved-plan\09-subagent-driven-skill-unavailable-executing-plans-available.md | PASS | Present |
| tests\scenarios\implement-approved-plan\10-both-execution-skills-unavailable.md | PASS | Present |
| tests\scenarios\implement-approved-plan\11-partial-task-failure.md | PASS | Present |
| tests\scenarios\implement-approved-plan\12-final-regression-failure.md | PASS | Present |
| tests\scenarios\resume-approved-plan\01-correctly-checked-completed-task.md | PASS | Present |
| tests\scenarios\resume-approved-plan\02-falsely-checked-incomplete-task.md | PASS | Present |
| tests\scenarios\resume-approved-plan\03-completed-code-with-unchecked-plan-task.md | PASS | Present |
| tests\scenarios\resume-approved-plan\04-partially-implemented-uncommitted-task.md | PASS | Present |
| tests\scenarios\resume-approved-plan\05-new-branch-with-stale-progress-file.md | PASS | Present |
| tests\scenarios\resume-approved-plan\06-prior-chat-unavailable.md | PASS | Present |
| tests\scenarios\resume-approved-plan\07-pre-existing-failing-test.md | PASS | Present |
| tests\scenarios\resume-approved-plan\08-plan-changed-after-implementation-began.md | PASS | Present |
| tests\scenarios\resume-approved-plan\09-conflicting-commits-and-progress-record.md | PASS | Present |
| tests\scenarios\resume-approved-plan\10-user-asks-to-restart-everything-unnecessarily.md | PASS | Present |
| tests\scenarios\resume-approved-plan\11-process-id-first-ux.md | PASS | Present |
| tests\scenarios\create-handoff\01-create-handoff-from-current-state.md | PASS | Present |
| tests\scenarios\create-handoff\02-refresh-stale-handoff.md | PASS | Present |
| tests\scenarios\create-handoff\03-process-id-first-ux.md | PASS | Present |
| tests\scenarios\verify-handoff\01-safe-to-reuse.md | PASS | Present |
| tests\scenarios\verify-handoff\02-stale-handoff-needs-refresh.md | PASS | Present |
| tests\scenarios\verify-handoff\03-process-id-first-ux.md | PASS | Present |
| tests\scenarios\self-qa-review\01-run-self-qa-review-and-create-remediation-handoff.md | PASS | Present |
| tests\scenarios\self-qa-review\02-reuse-existing-findings-for-fix-back.md | PASS | Present |
| tests\scenarios\critical-review\01-static-review-only.md | PASS | Present |
| tests\scenarios\adversarial-review\01-pressure-test-edge-cases.md | PASS | Present |
| tests\scenarios\critical-adversarial-review\01-critical-plus-adversarial.md | PASS | Present |
| tests\scenarios\review-findings-validator\01-triage-an-existing-review.md | PASS | Present |
| tests\scenarios\critical-review-with-validation\01-critical-review-with-validation.md | PASS | Present |
| src\skills\story-to-plan\metadata.json | PASS | Valid canonical metadata |
| src\skills\implement-approved-plan\metadata.json | PASS | Valid canonical metadata |
| src\skills\resume-approved-plan\metadata.json | PASS | Valid canonical metadata |
| src\skills\create-handoff\metadata.json | PASS | Valid canonical metadata |
| src\skills\verify-handoff\metadata.json | PASS | Valid canonical metadata |
| src\skills\self-qa-review\metadata.json | PASS | Valid canonical metadata |
| src\skills\critical-review\metadata.json | PASS | Valid canonical metadata |
| src\skills\adversarial-review\metadata.json | PASS | Valid canonical metadata |
| src\skills\critical-adversarial-review\metadata.json | PASS | Valid canonical metadata |
| src\skills\review-findings-validator\metadata.json | PASS | Valid canonical metadata |
| src\skills\critical-review-with-validation\metadata.json | PASS | Valid canonical metadata |
| src\skills\story-to-plan\body.md | PASS | No placeholder tokens found |
| src\skills\implement-approved-plan\body.md | PASS | No placeholder tokens found |
| src\skills\resume-approved-plan\body.md | PASS | No placeholder tokens found |
| src\skills\create-handoff\body.md | PASS | No placeholder tokens found |
| src\skills\verify-handoff\body.md | PASS | No placeholder tokens found |
| src\skills\self-qa-review\body.md | PASS | No placeholder tokens found |
| src\skills\critical-review\body.md | PASS | No placeholder tokens found |
| src\skills\adversarial-review\body.md | PASS | No placeholder tokens found |
| src\skills\critical-adversarial-review\body.md | PASS | No placeholder tokens found |
| src\skills\review-findings-validator\body.md | PASS | No placeholder tokens found |
| src\skills\critical-review-with-validation\body.md | PASS | No placeholder tokens found |
| README.md | PASS | No placeholder tokens found |
| AGENTS.md | PASS | No placeholder tokens found |
| CHANGELOG.md | PASS | No placeholder tokens found |
| docs\architecture.md | PASS | No placeholder tokens found |
| docs\compatibility.md | PASS | No placeholder tokens found |
| docs\authoring.md | PASS | No placeholder tokens found |
| docs\evaluation.md | PASS | No placeholder tokens found |
| dist layout | SKIP | dist/ is not present yet. |
| Build-SkillDistributions.ps1 -Check | SKIP | dist/ is not present yet. |
| plugin layout | SKIP | dist/plugin-marketplace is not present yet. |
| Build-AgenticWorkflowPlugin.ps1 -Check | SKIP | dist/plugin-marketplace is not present yet. |

## Commands

- `pwsh ./scripts/Build-SkillDistributions.ps1 -Check`
- `pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1 -Check`
- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill story-to-plan -Scenario 01-minimal-valid-story-and-file-path`
- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill self-qa-review -Scenario 01-run-self-qa-review-and-create-remediation-handoff`
- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill critical-review-with-validation -Scenario 01-critical-review-with-validation`

