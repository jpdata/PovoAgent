---
name: flutter-feature
description: 'Create a new feature module in a Flutter project (Clean Architecture or Vertical Slice Architecture). Use when adding a feature, creating a new screen with its use case, repository, model, and ViewModel/Cubit (CA) or full vertical slice per feature (VSA), or implementing a user story end-to-end.'
argument-hint: 'Feature name and description'
---

# Flutter Feature Implementation

## When to Use
- Adding a new feature (screen + logic + data) to an existing Flutter project.
- Implementing a user story that spans all layers (CA) or owns its full vertical stack (VSA).
- Creating a new module following Clean Architecture or Vertical Slice Architecture.

## Procedure

1. **Define the feature scope**
   - Identify the entity, use case(s), data source, and UI screens.
   - **Architecture style:** Confirm whether the project uses Clean Architecture or Vertical Slice Architecture. If not decided, refer to the kickoff diagnostic questions.

2. **Create Domain layer files**
   ```
   lib/domain/entities/<feature>_entity.dart        ← Business entity
   lib/domain/repositories/<feature>_repository.dart ← Abstract repository
   lib/domain/usecases/get_<feature>.dart            ← Use case
   ```
   - Entity: plain Dart class, no Flutter imports.
   - Repository: abstract class defining the contract.
   - Use case: single-responsibility, calls repository interface.

3. **Create Data layer files**
   ```
   lib/data/models/<feature>_model.dart              ← DTO with fromJson/toJson
   lib/data/datasources/<feature>_remote_source.dart ← API calls
   lib/data/repositories/<feature>_repository_impl.dart ← Implements domain interface
   ```
   - Model extends or maps to Entity.
   - Repository implementation uses data sources, never UI.

4. **Create Presentation layer files**
   ```
   lib/presentation/viewmodels/<feature>_viewmodel.dart ← State management
   lib/presentation/pages/<feature>_page.dart            ← Screen widget
   lib/presentation/widgets/<feature>_card.dart           ← Reusable components
   ```
   - ViewModel/Cubit depends on use case only, not on data sources.
   - Page observes ViewModel state.

5. **Register in DI container**
   - Register data source, repository implementation, use case, and ViewModel in `injection.dart`.

6. **Add route** in the router configuration.

7. **Create tests**
   ```
   test/domain/usecases/get_<feature>_test.dart
   test/data/repositories/<feature>_repository_impl_test.dart
   test/presentation/viewmodels/<feature>_viewmodel_test.dart
   test/presentation/pages/<feature>_page_test.dart
   ```

### Vertical Slice Architecture Path

When the project uses VSA, create a feature folder that owns its full vertical stack:

1. **Create the VSA feature folder**
   ```
   lib/features/<feature>/
   ├── models/
   │   └── <feature>_entity.dart              ← Business entity
   ├── data/
   │   ├── <feature>_api.dart                 ← HTTP client calls
   │   └── <feature>_repository.dart          ← Repository implementation
   ├── viewmodels/
   │   └── <feature>_viewmodel.dart           ← State management (Cubit/Bloc)
   ├── pages/
   │   └── <feature>_page.dart                ← Screen widget
   ├── widgets/
   │   └── <feature>_card.dart                ← Feature-scoped components
   └── <feature>.dart                          ← Public API barrel export (index)
   ```

2. **Create the entity and data access**
   - Entity: plain Dart class at `models/<feature>_entity.dart`.
   - API: HTTP calls scoped to this feature only at `data/<feature>_api.dart`.
   - Repository: implements data access; lives inside the feature, not in a shared `lib/data/` folder.

3. **Create the ViewModel (Cubit/Bloc)**
   - Depends on the feature's repository directly.
   - Owns the state for this slice: loading, data, error.
   - No separate use-case class — business logic lives in the ViewModel or a dedicated `services/` subfolder.

4. **Create the page and widgets**
   - Page observes ViewModel state via `BlocBuilder` or `context.watch`.
   - Widgets are feature-scoped and composed by the page.
   - No cross-feature imports between pages.

5. **Register in DI**
   - Register repository and ViewModel in the feature's own injection module.
   - Example: `lib/features/<feature>/<feature>_di.dart`

6. **Add route** via lazy-loaded route or `onGenerateRoute`.

7. **Create tests** (co-located with the slice)
   ```
   test/features/<feature>/viewmodels/<feature>_viewmodel_test.dart
   test/features/<feature>/data/<feature>_repository_test.dart
   test/features/<feature>/pages/<feature>_page_test.dart
   ```

**VSA Key Rules:**
- Each feature folder is self-contained.
- `lib/shared/` provides reusable cross-slice widgets, themes, and core utilities.
- `lib/contracts/` defines shared event types and interfaces for cross-slice communication.
- No feature imports from another feature.

## Decoupling Checklist

**Clean Architecture:**
- [ ] Domain files have zero Flutter imports.
- [ ] Data files don't import from presentation.
- [ ] Presentation files don't import from data directly.
- [ ] ViewModel can be tested without Flutter framework.
- [ ] Swapping the page widget doesn't break the ViewModel tests.

**Vertical Slice Architecture:**
- [ ] Each feature folder is self-contained — no imports from other feature folders.
- [ ] `lib/shared/` contains only reusable cross-slice code, no feature-specific logic.
- [ ] `lib/contracts/` defines shared event types and interfaces for cross-slice communication.
- [ ] ViewModel can be tested with a mocked repository (no Flutter framework).
- [ ] Swapping the page widget doesn't affect other slices.

## Reference
- Refer to `conventions.md` in the project root for Flutter conventions.
