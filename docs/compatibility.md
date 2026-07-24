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

Codex can consume the generated local plugin marketplace bundle under `dist/plugin-marketplace/`. When the Codex surface supports marketplace import, it can also point at a GitHub repository or other marketplace URL that resolves to the generated bundle. Claude Code can consume `dist/plugin-marketplace/hosts/claude-marketplace/` through `/plugin marketplace add` or `claude plugin marketplace add`, including a GitHub repository URL or remote `marketplace.json` source. GitHub Copilot CLI can consume `dist/plugin-marketplace/hosts/copilot-marketplace/` through `copilot plugin marketplace add` plus `copilot plugin install`, including a GitHub repository URL or remote `marketplace.json` source.

The host overlays in `platform/` control the generated frontmatter and invocation metadata for each host. That is the adapter layer: canonical workflow behavior stays in `src/`, while the host wrapper changes only how the skill is invoked.

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
- the shared input or artifact contract;
- the cross-tool handoff template;
- the approval or verification gate language.

## Known compatibility constraints

- The package does not depend on a Unix shell.
- The behavioral evaluation runner records scenario runs but does not automate host model invocation.
- The package assumes the current repository layout remains stable for `docs/`, `src/`, `platform/`, `scripts/`, and `tests/`.
