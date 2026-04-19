---
name: flutter-feature
description: 'Create a new feature module in a Flutter Clean Architecture project. Use when adding a feature, creating a new screen with its use case, repository, model, and ViewModel/Cubit, or implementing a user story end-to-end across all layers.'
argument-hint: 'Feature name and description'
---

# Flutter Feature Implementation

## When to Use
- Adding a new feature (screen + logic + data) to an existing Flutter project.
- Implementing a user story that spans all layers.
- Creating a new module following Clean Architecture.

## Procedure

1. **Define the feature scope**
   - Identify the entity, use case(s), data source, and UI screens.

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

## Decoupling Checklist
- [ ] Domain files have zero Flutter imports.
- [ ] Data files don't import from presentation.
- [ ] Presentation files don't import from data directly.
- [ ] ViewModel can be tested without Flutter framework.
- [ ] Swapping the page widget doesn't break the ViewModel tests.

## Reference
- [Flutter Conventions](../conventions.md)
