---
name: flutter-scaffold
description: 'Scaffold a new Flutter project with Clean Architecture structure. Use when creating a new Flutter app, initializing project structure, setting up layers (domain, data, presentation), configuring DI, or bootstrapping a Flutter project from scratch.'
argument-hint: 'Project name and main features'
---

# Flutter Project Scaffolding

## When to Use
- Creating a new Flutter application from scratch.
- Setting up the initial folder structure following Clean Architecture.
- Configuring dependency injection, routing, and state management base.

## Procedure

1. **Create the Flutter project**
   ```bash
   flutter create --org com.example <project_name>
   ```

2. **Set up Clean Architecture folder structure**
   ```
   lib/
   ├── core/
   │   ├── constants/
   │   ├── theme/
   │   └── utils/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── presentation/
   │   ├── pages/
   │   ├── widgets/
   │   └── viewmodels/
   └── main.dart
   ```

3. **Add core dependencies to `pubspec.yaml`**
   - State management (ask user: `flutter_bloc`, `riverpod`, or `provider`)
   - DI: `get_it` + `injectable`
   - Navigation: `go_router`
   - HTTP: `http` or `dio`
   - Code generation: `freezed`, `json_serializable`, `build_runner`

4. **Create base files**
   - `lib/core/constants/api_constants.dart` — API URLs and keys
   - `lib/core/theme/app_theme.dart` — App-wide theme definition
   - `lib/core/utils/injection.dart` — DI container setup
   - `lib/main.dart` — App entry point wiring DI and router

5. **Create test mirrors**
   ```
   test/
   ├── data/
   ├── domain/
   └── presentation/
   integration_test/
   ```

6. **Verify**
   - Run `flutter pub get` — no errors.
   - Run `flutter analyze` — no issues.
   - Confirm `domain/` has zero Flutter imports.

## Decoupling Validation
- `domain/` must contain only pure Dart (no `package:flutter` imports).
- `data/` implements interfaces from `domain/`. No imports from `presentation/`.
- `presentation/` accesses `domain/` only through use cases or ViewModels.

## Reference
- [Flutter Conventions](../conventions.md)
