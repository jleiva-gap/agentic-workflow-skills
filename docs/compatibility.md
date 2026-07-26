# Compatibility

This package is designed for Windows-first automation with PowerShell 7+.

## Tested baseline

- PowerShell 7.4 or later
- Windows file paths and separators
- Git worktrees
- UTF-8 without BOM

## Supported hosts

- Codex
- GitHub Copilot
- Claude Code

Codex can consume the generated local plugin marketplace bundle under `dist/plugin-marketplace/`. For remote installation, use the repository root `https://github.com/jleiva-gap/agentic-workflow-skills-marketplace` with all three hosts. Codex discovers `.agents/plugins/marketplace.json` and installs the plugin from the marketplace repository root, Claude Code discovers `.claude-plugin/marketplace.json`, and GitHub Copilot CLI discovers the repository-root `marketplace.json`.

The host overlays in `platform/` control distribution roots and host-level support flags. Per-skill invocation metadata is canonical in each `src/skills/<skill>/metadata.json` file. That metadata renders Codex `allowImplicitInvocation` and Copilot/Claude `user-invocable` plus `disable-model-invocation` frontmatter.

User-facing entrypoints remain directly invocable. Internal helpers and reusable review skills may be model-invocable so wrapper skills such as `self-qa-review` can route to `create-handoff` or review variants without hiding downstream dependencies from the host model.

## Mandatory operational rules

- Use PowerShell for build, install, validation, and evaluation scripts.
- Do not rely on Node.js, Python, or Bash for mandatory operations.
- Do not require symbolic links.
- Keep generated copies compatible with Git and Windows file systems.
- Preserve the canonical source in `src/` and treat `dist/` as generated output.

## Runtime expectations

The package assumes:

- the user can run PowerShell 7+;
- the repository can be read from a local working tree;
- Git is available for status and drift checks;
- the three host-specific skill locations are writable when installing.

## Revalidation guidance

Revalidate this package when any of the following change:

- host frontmatter support;
- host skill installation paths;
- the generator format;
- per-skill invocation metadata semantics;
- the shared input or artifact contract;
- the cross-tool handoff template;
- the review findings template;
- the approval or verification gate language.

## Known compatibility constraints

- The package does not depend on a Unix shell.
- The behavioral evaluation runner records scenario runs but does not automate host model invocation.
- The package assumes the current repository layout remains stable for `docs/`, `src/`, `platform/`, `scripts/`, and `tests/`.
