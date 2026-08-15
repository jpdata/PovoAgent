---
name: flutter-scaffold
description: 'Scaffold a new Flutter project with Clean Architecture or Vertical Slice Architecture structure. Use when creating a new Flutter app, initializing project structure, setting up layers or slices, configuring DI, or bootstrapping a Flutter project from scratch.'
argument-hint: 'Project name and main features'
---

# Flutter Project Scaffolding

## When to Use
- Creating a new Flutter application from scratch.
- Setting up the initial folder structure following Clean Architecture or Vertical Slice Architecture (as chosen in the Design phase).
- Configuring dependency injection, routing, and state management base.

## Pre-Scaffold Questions

Ask the user **before starting** if any of these are undefined:
- Architecture style: Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.
- State management: **Riverpod 3.x + Codegen by default** (no question needed). Bloc/Cubit is a **disabled-by-default sub-option** — only ask about it if the user explicitly mentions BLoC, and only enable it with explicit user approval in the Design phase.

## Procedure

### Clean Architecture Path

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
   - State management + DI (default): `flutter_riverpod`, `riverpod`, `riverpod_annotation`
   - Code generation (default): `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`
   - BLoC/Cubit (`flutter_bloc`) only if explicitly enabled by the user in the Design phase
   - DI (non-Riverpod only): `get_it` + `injectable`
   - Navigation: `go_router`
   - HTTP: `http` or `dio`

4. **Create base files**
   - `lib/core/constants/api_constants.dart` — API URLs and keys
   - `lib/core/theme/app_theme.dart` — App-wide theme definition
   - `lib/main.dart` — App entry point wrapping the app in `ProviderScope` (Riverpod DI) and setting up the router
   - If the project is explicitly non-Riverpod: `lib/core/utils/injection.dart` — DI container setup (`get_it` + `injectable`)

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

### Vertical Slice Architecture Path

1. **Create the Flutter project**
   ```bash
   flutter create --org com.example <project_name>
   ```

2. **Set up VSA folder structure**
   ```
   lib/
   ├── features/
   │   └── <feature_name>/
   │       ├── presentation/
   │       │   ├── pages/
   │       │   ├── widgets/
   │       │   └── viewmodel/
   │       ├── domain/
   │       │   ├── entities/
   │       │   └── usecases/
   │       ├── data/
   │       │   ├── models/
   │       │   └── datasources/
   │       └── <feature>_module.dart
   ├── shared/
   │   ├── kernel/
   │   ├── ui/
   │   ├── routing/
   │   └── di/
   ├── contracts/
   │   └── events/
   └── main.dart
   ```

3. **Add core dependencies** (same as CA path)

4. **Create base files**
   - `lib/shared/routing/app_router.dart` — App-level router
   - `lib/main.dart` — Composes all slice modules inside `ProviderScope` (Riverpod DI)
   - If the project is explicitly non-Riverpod: `lib/shared/di/injection.dart` — Shared DI setup (`get_it` + `injectable`)

5. **Create test mirrors**
   ```
   test/
   ├── features/
   │   └── <feature_name>/
   └── shared/
   ```
   - One test folder per feature slice.

6. **Verify**
   - Run `flutter pub get` — no errors.
   - Run `flutter analyze` — no issues.
   - Confirm no slice imports another slice directly.

## Decoupling Validation

### Clean Architecture
- `domain/` must contain only pure Dart (no `package:flutter` imports).
- `data/` implements interfaces from `domain/`. No imports from `presentation/`.
- `presentation/` accesses `domain/` only through use cases or ViewModels.

### Vertical Slice Architecture
- No slice imports another slice's widgets, viewmodels, or data sources.
- Cross-slice communication uses `contracts/events/` only.
- `shared/` contains only infrastructure (routing, theming, DI setup).
- Each slice can be compiled independently.

## Reference
- Refer to `conventions.md` in the project root for Flutter conventions.
