# Agentic Workflow Skill Cheat Sheet

Use this cheat sheet when you know the work situation and need the right skill chain quickly. Prefer `process_id=<YYYY-MM-DD-story-id>` for handoff, verification, and resume commands. Use explicit paths only when artifact discovery is ambiguous.

## Skill Invocation

| Host | Prefix | Example |
| --- | --- | --- |
| Codex | `$` | `$story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |
| GitHub Copilot | `/` | `/story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |
| Claude Code | `/` | `/story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md` |

Examples below use Codex syntax. Replace `$` with `/` for Copilot or Claude.

## Common Parameters

Use these tables when you need to add detail to a scenario command. Keep the command example minimal, then add only the parameters that matter for the current case.

### Planning

| Skill | Parameter | Example value | When to use it | Description |
| --- | --- | --- | --- | --- |
| `story-to-plan` | `story_id` | `STORY-001` | Always for new planning work | Stable story or ticket identifier used in generated artifact names. |
| `story-to-plan` | `story_source` | `.plans/STORY-001.md` | When the story is in a file or inline text | Source story, feature request, bug report, or acceptance criteria. |
| `story-to-plan` | `notes_source` | `.plans/STORY-001-notes.md` | When there are implementation notes, peer-review findings, or remediation context | Extra context to consider during design and planning. |
| `story-to-plan` | `related_paths` | `src/Feature,tests/Feature.Tests` | When the impacted area is known | Hints for source, tests, docs, or modules to inspect. |
| `story-to-plan` | `constraints` | `no new dependencies` | When nonfunctional limits matter | Security, compatibility, release, dependency, or architecture constraints. |
| `story-to-plan` | `test_command` | `dotnet test ./tests/Feature.Tests` | When there is an expected verification command | Suggested command to consider in the implementation plan. |

### Implementation And Resume

| Skill | Parameter | Example value | When to use it | Description |
| --- | --- | --- | --- | --- |
| `implement-approved-plan` | `<plan-path>` | `docs/superpowers/plans/2026-07-29-STORY-001.md` | Always when implementing | Approved implementation plan to execute. |
| `implement-approved-plan` | `<spec-path>` | `docs/superpowers/specs/2026-07-29-STORY-001-design.md` | When the plan does not clearly link the spec | Approved design spec to enforce during implementation. |
| `resume-approved-plan` | `process_id` | `2026-07-29-STORY-001` | Preferred for normal resume | Resolves the standard spec, plan, handoff, and progress files. |
| `resume-approved-plan` | `story_id` | `STORY-001` | When it maps to exactly one process id | Shortcut when there is no ambiguity. |
| `resume-approved-plan` | `plan` or `plan_path` | `docs/superpowers/plans/2026-07-29-STORY-001.md` | When discovery is ambiguous | Explicit approved plan path. |
| `resume-approved-plan` | `spec` or `spec_path` | `docs/superpowers/specs/2026-07-29-STORY-001-design.md` | When discovery is ambiguous | Explicit approved design spec path. |
| `resume-approved-plan` | `handoff` or `handoff_path` | `docs/superpowers/handoffs/STORY-001-handoff.md` | When using a specific handoff | Explicit handoff path. |
| `resume-approved-plan` | `progress` or `progress_path` | `docs/superpowers/progress/STORY-001-progress.md` | When progress discovery is ambiguous | Explicit progress artifact path. |

### Handoff And Verification

| Skill | Parameter | Example value | When to use it | Description |
| --- | --- | --- | --- | --- |
| `create-handoff` | `process_id` | `2026-07-29-STORY-001` | Preferred for normal handoff refresh | Resolves the standard artifact set. |
| `create-handoff` | `story_id` | `STORY-001` | When it maps to exactly one process id | Shortcut for unambiguous work. |
| `create-handoff` | `plan` or `plan_path` | `docs/superpowers/plans/2026-07-29-STORY-001.md` | When discovery is ambiguous | Explicit plan path. |
| `create-handoff` | `spec` or `spec_path` | `docs/superpowers/specs/2026-07-29-STORY-001-design.md` | When discovery is ambiguous | Explicit spec path. |
| `create-handoff` | `progress` or `progress_path` | `docs/superpowers/progress/STORY-001-progress.md` | When discovery is ambiguous | Explicit progress path. |
| `create-handoff` | `findings` or `findings_report` | `docs/superpowers/reviews/STORY-001-review.md` | When QA or peer review found issues | Review findings report used to refresh a fix-back handoff. |
| `verify-handoff` | `process_id` | `2026-07-29-STORY-001` | Preferred before resume | Resolves the handoff, plan, spec, and progress files. |
| `verify-handoff` | `story_id` | `STORY-001` | When it maps to exactly one process id | Shortcut for unambiguous work. |
| `verify-handoff` | `handoff` or `handoff_path` | `docs/superpowers/handoffs/STORY-001-handoff.md` | When checking a specific handoff | Explicit handoff path. |
| `verify-handoff` | `plan` or `plan_path` | `docs/superpowers/plans/2026-07-29-STORY-001.md` | When discovery is ambiguous | Explicit approved plan path. |
| `verify-handoff` | `spec` or `spec_path` | `docs/superpowers/specs/2026-07-29-STORY-001-design.md` | When discovery is ambiguous | Explicit approved spec path. |
| `verify-handoff` | `progress` or `progress_path` | `docs/superpowers/progress/STORY-001-progress.md` | When discovery is ambiguous | Explicit progress path. |

### Reviews

| Skill | Parameter | Example value | When to use it | Description |
| --- | --- | --- | --- | --- |
| Review skills | `story_file` | `.plans/STORY-001.md` | Always for review work | Story, ticket, or acceptance criteria to review against. |
| Review skills | `repo_root` | `.` | When running outside the target repo root | Repository root override. |
| Review skills | `output_dir` | `docs/superpowers/reviews` | When storing generated reports predictably | Directory for review, validation, or handoff outputs. |
| Review skills | `base_ref` | `main` | When reviewing branch changes | Git ref for diff comparison. |
| Review skills | `review_scope` | `src/Feature,tests/Feature.Tests` | When review should be limited | Files, modules, or behavior to inspect. |
| Review skills | `agent_name` | `codex-reviewer` | When multiple reviewers write artifacts | Reviewer label in outputs. |
| Review skills | `run_tests` | `targeted` | When tests may be run during review | Test policy for validation. |
| Review skills | `token_budget` | `12000` | When review scope needs budget control | Budget guidance for the review pass. |
| `critical-review` | `output_mode` | `concise` | When report detail needs control | Report detail or format preference. |
| `self-qa-review` | `review_type` | `critical-with-validation` | When generating a new self-QA review | Selects `critical`, `adversarial`, `critical-adversarial`, or `critical-with-validation`. |
| `self-qa-review` | `review_file` | `docs/superpowers/reviews/STORY-001-review.md` | When reusing existing findings | Existing findings report to use for remediation instead of generating a new review. |
| `self-qa-review` | `commands` | `dotnet test ./tests/Feature.Tests` | When reviewer may inspect specific commands | Commands the reviewer may run or consider. |
| `review-findings-validator` | `review_report` | `docs/superpowers/reviews/STORY-001-peer-review.md` | Always when validating a report | Existing review report to validate, deduplicate, downgrade, or reject. |

## Case 1: Implementing a New Story

Use this when the work starts from a story, feature request, bug report, or acceptance criteria and no approved design or plan exists yet.

1. Convert the story into approved artifacts:

```text
$story-to-plan story_id=STORY-001 story_source=.plans/STORY-001.md
```

2. Review and approve the design spec when the skill asks.
3. Review and approve the implementation plan when the skill asks.
4. Let `story-to-plan` create the initial handoff.
5. Implement the approved plan:

```text
$implement-approved-plan docs/superpowers/plans/2026-07-29-STORY-001.md
```

6. Run final independent QA:

```text
$self-qa-review story_file=.plans/STORY-001.md review_type=critical-with-validation
```

7. If QA passes, create a final checkpoint:

```text
$create-handoff process_id=2026-07-29-STORY-001
```

8. If QA finds issues, use the findings report as remediation context:

```text
$create-handoff process_id=2026-07-29-STORY-001 findings=docs/superpowers/reviews/STORY-001-review.md
$story-to-plan story_id=STORY-001-remediation story_source=.plans/STORY-001.md notes_source=docs/superpowers/reviews/STORY-001-review.md
```

## Case 2: Implementing an Already Approved Plan

Use this when another agent or prior session already produced an approved spec and plan.

```text
$implement-approved-plan docs/superpowers/plans/2026-07-29-STORY-001.md
```

Expected behavior:

- read the linked spec and plan before editing;
- check repository state and baseline verification;
- implement one plan task at a time;
- update progress only after verification evidence exists;
- stop on blockers instead of silently changing scope.

## Case 3: Reviewing a Peer Implementation

Use this when someone else implemented a story and you need an evidence-based review before the work is accepted.

Recommended default:

```text
$critical-review-with-validation story_file=.plans/STORY-001.md base_ref=main
```

Use a narrower review when needed:

| Need | Skill |
| --- | --- |
| Strict acceptance-criteria review | `$critical-review story_file=.plans/STORY-001.md base_ref=main` |
| Edge cases, abuse cases, regressions, and hidden failures | `$adversarial-review story_file=.plans/STORY-001.md base_ref=main` |
| One pass for strict review plus adversarial pressure | `$critical-adversarial-review story_file=.plans/STORY-001.md base_ref=main` |
| Strict review plus second-pass finding validation | `$critical-review-with-validation story_file=.plans/STORY-001.md base_ref=main` |

Review output should be a findings report that separates confirmed defects from assumptions, risks, and non-blocking notes.

Storage options:

- Use `output_dir=<directory>` when generating a new review or validation report and you want it stored somewhere predictable.
- Use `review_report=<file>` with `review-findings-validator` when validating an existing peer review file.
- Use `review_file=<file>` with `self-qa-review` when reusing an existing findings report for remediation instead of generating a new review.

## Case 4: Planning Remediation From a Peer Review Report

Use this when a reviewer already produced findings and you need a clean fix plan, not immediate patching.

1. Validate the report if the findings are high impact, unclear, duplicated, or possibly stale:

```text
$review-findings-validator story_file=.plans/STORY-001.md review_report=docs/superpowers/reviews/STORY-001-peer-review.md
```

2. Refresh the implementation handoff with the validated findings:

```text
$create-handoff process_id=2026-07-29-STORY-001 findings=docs/superpowers/reviews/STORY-001-peer-review-validation.md
```

3. Plan the remediation as a scoped follow-up:

```text
$story-to-plan story_id=STORY-001-remediation story_source=.plans/STORY-001.md notes_source=docs/superpowers/reviews/STORY-001-peer-review-validation.md
```

4. Implement only after the remediation spec and plan are approved:

```text
$implement-approved-plan docs/superpowers/plans/2026-07-29-STORY-001-remediation.md
```

## Case 5: Creating a Handoff in the Middle of a Task

Use this before pausing, switching tools, changing agents, or leaving work for later.

1. Verify the last completed task if possible.
2. Do not mark unverified work as complete in the progress artifact.
3. Refresh the handoff:

```text
$create-handoff process_id=2026-07-29-STORY-001
```

4. Include the process id in the next session prompt:

```text
Resume process_id=2026-07-29-STORY-001
```

The handoff should summarize what is approved, what is verified, what changed, what remains, and what evidence can be trusted.

## Case 6: Retaking or Resuming Interrupted Work

Use this when the work has a prior spec, plan, handoff, or progress file.

Recommended safe resume:

```text
$verify-handoff process_id=2026-07-29-STORY-001
$resume-approved-plan process_id=2026-07-29-STORY-001
```

Skip `verify-handoff` only when the handoff was just created and nothing has changed since then.

If verification reports drift:

| Result | Next step |
| --- | --- |
| Handoff is current | Run `resume-approved-plan`. |
| Handoff is stale but artifacts agree | Run `create-handoff`, then resume. |
| Plan, spec, progress, and code disagree | Stop and reconcile the artifacts before coding. |
| Current code has unverified partial work | Preserve it, inspect it, and resume from the first genuinely incomplete task. |

## Case 7: Self-QA Before Calling Work Done

Use this after implementation and normal verification have passed.

```text
$self-qa-review story_file=.plans/STORY-001.md review_type=critical-with-validation
```

Other useful `review_type` values:

| Review type | Use when |
| --- | --- |
| `critical` | You need acceptance-criteria coverage only. |
| `adversarial` | You need edge-case and regression pressure testing. |
| `critical-adversarial` | You need one combined strict and adversarial pass. |
| `critical-with-validation` | You want the safest default: strict review plus validation. |

If findings exist, treat the review report as fix-back context and refresh the handoff before remediation planning.

If a findings report already exists and you only need the remediation handoff, reuse that file:

```text
$self-qa-review story_file=.plans/STORY-001.md review_file=docs/superpowers/reviews/STORY-001-review.md
```

## Case 8: Checking an Old Handoff Before Trusting It

Use this when a handoff was created in an earlier day, branch, tool, or chat.

```text
$verify-handoff process_id=2026-07-29-STORY-001
```

Use the result as the gate:

- `reuse`: the handoff still matches the approved artifacts and current state.
- `refresh`: update the handoff with `create-handoff` before resuming.
- `stop`: the mismatch is structural; reconcile the plan, spec, progress, or code first.

## Case 9: Choosing Among Review Skills

| Situation | Best first choice |
| --- | --- |
| Peer says "please review my branch" | `critical-review-with-validation` |
| You only need acceptance criteria checked | `critical-review` |
| You are worried about surprising edge cases | `adversarial-review` |
| You need one reviewer to do both strict and adversarial checks | `critical-adversarial-review` |
| A review report already exists and may contain weak findings | `review-findings-validator` |
| Finished implementation needs review plus remediation handoff support | `self-qa-review` |

## Case 10: Tool Transfer

Use this when work moves between Codex, GitHub Copilot, Claude Code, or a human maintainer.

1. Create or refresh the handoff:

```text
$create-handoff process_id=2026-07-29-STORY-001
```

2. Give the next executor the process id and repository branch.
3. The next executor starts with:

```text
$verify-handoff process_id=2026-07-29-STORY-001
$resume-approved-plan process_id=2026-07-29-STORY-001
```

Do not rely on the previous chat transcript as the source of truth.

## Fast Decision Table

| Situation | Use |
| --- | --- |
| New story needs design and plan | `story-to-plan` |
| Approved plan is ready for code | `implement-approved-plan` |
| Work paused or moves tools | `create-handoff` |
| Old handoff might be stale | `verify-handoff` |
| Continue interrupted work | `resume-approved-plan` |
| Finished implementation needs QA | `self-qa-review` |
| Peer implementation needs strict review | `critical-review-with-validation` |
| Existing review report needs triage | `review-findings-validator` |
| Review findings need planned fixes | `review-findings-validator` -> `create-handoff` -> `story-to-plan` |

## Defaults That Prevent Drift

- Start from `story-to-plan` unless a spec and plan are already approved.
- Use `process_id` for handoff, verify, and resume.
- Keep chat history secondary to spec, plan, progress, handoff, git state, and test evidence.
- Do not mark progress complete without verification evidence.
- Use `critical-review-with-validation` as the default peer review and self-QA review variant.
- Refresh the handoff after meaningful verified milestones and before switching tools.
