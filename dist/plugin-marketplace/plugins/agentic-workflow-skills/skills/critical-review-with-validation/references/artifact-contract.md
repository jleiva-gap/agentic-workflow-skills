# Artifact Contract

The workflows write approved planning artifacts to these default locations:

```text
docs/superpowers/specs/YYYY-MM-DD-<story-id>-design.md
docs/superpowers/plans/YYYY-MM-DD-<story-id>.md
docs/superpowers/handoffs/<story-id>-handoff.md
docs/superpowers/progress/<story-id>-progress.md
```

## Rules

- Normalize only the filename-safe portion of `story_id`.
- Preserve the original story id inside document content.
- Use the plan filename stem `YYYY-MM-DD-<story-id>` as the process id unless the approved artifacts require a different unambiguous code.
- Handoff, verification, and resume workflows should accept the process id as the primary input and resolve standard artifact paths from it.
- A plain story id may be used as a shortcut only when it maps to exactly one process id.
- Explicit artifact paths remain supported and override process id discovery for the specific artifact. Accept both short and explicit aliases such as `plan` or `plan_path`, `spec` or `spec_path`, `handoff` or `handoff_path`, and `progress` or `progress_path`.
- The design specification is the source of truth for expected behavior.
- The implementation plan is the source of truth for task sequencing.
- The handoff must identify the spec, plan, branch, baseline state, first pending task, assumptions, risks, and verification evidence.
- The handoff must include a process id that identifies the exact spec/plan pair being resumed.
- Use bundled `templates/cross-tool-handoff-template.md` for cross-host or cross-agent continuation. In source, the canonical template lives at `src/shared/templates/cross-tool-handoff-template.md`.
- The handoff must be understandable without chat history.
- The `create-handoff` skill is the supported way to generate or refresh the handoff artifact.
- `create-handoff` may infer approved artifact paths from current repository state when the match is unambiguous; otherwise it must ask for the missing path(s).
- The `verify-handoff` skill is the supported way to confirm whether a handoff is safe to reuse before resuming work.
- `verify-handoff` and `resume-approved-plan` may infer their required artifacts from process id when the artifact set is unambiguous.
- The progress file records completed tasks and verification evidence.
- Chat history is never the primary handoff mechanism.
- Existing approved artifacts must not be overwritten without explicit user approval.
- Reruns must detect and report existing artifacts before replacement.
- All generated artifacts must be written in English.
