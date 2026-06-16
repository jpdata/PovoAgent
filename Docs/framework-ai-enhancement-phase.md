# Framework AI Enhancement Phase

## Status

- Active since 2026-04-25.

## Purpose

- Track changes to the Framework core AI files in a consistent place.
- Make repository-wide AI behavior updates auditable across sessions.
- Keep implementation changes and their rationale discoverable for future maintenance.

## Scope

- Workspace instructions under `.github/`.
- Workspace agents under `.github/agents/`.
- Platform instructions under `platforms/`.
- Shared templates under `templates/`.
- Shared lifecycle skills under `skills/`.
- Pattern agents and skills under `dotnet/` and `flutter/`.
- Deploy scripts or related repository files that define or distribute Framework AI behavior.

## Rules

- Any upgrade or update to Framework core AI files must include documentation in `Docs/`.
- Documentation must be written in English.
- Each documentation entry should state what changed, why it changed, and which files were affected.
- Documentation should be created or updated in the same task as the code or instruction change.

## Documented Updates

### 2026-06-05 - OpenCode MCP config schema migration

- Updated `platforms/opencode/opencode.json` MCP server entries from legacy format to current OpenCode schema.
- Replaced `command` string + `args` array with a single `command` array for local MCP servers.
- Replaced `env` with `environment` for the GitHub MCP server.
- Added `enabled: true` to each MCP server entry.
- Why: prevent `ConfigInvalidError` startup failures (`Expected array, got "npx"`) in projects generated from this template.
- Affected files: `platforms/opencode/opencode.json`, `Docs/framework-ai-enhancement-phase.md`.

### 2026-06-16 - Evolutionary lifecycle support added

- Added `skills/change-intake/SKILL.md`: guided intake conversation for work on existing projects (features, modifications, bug fixes, refactors). Routes to appropriate lightweight workflow.
- Added `templates/change-request.md`: template for feature, modification, and refactor change requests.
- Added `templates/bug-report.md`: template for bug reports with diagnosis, fix strategy, and verification.
- Added `Docs/evolutionary-lifecycle.md`: documents the four lightweight workflows (Feature 4-phase, Modification 3-phase, Bug Fix 4-phase, Refactor 4-phase) with Mermaid diagrams, phase tables, and comparison to the new-project lifecycle.
- Updated `templates/povo.agent.md` and `templates/opencode/povo.agent.md`: `change-intake` added to lifecycle skills; "Existing Project" workflow updated to start with `change-intake` and route by change type.
- Updated `.github/copilot-memory.md` with new evolutionary lifecycle conventions.
- Why: the framework was strong for greenfield (new projects) but lacked a structured entry point and lightweight workflows for brownfield work (evolutionary features, corrections, refactors on existing projects).
- Affected files: `skills/change-intake/SKILL.md`, `templates/change-request.md`, `templates/bug-report.md`, `Docs/evolutionary-lifecycle.md`, `Docs/framework-ai-enhancement-phase.md`, `templates/povo.agent.md`, `templates/opencode/povo.agent.md`, `.github/copilot-memory.md`.

### 2026-04-25 - Enhancement phase introduced

- Added enhancement-phase rules to `.github/copilot-instructions.md`.
- Updated `.github/agents/project-wide.agent.md` to require `Docs/` updates when Framework core AI files change.
- Updated `.github/copilot-memory.md` with the durable repository rule.
- Created this document to establish the phase and its documentation policy.
