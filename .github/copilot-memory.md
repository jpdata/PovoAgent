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

## User Corrections

- 2026-04-25: When the user asks for Copilot instructions for this repository, they mean the real workspace file in `./.github`, not the template files under `platforms/`.
- 2026-04-25: The Angular pattern should stay at the level of general development guidance; do not prescribe a fixed UI baseline there. Specific design-system and visual-baseline decisions belong to the analysis and design phases of each real project.
- 2026-04-25: The React pattern should follow the same principle as Angular: keep it at the level of general development guidance and leave framework-specific UI baseline and design-system decisions to the analysis and design phases of each real project.

## Carry-Over

- None.
