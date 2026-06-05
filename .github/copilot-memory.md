# Copilot Memory

## Durable Knowledge

- This file is the persistent memory for Copilot in this workspace.
- Workspace-level Copilot behavior is defined in `.github/copilot-instructions.md`, not in `platforms/` or `templates/`, unless the user explicitly asks for template changes.
- Workspace-level custom agents for this repository live under `.github/agents/`.
- `project-wide.agent.md` is the repository-wide agent for changes that span root files, shared skills, templates, platforms, or multiple patterns.
- The repository is in the Framework AI enhancement phase.
- Any upgrade or update to Framework core AI files must also be documented under `Docs/`.
- Angular is a supported deployable pattern in this repository.
- React is a supported deployable pattern in this repository.
- Astro is a supported deployable pattern in this repository.
- Deploy pattern discovery is driven by top-level pattern folders that contain `conventions.md`, but README and script help text should still be updated when adding a new supported pattern.
- The Astro pattern is static-first and content-first, with React integration as an optional island strategy rather than a mandatory baseline.
- OpenCode MCP local server config must use the current schema: `command` as array, `environment` (not `env`), and explicit `enabled` to avoid startup `ConfigInvalidError` in generated projects.
- `deploy.ps1` must wrap parsed pattern results in `@(...)`; otherwise a single pattern can become scalar and fail on `$Patterns.Count` under strict mode.
- `deploy.ps1` now fails fast when parsed patterns are empty (e.g., `-t ","`) to avoid silent no-pattern deploy behavior.
- `deploy.sh` now mirrors the same empty-pattern fail-fast validation after trimming/splitting parsed values.

## User Corrections

- 2026-04-25: When the user asks for Copilot instructions for this repository, they mean the real workspace file in `./.github`, not the template files under `platforms/`.
- 2026-04-25: The Angular pattern should stay at the level of general development guidance; do not prescribe a fixed UI baseline there. Specific design-system and visual-baseline decisions belong to the analysis and design phases of each real project.
- 2026-04-25: The React pattern should follow the same principle as Angular: keep it at the level of general development guidance and leave framework-specific UI baseline and design-system decisions to the analysis and design phases of each real project.

## Multi-Pattern Deploy (2026-06-05)

- `deploy.ps1` and `deploy.sh` now support multiple patterns in one run via comma-separated input.
- Single pattern → `conventions.md`; multiple patterns → `conventions-{pattern}.md` per pattern.
- `.gitignore` block updated to cover all deployed patterns.
- See `Docs/multi-pattern-deploy.md` for full details.

## Carry-Over

- None.

## Lifecycle Changes (2026-06-03)

- Added `skills/kickoff/SKILL.md`: interactive onboarding, 5-block conversation, produces `PROJECT_INTAKE.md`.
- Added `skills/planning/SKILL.md`: generates `PROJECT_PLAN.md` with Mermaid diagram, phase table (8 phases), milestone checklist, risk register.
- Full lifecycle is now: Kickoff → Planning → Analysis → Design → Scaffold → Implementation → Testing → Review.
- Scaffold is now an explicit lifecycle phase (was only a pattern-specific skill before).
- Both `templates/povo.agent.md` and `templates/opencode/povo.agent.md` updated to reflect the 8-phase lifecycle and split workflow (new project vs. existing project).
- Added `Docs/new-project-lifecycle.md` documenting the complete flow, artifact map, cross-platform table, cross-pattern table, and milestone checklist template.
