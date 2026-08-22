# Flutter Serverpod Pattern

## What Changed

Integrated **Serverpod** as an opt-in backend sub-option of the Flutter pattern,
enabling a single-language (Dart) environment for full-stack app development:
Flutter on the front, Serverpod on the back. The integration follows the same
layering used for the Riverpod ViewModel pattern:

1. **New pattern skill** — `flutter/skills/flutter-serverpod/SKILL.md` codifies
   the full backend workflow: prerequisites, CLI install, `serverpod create`
   workspace layout (`_server`, `_client`, `_flutter`), local run commands,
   three backend structure options (idiomatic Serverpod, Clean Architecture,
   Vertical Slice Architecture), models (`.spy.yaml`), endpoints, migrations,
   generated-client integration into the Flutter data layer, and Serverpod
   testing.
2. **Conventions alignment** — `flutter/conventions.md` gained a backend
   section (later generalized to "Backend (Dart single-language)" to also
   cover Dart Frog): single language, workspace layout, three backend
   structures, client integration rules, codegen commands, decoupling rules —
   plus four Serverpod rows in the Common Packages table.
3. **Existing skill alignment** — `flutter-scaffold`, `flutter-feature`,
   `flutter-spec`, and `flutter-testing` route through the Serverpod pattern
   when the backend option is enabled.
4. **Agent alignment** — the three Flutter agents (architect, developer,
   reviewer) now cover Serverpod backend design, endpoint/model implementation,
   and review checks respectively.
5. **Kickoff alignment** — `skills/kickoff/SKILL.md` asks the backend question
   (Serverpod vs external API vs none) when Flutter is selected.

## Why It Changed

The Flutter pattern previously assumed an external backend: the data layer used
`http`/`dio` against some REST/GraphQL API. With Serverpod, the backend is also
written in Dart and a client is generated, eliminating hand-written
serialization and context-switching between languages. This makes Flutter a
full-stack option: one language, one codebase, one toolchain from database to
UI.

## Files Affected

| File                                        | Change                                                                                                                                                                             |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flutter/skills/flutter-serverpod/SKILL.md` | **New** — Full Serverpod backend skill (prereqs, CLI, workspace layout, run commands, 3 backend structures, models, endpoints, migrations, client integration, testing, checklist) |
| `flutter/conventions.md`                    | **Updated** — Added a backend section (now "Backend (Dart single-language)") + decoupling rules + 4 packages in the Common Packages table                                                                     |
| `flutter/skills/flutter-scaffold/SKILL.md`  | **Updated** — Full-stack scaffold path (`serverpod create` workspace) + backend pre-scaffold question                                                                              |
| `flutter/skills/flutter-feature/SKILL.md`   | **Updated** — Serverpod endpoint + model + generated-client integration steps                                                                                                      |
| `flutter/skills/flutter-spec/SKILL.md`      | **Updated** — Serverpod endpoint/model spec units + server test mapping                                                                                                            |
| `flutter/skills/flutter-testing/SKILL.md`   | **Updated** — Serverpod server tests (`serverpod test`, `withServerpod`)                                                                                                           |
| `flutter/agents/flutter-architect.agent.md` | **Updated** — Backend design: endpoints, models, database, backend structure choice                                                                                                |
| `flutter/agents/flutter-developer.agent.md` | **Updated** — Endpoint/model implementation, `serverpod generate`/`create-migration`, client integration in the data layer                                                         |
| `flutter/agents/flutter-reviewer.agent.md`  | **Updated** — Serverpod review checks (stateless endpoints, typed signatures, `generated/` untouched, client behind repositories)                                                  |
| `skills/kickoff/SKILL.md`                   | **Updated** — Backend question (Serverpod vs external API vs none) added to the Flutter technology question                                                                        |
| `Docs/framework-ai-enhancement-phase.md`    | **Updated** — Added entry for this change                                                                                                                                          |
| `VERSION`                                   | **Updated** — Bumped to 0.6.1                                                                                                                                                      |
| `.github/project-memory.md`                 | **Updated** — Added Serverpod section                                                                                                                                              |

## Key Rules of the Pattern

- Serverpod is an **opt-in** backend sub-option — only enabled when explicitly selected.
- **Single language:** server (models, endpoints, database) and app (generated
  client) are all Dart.
- Workspace layout: `serverpod create <name>` → `<name>_server/`,
  `<name>_client/`, `<name>_flutter/` under one Dart pub workspace.
- Backend structure is a user choice: **idiomatic Serverpod**, **Clean
  Architecture**, or **Vertical Slice Architecture** inside the server.
- Models are `.spy.yaml` files; `serverpod generate` emits `lib/src/generated/`
  code and the client; `serverpod create-migration` handles schema changes.
- Endpoints extend `Endpoint`, first parameter `Session`, typed `Future`/`Stream`
  returns, stateless.
- The generated client is consumed **only** in the Flutter data layer, behind
  repositories; `domain/` stays pure Dart.
- Server `generated/` code is never hand-edited.

## Skill Usage

- **Scaffolding a full-stack Flutter app** → `flutter-scaffold` (Serverpod path)
  then `flutter-serverpod` for the backend.
- **Adding a feature** → `flutter-feature` + `flutter-serverpod` for the server
  endpoint and client integration.
- **Specifying endpoints/models** → `flutter-spec` + `flutter-serverpod` units.
- **Testing the backend** → `flutter-testing` (Serverpod section) with
  `serverpod test`.
