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
- Vertical Slice Architecture (VSA) is now a first-class architecture choice alongside Clean Architecture (CA) across all patterns (dotnet, flutter, react, angular). The kickoff skill interviews the user with diagnostic questions when the preference is unknown.
- When a pattern skill has dual architecture support, always ask about the architecture style before generating code if it is not already defined in the project intake.

## User Corrections

- 2026-04-25: When the user asks for Copilot instructions for this repository, they mean the real workspace file in `./.github`, not the template files under `platforms/`.
- 2026-04-25: The Angular pattern should stay at the level of general development guidance; do not prescribe a fixed UI baseline there. Specific design-system and visual-baseline decisions belong to the analysis and design phases of each real project.
- 2026-04-25: The React pattern should follow the same principle as Angular: keep it at the level of general development guidance and leave framework-specific UI baseline and design-system decisions to the analysis and design phases of each real project.

## Multi-Pattern Deploy (2026-06-05)

- `deploy.ps1` and `deploy.sh` now support multiple patterns in one run via comma-separated input.
- Single pattern → `conventions.md`; multiple patterns → `conventions-{pattern}.md` per pattern.
- `.gitignore` block updated to cover all deployed patterns.
- See `Docs/multi-pattern-deploy.md` for full details.

## Evolutionary Lifecycle (2026-06-16)

- `skills/change-intake/SKILL.md` is the entry point for all work on existing projects (counterpart to `kickoff` for new projects).
- The `change-intake` skill produces `CHANGE_REQUEST.md` (features, modifications, refactors) or `BUG_REPORT.md` (bug fixes).
- Four lightweight workflows exist: Feature (4 phases), Modification (3 phases), Bug Fix (4 phases), Refactor (4 phases).
- `Docs/evolutionary-lifecycle.md` documents the complete evolutionary lifecycle with Mermaid diagrams and phase tables.
- `templates/change-request.md` and `templates/bug-report.md` are the document templates for evolutionary work.
- When working on an existing project, always start with `change-intake` instead of `kickoff`.

## Assessment Workflow (2026-06-20)

- `skills/change-intake/SKILL.md` now supports **Assessment** as a fifth change type, producing `ASSESSMENT_REPORT.md`.
- `skills/analysis/SKILL.md` operates in **two modes**: Mode 1 (New Project Analysis) and **Mode 2 (Existing Project Assessment)** with 8 steps including cache generation.
- Assessment performs a holistic audit across three dimensions: **Architecture** (SOLID, decoupling, patterns, structure), **Technical** (performance, security, maintainability, dependencies, debt), and **Flows** (user flows, data flows, API contracts, cross-slice).
- `Docs/evolutionary-lifecycle.md` includes **Workflow E — Assessment** (3 phases + optional CR generation).
- `templates/assessment-report.md` is the output template with severity-classified findings and linked Change Requests.
- `Docs/assessment-workflow.md` is the comprehensive documentation for the Assessment workflow.
- Severity levels: Critical → Generate CR + fix now; High → Generate CR + current cycle; Medium → optional CR + next cycle; Low → document only.
- Assessment is divergent (broad discovery) then convergent (targeted CRs), unlike other workflows that start with a specific change.

## Project Cache System (2026-07-02)

- `PROJECT_CACHE.md` is a machine-generated, machine-read persistent snapshot of the target project's architecture, domain map, file layout, and symbol index.
- `templates/project-cache.md` is the core schema template, now with **Symbol Index** and **Import/Export Map** sections to eliminate grep-based symbol location.
- `templates/povo.agent.md` has a new **Project Cache** section defining lifecycle, freshness rules, and incremental update rules.
- **All lifecycle skills** (design, implementation, testing, review, specification) now have a **Pre-Step** that reads `PROJECT_CACHE.md` before scanning the codebase.
- `change-intake` already reads the cache (Pre-Intake Check). `analysis` already generates it (Mode 2, Step 8).
- All four platform configs (Copilot, Claude, Gemini, OpenCode) now reference `PROJECT_CACHE.md`.
- `opencode.json` includes `PROJECT_CACHE.md` in its instructions list.
- New documentation: `Docs/project-cache-system.md` describes the full system, lifecycle, freshness rules, and migration guide.
- Implementation repurposed the PROJECT_CACHE.md work originally done in parkinson_apps.

## Project Cache (2026-06-20)

- `templates/project-cache.md` defines the `PROJECT_CACHE.md` structure: Metadata, Architecture Map (CA layers or VSA slices + contracts), Domain Map, File Index, Key Decisions & Constraints, Cache Refresh Log.
- `skills/analysis/SKILL.md` Mode 2, Step 2 reads `PROJECT_CACHE.md` first if fresh — avoids redundant file scans.
- `skills/analysis/SKILL.md` Mode 2, Step 8 generates or updates `PROJECT_CACHE.md` after Assessment approval. Sets stale date (Last Updated + 30 days).
- `skills/change-intake/SKILL.md` Pre-Intake Check reads `PROJECT_CACHE.md` as the first context source. If stale (>30 days), asks user about re-assessment.
- Cache lifecycle: **Fresh ≤30 days** → all skills skip scans (~1-2 tool calls for context vs ~8-12 without). **Stale >30 days** → warn user. **Invalidated** → fall back to full scan.
- `Docs/assessment-workflow.md` documents the full cache lifecycle with Mermaid decision flow and impact metrics.

## Git Hooks Deploy (2026-06-20)

- `deploy.ps1` now supports `-GitHooks` (`-gh`) switch and interactive prompt to deploy git hooks.
- `deploy.sh` now supports `-g` flag and interactive prompt for the same.
- Hooks are deployed to `$Target/.git/hooks/pre-commit`, made executable on Unix.
- The pre-commit hook auto-increments the patch version in the target project's `VERSION` file on every commit.
- Interactive mode asks "Deploy git hooks (pre-commit auto-version-bump)? (y/N)" when flag is not provided.
- `README.md` documents the hook with usage examples, behavior description, and updated deploy process.

## Flutter Hook System (2026-07-06)

- New `hooks/pre-commit-flutter` hook that bumps `VERSION` AND syncs `pubspec.yaml` version field, preserving build number (`+N`).
- `deploy.ps1` and `deploy.sh` now auto-select the hook: if Flutter is among the selected patterns → `pre-commit-flutter`, otherwise → generic `pre-commit`.
- Multi-pattern deploys including Flutter use the Flutter hook (harmless for non-Flutter patterns — warns if `pubspec.yaml` missing).
- Summary output shows which hook type was deployed.
- Full documentation in `Docs/flutter-hook-system.md`.

## Flutter MSIX Installer Skill (2026-07-18)

- New pattern-specific skill `flutter/skills/flutter-msix-installer/SKILL.md` for creating self-contained MSIX installers for Flutter Windows desktop apps.
- Ported from the NpGmao project where it was built and tested for real-world Windows distribution.
- Covers: prerequisites, msix_config setup in pubspec.yaml, build & package via `dart run msix:create`, DLL verification (Flutter engine + plugins + VC++ Redist), beta distribution with certificate, storage path guidance (`path_provider` vs `Platform.resolvedExecutable`), and sign-off checklist.
- Requires the project to have a working `flutter build windows --release`, a `.pfx` certificate, and a logo image.
- msix v3.18.0+ is critical for automatic VC++ Redist DLL bundling.
- Documentation in `Docs/flutter-msix-installer.md`.

## Carry-Over

- None.

## Vertical Slice Architecture (2026-06-16)

- VSA support added across all 4 patterns (dotnet, flutter, react, angular) and all 7 shared lifecycle skills.
- The kickoff skill (Question #14) interviews the user with 4 diagnostic questions when architecture preference is unknown.
- All shared skills (`kickoff`, `planning`, `analysis`, `design`, `specification`, `implementation`, `testing`, `review`) now have dual architecture paths.
- All pattern conventions now include VSA project structures (e.g., `Features/`, `Shared/`, `Contracts/`) alongside CA structures.
- All pattern skills (scaffold, feature, testing) now include pre-questions about architecture and dual procedure paths.
- Pattern architect agents updated to recommend CA or VSA according to the project's choice.
- VSA Key Rules: slices are self-contained, no cross-slice imports, shared kernel for cross-cutting concerns, contracts for cross-slice events.
- See `Docs/vertical-slice-architecture.md` for the full list of affected files.

## Lifecycle Changes (2026-06-03)

- Added `skills/kickoff/SKILL.md`: interactive onboarding, 5-block conversation, produces `PROJECT_INTAKE.md`.
- Added `skills/planning/SKILL.md`: generates `PROJECT_PLAN.md` with Mermaid diagram, phase table (8 phases), milestone checklist, risk register.
- Full lifecycle is now: Kickoff → Planning → Analysis → Design → Scaffold → Implementation → Testing → Review.
- Scaffold is now an explicit lifecycle phase (was only a pattern-specific skill before).
- Both `templates/povo.agent.md` and `templates/opencode/povo.agent.md` updated to reflect the 8-phase lifecycle and split workflow (new project vs. existing project).
- Added `Docs/new-project-lifecycle.md` documenting the complete flow, artifact map, cross-platform table, cross-pattern table, and milestone checklist template.
