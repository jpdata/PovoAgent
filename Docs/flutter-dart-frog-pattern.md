# Flutter Dart Frog Pattern

## What Changed

Integrated **Dart Frog** as a second opt-in backend sub-option of the Flutter
pattern (alongside Serverpod), enabling a single-language (Dart) environment
with a lightweight REST backend. The integration follows the same layering used
for the Serverpod and Riverpod ViewModel patterns:

1. **New pattern skill** — `flutter/skills/flutter-dart-frog/SKILL.md` codifies
   the backend workflow: prerequisites, CLI install, sibling-project layout
   (`<name>_app/` + `<name>_api/`), local run commands, three backend structure
   options (idiomatic Dart Frog, Clean Architecture, Vertical Slice
   Architecture), routes (`onRequest`, dynamic `[id].dart`), requests/responses,
   middleware + DI (`provider<T>` / `context.read<T>()`), client integration
   into the Flutter data layer, and testing with `package:test` + `mocktail`.
2. **Conventions alignment** — `flutter/conventions.md` generalized its backend
   section to **"Backend (Dart single-language)"**, presenting Serverpod and
   Dart Frog as mutually exclusive alternatives, and added two Dart Frog rows to
   the Common Packages table.
3. **Existing skill alignment** — `flutter-scaffold`, `flutter-feature`,
   `flutter-spec`, and `flutter-testing` route through the Dart Frog pattern
   when that backend option is enabled.
4. **Agent alignment** — the three Flutter agents (architect, developer,
   reviewer) now cover Dart Frog backend design, route-handler/middleware
   implementation, and review checks respectively.
5. **Kickoff alignment** — `skills/kickoff/SKILL.md` backend question now lists
   Dart Frog alongside Serverpod.

## Why It Changed

Serverpod gives Flutter a full-stack Dart backend with codegen and an ORM, but
some projects only need a lightweight REST API. Dart Frog fills that gap: a
minimal, file-system-routed backend on `shelf` with hot reload, middleware, and
DI — still 100% Dart. Offering both lets the user pick the right weight of
backend while keeping a single language across app and server.

## Files Affected

| File                                         | Change                                                                                                                                                  |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flutter/skills/flutter-dart-frog/SKILL.md`  | **New** — Full Dart Frog backend skill (prereqs, CLI, sibling layout, run commands, 3 backend structures, routes, middleware/DI, client integration, testing, checklist) |
| `flutter/conventions.md`                     | **Updated** — Backend section generalized to "Backend (Dart single-language)" (Serverpod + Dart Frog) + 2 Dart Frog packages in the Common Packages table |
| `flutter/skills/flutter-scaffold/SKILL.md`   | **Updated** — Dart Frog scaffold path + backend pre-scaffold question covers Dart Frog                                                                    |
| `flutter/skills/flutter-feature/SKILL.md`    | **Updated** — Dart Frog route + middleware + client-integration steps                                                                                    |
| `flutter/skills/flutter-spec/SKILL.md`       | **Updated** — Dart Frog route-handler spec units + test mapping                                                                                          |
| `flutter/skills/flutter-testing/SKILL.md`    | **Updated** — Dart Frog route/middleware tests (`package:test` + `mocktail`)                                                                             |
| `flutter/agents/flutter-architect.agent.md`  | **Updated** — Backend design covers Dart Frog (routes, middleware, DI, structure choice)                                                                 |
| `flutter/agents/flutter-developer.agent.md`  | **Updated** — Route handler/middleware implementation, `dart_frog dev`/`build`, client integration                                                        |
| `flutter/agents/flutter-reviewer.agent.md`   | **Updated** — Dart Frog review checks (handler signatures, stateless routes, DI via provider, no direct HTTP in widgets)                                  |
| `skills/kickoff/SKILL.md`                    | **Updated** — Backend question lists Dart Frog alongside Serverpod                                                                                       |
| `Docs/flutter-serverpod-pattern.md`          | **Updated** — Conventions section references the unified "Backend (Dart single-language)" section                                                         |
| `Docs/framework-ai-enhancement-phase.md`     | **Updated** — Added entry for this change                                                                                                                |
| `VERSION`                                    | **Updated** — Bumped to 0.7.0                                                                                                                            |
| `.github/project-memory.md`                  | **Updated** — Added Dart Frog section                                                                                                                    |

## Key Rules of the Pattern

- Dart Frog is an **opt-in** backend sub-option — only enabled when explicitly selected.
- **Single language:** routes, middleware, and DI are all Dart; the Flutter app
  consumes the API over HTTP.
- Sibling layout: `flutter create <name>_app` + `dart_frog create <name>_api`.
- Backend structure is a user choice: **idiomatic Dart Frog**, **Clean
  Architecture**, or **Vertical Slice Architecture**.
- Routes are `onRequest(RequestContext context, ...)` functions in `routes/`;
  `index.dart` → `/`; dynamic routes via `[id].dart`.
- DI via `provider<T>` + `context.read<T>()`; provider order resolves
  bottom-to-top.
- The Flutter app calls the API only in the `data/` layer behind repositories
  (`http`/`dio`); `domain/` stays pure Dart.
- `dart_frog build` must pass (no route conflicts/rogue routes).

## Skill Usage

- **Scaffolding a Flutter app with a Dart Frog API** → `flutter-scaffold` (Dart
  Frog path) then `flutter-dart-frog` for the backend.
- **Adding a feature** → `flutter-feature` + `flutter-dart-frog` for the route
  handler, middleware, and client integration.
- **Specifying routes** → `flutter-spec` + `flutter-dart-frog` units.
- **Testing the backend** → `flutter-testing` (Dart Frog section) with
  `package:test` + `mocktail`.
