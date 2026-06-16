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
- Dependency injection wires layers together (e.g., `get_it`, `injectable`).

### Vertical Slice Architecture
- **Each slice is self-contained.** A slice must not import another slice's widgets, viewmodels, or data sources directly.
- **Cross-slice communication through contracts/events/.** Use integration events or shared kernel interfaces. Never call another slice's use case directly.
- **shared/kernel/ is for infrastructure, not business logic.** Shared UI primitives, routing, and DI setup belong here. Business rules stay in slices.
- **DI composes slices.** Each slice exports a registration module; `main.dart` wires all modules together.

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
- **Dependency Injection:** `get_it` + `injectable` (or manual registration). All wiring in a single setup file.
- **Observer:** State management (Bloc/Cubit/Riverpod) acts as the observer pattern for UI reactivity.
- **Factory:** Use `freezed` or factory constructors for entities/DTOs with complex creation logic.
- **Adapter:** Wrap external SDKs (Firebase, platform channels) behind interfaces in `data/datasources/`.

### Vertical Slice Architecture Patterns
- **Handler per operation:** Each user action in a slice has a dedicated use case or handler class.
- **Feature-scoped state:** Each slice manages its own state (Cubit / Notifier / Riverpod provider scoped to the feature). No global state for feature-specific data.
- **Feature-scoped data access:** Each slice defines its own data sources and models. Shared data sources only for truly cross-cutting data (e.g., auth token storage).
- **Integration Events:** Cross-slice communication via a lightweight event bus or stream-based events.
- **Slice registration modules:** Each slice exports a DI module; `main.dart` composes all modules.

## State Management

- Use Riverpod, Bloc/Cubit, or Provider — chosen per project in the Design phase.
- ViewModels/Cubits must not contain widget references.
- Widgets observe state, they do not manage it.

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for global constants
- Test files: `<name>_test.dart` in `test/` mirroring `lib/` structure

## Testing

- Unit tests for **domain/** use cases (no mocking needed, pure Dart).
- Unit tests for **data/** repositories (mock data sources).
- Widget tests for **presentation/** (mock ViewModels/Cubits).
- Integration tests in `integration_test/` folder.

## Common Packages

| Purpose              | Package                         | Use/Priority                  |
|----------------------|---------------------------------|-------------------------------|
| DI                   | `get_it`, `injectable`          | Ask                           |
| State management     | `flutter_bloc`, `riverpod`      | Ask                           |
| HTTP client          | `dio`, `http`                   | `http` > `dio`                |
| Navigation           | `go_router`, `auto_route`       | `go_router` > `auto_route`    |
| Local storage        | `hive`, `shared_preferences`    | `shared_preferences` > `hive` |
| Testing mocks        | `mockito`, `mocktail`           | Ask                           |
| Code generation      | `freezed`, `json_serializable`  | Both                          |

## Package Version Selection

- Use the **latest stable version** of any package when adding it to `pubspec.yaml`.
- If the latest stable version causes a dependency conflict (version mismatch or transitive constraint violation), fall back to the **closest compatible version** — the highest patch/minor release that satisfies all existing constraints.
- Re-evaluate pinned packages on each major project update to move back toward latest stable when conflict no longer exists.
