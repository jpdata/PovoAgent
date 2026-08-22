# Flutter Conventions

## Project Structure (Clean Architecture)

```
lib/
├── core/                  ← Shared utilities, constants, themes
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/                  ← Data layer (API, local storage)
│   ├── datasources/       ← Remote and local data sources
│   ├── models/            ← Data transfer objects (DTOs)
│   └── repositories/      ← Repository implementations
├── domain/                ← Business logic layer (pure Dart, no Flutter imports)
│   ├── entities/          ← Business entities
│   ├── repositories/      ← Repository interfaces (abstract)
│   └── usecases/          ← Use cases / interactors
├── presentation/          ← UI layer (Flutter widgets)
│   ├── pages/             ← Screen-level widgets
│   ├── widgets/           ← Reusable UI components
│   └── viewmodels/        ← State management (ViewModel / Cubit / Notifier)
└── main.dart
```

## Project Structure (Vertical Slice Architecture)

```
lib/
├── features/                      ← Each feature is a self-contained vertical slice
│   └── <feature_name>/
│       ├── presentation/          ← Feature-scoped UI
│       │   ├── pages/             ← Screen-level widgets for this feature
│       │   ├── widgets/           ← Feature-scoped reusable widgets
│       │   └── viewmodel/         ← Feature-scoped state (Cubit / Notifier / Riverpod provider)
│       ├── domain/                ← Feature-scoped business logic (pure Dart)
│       │   ├── entities/          ← Feature entities
│       │   └── usecases/          ← Feature use cases
│       ├── data/                  ← Feature-scoped data access
│       │   ├── models/            ← Feature DTOs
│       │   └── datasources/       ← Feature API / local sources
│       └── <feature>_module.dart  ← DI registration for this slice
├── shared/                        ← Cross-cutting shared code
│   ├── kernel/                    ← Shared types, base classes, common contracts
│   ├── ui/                        ← Shared design system widgets
│   ├── routing/                   ← App-level router
│   └── di/                        ← Shared DI setup
├── contracts/                     ← Cross-slice communication contracts
│   └── events/                    ← Integration events between slices
└── main.dart                      ← App entry point
test/
├── <feature_name>/
│   ├── presentation/
│   ├── domain/
│   └── data/
└── shared/
```

### VSA Key Rules (Flutter)

- **Each slice is self-contained.** A feature's UI, logic, and data access live together under `features/<feature_name>/`.
- **Slices do not reference each other directly.** Cross-slice communication through `contracts/events/` or shared kernel interfaces.
- **shared/kernel/** is minimal. Only types genuinely used by multiple slices belong here. When in doubt, keep it in the slice.
- **DI per slice.** Each slice exports its own registration module (`<feature>_module.dart`). `main.dart` composes all slice modules.
- **Slices are independently testable.** Each slice's tests run without loading other slices.

## Decoupling Rules for Flutter

### Clean Architecture
- **domain/** must contain only pure Dart. No Flutter imports (`import 'package:flutter/...'`) allowed.
- **data/** implements interfaces defined in **domain/**. Never import from **presentation/**.
- **presentation/** depends on **domain/** only through use cases or ViewModels. Never imports from **data/** directly.
- **Dependency injection wires layers together via Riverpod's `ProviderScope` and overrides.** Repositories and use cases are plain `Provider`s; use cases receive dependencies through the constructor and are wired with `ref.watch`. `get_it` + `injectable` are only used in non-Riverpod projects.

### Vertical Slice Architecture
- **Each slice is self-contained.** A slice must not import another slice's widgets, viewmodels, or data sources directly.
- **Cross-slice communication through contracts/events/.** Use integration events or shared kernel interfaces. Never call another slice's use case directly.
- **shared/kernel/ is for infrastructure, not business logic.** Shared UI primitives, routing, and DI setup belong here. Business rules stay in slices.
- **DI composes slices.** Each slice exports a registration module; `main.dart` wires all modules together via `ProviderScope`.

## SOLID in Flutter

These principles apply to both architectures:

- **S:** Clean Architecture — each use case class does one thing. VSA — each slice handles one feature.
- **O:** Clean Architecture — new features create new use cases and repositories. VSA — new features create new slices; existing slices are not modified.
- **L:** Clean Architecture — every repository implementation can replace another. VSA — slices implementing the same cross-slice contract are interchangeable.
- **I:** Clean Architecture — split `UserRepository` from `AuthRepository`. VSA — cross-slice interfaces are narrow.
- **D:** Clean Architecture — `domain/` defines interfaces, `data/` implements them. VSA — slices depend on `contracts/` abstractions, not other slices' concretions.

## Design Patterns in Flutter

### Clean Architecture Patterns
- **Repository:** All data access through abstract repositories in `domain/repositories/`, implemented in `data/repositories/`.
- **Use Case / Interactor:** One class per business operation in `domain/usecases/`. Receives repositories via constructor.
- **Dependency Injection:** Riverpod's `ProviderScope` handles DI natively. Use `overrideWith` in tests. For non-Riverpod projects, `get_it` + `injectable`.
- **Observer:** State management (Riverpod providers / Notifiers) acts as the observer pattern for UI reactivity.
- **ViewModel:** Riverpod ViewModels follow the `flutter-riverpod-viewmodel` skill (AsyncNotifier / Notifier / state classes with `copyWith`). Bloc/Cubit is a disabled-by-default sub-option.
- **Factory:** Use `freezed` or factory constructors for entities/DTOs with complex creation logic.
- **Adapter:** Wrap external SDKs (Firebase, platform channels) behind interfaces in `data/datasources/`.

### Vertical Slice Architecture Patterns
- **Handler per operation:** Each user action in a slice has a dedicated use case or handler class.
- **Feature-scoped state:** Each slice manages its own state (Riverpod provider or Notifier scoped to the feature). No global state for feature-specific data.
- **Feature-scoped data access:** Each slice defines its own data sources and models. Shared data sources only for truly cross-cutting data (e.g., auth token storage).
- **Integration Events:** Cross-slice communication via a lightweight event bus or stream-based events.
- **Slice registration modules:** Each slice exports a DI module; `main.dart` composes all modules.

## State Management

- Use **Riverpod 3.x + Codegen** by default for state management and dependency injection. Follow the `flutter-riverpod-viewmodel` skill for all ViewModels and providers.
- `flutter_bloc` (Bloc/Cubit) is a **disabled-by-default sub-option**: it is not part of the default pattern and must be explicitly enabled by the user in the Design phase.
- Riverpod is the single state-management + DI mechanism. No `get_it`, no manual service locators. DI is wired through `ProviderScope` (and `overrides` in tests).
- ViewModels/Notifiers must not contain widget references. No `BuildContext`, no `ScaffoldMessenger` inside a Notifier.
- Widgets only observe and trigger: `ref.watch` to read state, `ref.read(provider.notifier).method()` to trigger actions. Widgets never mutate state directly.
- All data access goes through use-case providers (`ref.read(xUseCaseProvider).call(...)`), never through repositories directly from widgets.
- Asynchronous state is modeled with `AsyncValue` (loading/data/error) and switched on with `.when()` / pattern matching.
- **Never** use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider` in new code — they are legacy in Riverpod 3.x.
- A project must never mix Riverpod and Bloc/Cubit for the same feature.

## Backend (Dart single-language)

When the user selects Flutter and needs a backend, kickoff/design offers four
choices: **Serverpod (Dart full-stack with codegen/ORM)**, **Dart Frog
(lightweight Dart REST API)**, **external REST/GraphQL API**, or **no backend**.
Both Dart backends are **opt-in sub-options** — only enabled when explicitly
selected. A project picks one backend; Serverpod and Dart Frog are mutually
exclusive alternatives.

### Serverpod

- **Style:** full-stack framework with codegen — models (`.spy.yaml`), typed
  endpoints, ORM, and a generated Dart client consumed by the Flutter app.
- **Workspace layout:** `serverpod create <name>` produces a Dart pub workspace
  with `<name>_server/`, `<name>_client/`, and `<name>_flutter/`.
- **Backend structure** (user chooses in the Design phase, per the
  `flutter-serverpod` skill): idiomatic Serverpod (`endpoints/` + `models/`),
  Clean Architecture (layer-first), or Vertical Slice Architecture
  (feature-first) inside the server.
- **Client integration:** the generated client is consumed only in the Flutter
  `data/` layer behind repositories. `domain/` stays pure Dart. Never call
  `client.*` from widgets or ViewModels.
- **Codegen:** `serverpod generate` after model/endpoint changes;
  `serverpod create-migration` after schema-affecting model changes.
- Follow the `flutter-serverpod` skill for all Serverpod backend work.

### Dart Frog

- **Style:** lightweight REST framework built on `shelf` — file-system routing,
  middleware, and DI via `provider`; no codegen and no ORM. The Flutter app
  calls it over HTTP (`http`/`dio`).
- **Workspace layout:** sibling projects `<name>_app/` (`flutter create`) +
  `<name>_api/` (`dart_frog create`).
- **Backend structure** (user chooses in the Design phase, per the
  `flutter-dart-frog` skill): idiomatic Dart Frog (feature-first `routes/`),
  Clean Architecture (`lib/domain/` + `lib/data/` + `routes/` as presentation),
  or Vertical Slice Architecture (feature folders grouping route + logic +
  data).
- **Client integration:** the Flutter `data/` layer calls the REST endpoints
  via `http`/`dio` behind repositories. `domain/` stays pure Dart. Never call
  HTTP directly from widgets or ViewModels.
- **Run:** `dart_frog dev` (hot reload, port 8080); `dart_frog build` for
  production (includes a Dockerfile).
- Follow the `flutter-dart-frog` skill for all Dart Frog backend work.

### Backend Decoupling Rules

- Serverpod: server `generated/` code is never hand-edited.
- When a backend uses Clean Architecture, the backend `domain/` must not import
  the framework (no `serverpod`/generated protocol, no `dart_frog`/`shelf`).
- When a backend uses VSA, backend slices are self-contained; cross-slice
  communication goes through shared kernel types or events.
- The Flutter app talks to the backend only through the generated client
  (Serverpod) or HTTP clients behind repositories (Dart Frog) — never raw calls
  from widgets or ViewModels.

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for global constants
- Test files: `<name>_test.dart` in `test/` mirroring `lib/` structure

## Testing

- Unit tests for **domain/** use cases (no mocking needed, pure Dart).
- Unit tests for **data/** repositories (mock data sources).
- Widget tests for **presentation/** (mock ViewModels/Notifiers via `ProviderScope.overrides`).
- Integration tests in `integration_test/` folder.

## Common Packages

| Purpose             | Package                                                     | Use/Priority                                                          |
| ------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------- |
| DI                  | `riverpod` (built-in)                                       | Default                                                               |
| State management    | `flutter_riverpod`, `riverpod`                              | Default (Riverpod 3.x)                                                |
| Codegen (Riverpod)  | `riverpod_annotation`, `riverpod_generator`, `build_runner` | Default                                                               |
| DI (alternative)    | `get_it`, `injectable`                                      | Only for non-Riverpod projects                                        |
| State (alternative) | `flutter_bloc`                                              | Disabled-by-default sub-option — only if explicitly enabled in Design |
| HTTP client         | `dio`, `http`                                               | `http` > `dio`                                                        |
| Navigation          | `go_router`, `auto_route`                                   | `go_router` > `auto_route`                                            |
| Local storage       | `hive`, `shared_preferences`                                | `shared_preferences` > `hive`                                         |
| Testing mocks       | `mockito`, `mocktail`                                       | Ask                                                                   |
| Code generation     | `freezed`, `json_serializable`, `riverpod_generator`        | Both + Riverpod                                                       |
| Backend (Serverpod) | `serverpod`                                                 | Opt-in full-stack Dart backend (server)                               |
| Backend client      | `serverpod_flutter` (+ generated `<project>_client`)        | Opt-in — generated client consumed in the data layer                  |
| Serverpod CLI       | `serverpod_cli`                                             | Opt-in — `dart pub global activate serverpod_cli`                     |
| Backend testing     | `serverpod_test`                                            | Opt-in — `withServerpod` server tests                                 |
| Backend (Dart Frog) | `dart_frog`                                                 | Opt-in lightweight Dart REST backend                                  |
| Dart Frog CLI       | `dart_frog_cli`                                             | Opt-in — `dart pub global activate dart_frog_cli`                     |

## Package Version Selection

- Use the **latest stable version** of any package when adding it to `pubspec.yaml`.
- If the latest stable version causes a dependency conflict (version mismatch or transitive constraint violation), fall back to the **closest compatible version** — the highest patch/minor release that satisfies all existing constraints.
- Re-evaluate pinned packages on each major project update to move back toward latest stable when conflict no longer exists.
