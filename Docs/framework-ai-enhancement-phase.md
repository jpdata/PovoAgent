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

### 2026-04-25 - Enhancement phase introduced

- Added enhancement-phase rules to `.github/copilot-instructions.md`.
- Updated `.github/agents/project-wide.agent.md` to require `Docs/` updates when Framework core AI files change.
- Updated `.github/copilot-memory.md` with the durable repository rule.
- Created this document to establish the phase and its documentation policy.
