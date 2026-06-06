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

## Decoupling Rules for Flutter

- **domain/** must contain only pure Dart. No Flutter imports (`import 'package:flutter/...'`) allowed.
- **data/** implements interfaces defined in **domain/**. Never import from **presentation/**.
- **presentation/** depends on **domain/** only through use cases or ViewModels. Never imports from **data/** directly.
- Dependency injection wires layers together (e.g., `get_it`, `injectable`).

## SOLID in Flutter

- **S:** Each use case class does one thing. Each widget has a single purpose. ViewModels don't fetch data directly.
- **O:** Add new features by creating new use cases and repositories — don't modify existing ones.
- **L:** Every repository implementation can replace another that implements the same interface. Mock implementations work in tests.
- **I:** Repository interfaces expose only what consumers need. Split `UserRepository` from `AuthRepository` if they serve different use cases.
- **D:** `domain/` defines interfaces, `data/` implements them. `presentation/` depends on `domain/` abstractions, never on `data/` concretions.

## Design Patterns in Flutter

- **Repository:** All data access through abstract repositories in `domain/repositories/`, implemented in `data/repositories/`.
- **Use Case / Interactor:** One class per business operation in `domain/usecases/`. Receives repositories via constructor.
- **Dependency Injection:** `get_it` + `injectable` (or manual registration). All wiring in a single setup file.
- **Observer:** State management (Bloc/Cubit/Riverpod) acts as the observer pattern for UI reactivity.
- **Factory:** Use `freezed` or factory constructors for entities/DTOs with complex creation logic.
- **Adapter:** Wrap external SDKs (Firebase, platform channels) behind interfaces in `data/datasources/`.

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
