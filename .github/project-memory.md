# Project Memory

- This is the shared persistent memory file for this repository and for all supported AI platforms.
- Use `.github/project-memory.md` as the canonical project memory location across Copilot, OpenCode, Claude, Gemini, Codex, and other AI platforms.
- At the start of a task, read this file before making decisions that depend on prior corrections or agreements.
- Record user corrections, durable decisions, reusable knowledge, and carry-over items here.
- Keep entries short, factual, and easy to prune.
- Remove or rewrite items that are no longer valid.

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

- 2026-04-25: When the user asks for Copilot instructions for this repository, they mean the real workspace file in `./.github`, not in the template files under `platforms/`.
- 2026-04-25: The Angular pattern should stay at the level of general development guidance; do not prescribe a fixed UI baseline there. Specific design-system and visual-baseline decisions belong to the analysis and design phases of each real project.
- 2026-04-25: The React pattern should follow the same principle as Angular: keep it at the level of general development guidance and leave framework-specific UI baseline and design-system decisions to the analysis and design phases of each real project.

## Multi-Pattern Deploy (2026-06-05)

- `deploy.ps1` and `deploy.sh` now support multiple patterns in one run via comma-separated input.
- Single pattern → `conventions.md`; multiple patterns → `conventions-{pattern}.md` per pattern.
- `.gitignore` block updated to cover all deployed patterns.
- `deploy.ps1` now fails fast when parsed patterns are empty (e.g., `-t ","`) to avoid silent no-pattern deploy behavior.
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
- Severity levels: Critical → Generate CR + fix now; High → Generate CR + current cycle; Medium → optional CR + next cycle; Low → document only.
- Assessment is divergent (broad discovery) then convergent (targeted CRs), unlike other workflows that start with a specific change.
- `templates/assessment-report.md` is the output template with severity-classified findings and linked Change Requests.
- `Docs/assessment-workflow.md` is the comprehensive documentation for the Assessment workflow.
- `Docs/framework-ai-enhancement-phase.md` includes the complete assessment lifecycle.
- `templates/project-cache.md` now defines the cache schema for `PROJECT_CACHE.md`.
- `Docs/project-cache-system.md` documents the full cache lifecycle and freshness rules.
- `platforms/opencode/opencode.json` includes `PROJECT_CACHE.md` in its instructions list.
- New documentation: `Docs/project-cache-system.md` describes the full system, lifecycle, freshness rules, and migration guide.
- Implementation repurposed the PROJECT_CACHE.md work originally done in parkinson_apps.

## Project Cache (2026-06-20)

- `templates/project-cache.md` defines the `PROJECT_CACHE.md` structure: Metadata, Architecture Map (CA layers or VSA slices + contracts), Domain Map, File Index, Key Decisions & Constraints, Cache Refresh Log.
- `skills/analysis/SKILL.md` Mode 2, Step 2 reads `PROJECT_CACHE.md` first if fresh — avoids redundant file scans.
- `skills/analysis/SKILL.md` Mode 2, Step 8 generates or updates `PROJECT_CACHE.md` after Assessment approval. Sets stale date (Last Updated + 30 days).
- `skills/change-intake/SKILL.md` Pre-Intake Check reads `PROJECT_CACHE.md` as the first context source. If stale (>30 days), asks user about re-assessment.
- Cache lifecycle: **Fresh ≤30 days** → all skills skip scans (~1-2 tool calls for context vs ~8-12 without). **Stale >30 days** → warn user. **Invalidated** → fall back to full scan.
- `Docs/project-cache-system.md` documents the full cache lifecycle with Mermaid decision flow and impact metrics.

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

## Flutter Riverpod ViewModel Pattern (2026-08-15)

- New pattern skill `flutter/skills/flutter-riverpod-viewmodel/SKILL.md` — Riverpod 3.x + Codegen is the **default** state-management + DI pattern for Flutter. Covers dependency set, core rules, DI (repository + use-case providers), 7 ViewModel variants, provider naming, UI consumption, file organization, checklist, 2.x→3.x migration.
- Bloc/Cubit is a **disabled-by-default sub-option** in the Flutter pattern — must be explicitly enabled by the user in the Design phase; never mix Riverpod and Bloc/Cubit for the same feature.
- Legacy Riverpod providers (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`) are forbidden in new code (Riverpod 3.x).
- Use unified `Ref` in codegen — typed refs (`UsersRef`, `GetUsersRef`) are Riverpod 2.x style.
- ViewModels/Notifiers never reference widgets; widgets only observe (`ref.watch`) and trigger (`ref.read(provider.notifier).method()`); async state uses `AsyncValue`.
- Riverpod testing: `ProviderContainer.test()` for unit tests, `ProviderScope.overrides` for widget tests.
- Affected files: new skill + `flutter/conventions.md` + 3 Flutter agents + `flutter-spec`, `flutter-testing`, `flutter-feature`, `flutter-scaffold` skills + `Docs/flutter-riverpod-viewmodel-pattern.md`. VERSION bumped to 0.5.0.

## Flutter Serverpod Backend (2026-08-22)

- New pattern skill `flutter/skills/flutter-serverpod/SKILL.md` — Serverpod as an **opt-in backend sub-option** of the Flutter pattern, enabling a single-language (Dart) full-stack environment.
- Activation: kickoff/design asks the backend question (Serverpod vs external API vs none) when Flutter is selected. Only enabled when explicitly selected.
- `serverpod create <name>` produces a Dart pub workspace: `<name>_server/`, `<name>_client/`, `<name>_flutter/`.
- Backend structure is a user choice (per the `flutter-serverpod` skill): idiomatic Serverpod, Clean Architecture, or Vertical Slice Architecture inside the server.
- Models are `.spy.yaml` files; `serverpod generate` emits `lib/src/generated/` + client code; `serverpod create-migration` handles schema changes.
- Generated client is consumed only in the Flutter `data/` layer behind repositories; `domain/` stays pure Dart; never call `client.*` from widgets/ViewModels.
- Updated: `flutter/conventions.md` (Backend section + packages table), 3 Flutter agents, `flutter-scaffold`, `flutter-feature`, `flutter-spec`, `flutter-testing` skills, `skills/kickoff/SKILL.md`.
- Doc: `Docs/flutter-serverpod-pattern.md`. VERSION bumped 0.5.1 → 0.6.1.

## Flutter Dart Frog Backend (2026-08-22)

- New pattern skill `flutter/skills/flutter-dart-frog/SKILL.md` — Dart Frog as a second **opt-in backend sub-option** of the Flutter pattern (lightweight Dart REST API), alongside Serverpod.
- Activation: kickoff/design backend question now offers Serverpod, Dart Frog, external API, or none. Serverpod and Dart Frog are mutually exclusive alternatives.
- Layout: sibling projects `<name>_app/` (`flutter create`) + `<name>_api/` (`dart_frog create`).
- Backend structure is a user choice: idiomatic Dart Frog (feature-first `routes/`), Clean Architecture, or Vertical Slice Architecture.
- Routes are `onRequest(RequestContext context, ...)` functions; DI via `provider<T>` + `context.read<T>()`.
- Flutter app consumes the API via `http`/`dio` only in the `data/` layer behind repositories; `domain/` stays pure Dart.
- `flutter/conventions.md` backend section generalized to "Backend (Dart single-language)".
- Updated: `flutter/conventions.md`, 3 Flutter agents, `flutter-scaffold`, `flutter-feature`, `flutter-spec`, `flutter-testing`, `skills/kickoff/SKILL.md`.
- Doc: `Docs/flutter-dart-frog-pattern.md`. VERSION bumped 0.6.1 → 0.7.1.

## Carry-Over

- None.

## Vertical Slice Architecture (2026-06-16)

- VSA support added across all 4 patterns (dotnet, flutter, react, angular) and all 7 shared lifecycle skills.
- The kickoff skill (Question #14) interviews the user with 4 diagnostic questions when architecture preference is unknown.
- All shared skills (`kickoff`, `planning`, `analysis`, `design`, `specification`, `implementation`, `testing`, `review`) now have dual architecture paths.
- All pattern conventions now include VSA project structures (e.g., `Features/`, `Shared/`, `Contracts/`) alongside CA structures.
- VSA Key Rules: slices are self-contained, no cross-slice imports, shared kernel for cross-cutting concerns, contracts for cross-slice events.
- See `Docs/vertical-slice-architecture.md` for the full list of affected files.

## Lifecycle Changes (2026-06-03)

- Added `skills/kickoff/SKILL.md`: interactive onboarding, 5-block conversation, produces `PROJECT_INTAKE.md`.
