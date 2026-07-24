# Behavioral Evaluation

The behavioral evaluation layer uses pressure scenarios to check whether the skills preserve their approval gates and evidence rules under realistic pushback.

## Purpose

The scenarios are not unit tests. They are short, adversarial prompts designed to verify that the workflow:

- pauses when input is ambiguous;
- preserves the design and plan gates;
- refuses to skip baseline checks;
- updates progress only after evidence exists;
- resumes from artifacts instead of chat history.

## Scenario layout

Scenario markdown files live under:

- `tests/scenarios/story-to-plan/`
- `tests/scenarios/implement-approved-plan/`
- `tests/scenarios/resume-approved-plan/`
- `tests/scenarios/create-handoff/`
- `tests/scenarios/verify-handoff/`
- `tests/scenarios/self-qa-review/`
- `tests/scenarios/critical-review/`
- `tests/scenarios/adversarial-review/`
- `tests/scenarios/critical-adversarial-review/`
- `tests/scenarios/review-findings-validator/`
- `tests/scenarios/critical-review-with-validation/`

Each scenario should describe:

- the situation;
- the pressure applied to the agent;
- the expected safe response;
- the failure mode the scenario is guarding against.

## Running the evaluator

Use the scaffolded runner to record the evaluation request:

```powershell
pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill story-to-plan -Scenario 01-minimal-valid-story-and-file-path
pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill critical-review-with-validation -Scenario 01-critical-review-with-validation
```

If `-Scenario` is omitted, the runner lists the available scenarios for the selected skill.

## Model invocation policy

The repository runner does not automatically invoke a model.

That is intentional:

- it prevents accidental pressure-test execution;
- it keeps the repository workflow safe in CI-style environments;
- it forces explicit confirmation before any external model action.

If a manual evaluation is performed elsewhere, record the observed behavior in the generated artifact under `artifacts/evaluations/`.

## Package Validation

Run the package validator before and after behavioral evaluation:

```powershell
pwsh ./scripts/Test-SkillPackage.ps1 -Check
```

The validator checks direct skill distributions and the generated plugin marketplace bundle when those outputs exist.

## Artifacts

Behavioral runs write Markdown records under:

- `artifacts/evaluations/`

The final evaluation record should capture:

- the platform and skill under test;
- the selected scenario;
- the observed outcome;
- any deviations from the expected safe behavior;
- follow-up actions if the scenario exposed a bug.
