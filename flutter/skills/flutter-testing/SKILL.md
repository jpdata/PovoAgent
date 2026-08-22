---
name: flutter-testing
description: 'Generate and run tests for a Flutter project (Clean Architecture or Vertical Slice Architecture). Use when writing unit tests, widget tests, integration tests, validating decoupling between layers/slices, or checking test coverage.'
argument-hint: 'Feature or layer to test'
---

# Flutter Testing

## When to Use
- Writing or generating tests for a feature, layer (CA), or slice (VSA).
- Validating that architectural decoupling is maintained.
- Checking test coverage.

## Pre-Testing Questions
- **Architecture style:** Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.

## Procedure

### Unit Tests (Domain)
1. Test each use case in isolation (pure Dart, no mocking needed).
2. File: `test/domain/usecases/<usecase>_test.dart`
3. Verify business rules and edge cases.

### Unit Tests (Data)
1. Mock data sources using `mocktail` or `mockito`.
2. Test repository implementations.
3. File: `test/data/repositories/<repo>_impl_test.dart`
4. Verify correct mapping between models and entities.

### Widget Tests (Presentation)
1. Mock ViewModel/Cubit — never use real repositories.
2. Test widgets render correctly for each state (loading, data, error).
3. File: `test/presentation/pages/<page>_test.dart`
4. Use `pumpWidget` with mocked dependencies.

### Riverpod Provider Tests (default state management)
1. Unit-test ViewModels/Notifiers in isolation with `ProviderContainer.test()`.
2. Override repository/use-case providers with `ProviderScope.overrides` (widget tests) or provider overrides in the container (unit tests).
3. Assert `AsyncValue` states: `loading`, `data`, `error`.
4. Trigger actions via `container.read(provider.notifier).method()` and assert state transitions.
5. Verify subscriptions are cancelled on dispose (`ref.onDispose`).
6. File: `test/presentation/viewmodels/<viewmodel>_test.dart` (CA) or `test/features/<feature>/viewmodels/<viewmodel>_test.dart` (VSA).

```dart
// test/presentation/viewmodels/users_viewmodel_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads users and exposes AsyncValue.data', () async {
    final container = ProviderContainer(
      overrides: [getUsersProvider.overrideWithValue(FakeGetUsers())],
    );
    addTearDown(container.dispose);

    await container.read(usersViewModelProvider.future);
    expect(container.read(usersViewModelProvider), isA<AsyncValue<List<User>>>());
  });
}
```

### Integration Tests
1. Place in `integration_test/` folder.
2. Test full user flows across screens.
3. Use `IntegrationTestWidgetsFlutterBinding`.

### Serverpod Tests (backend)

When the project uses **Serverpod** (see the `flutter-serverpod` skill), test
the backend in `<project>_server/test/`:

1. Run server tests with `serverpod test` (spins up a test database + server).
2. Use the `withServerpod` helper from `package:serverpod_test/serverpod_test.dart`.
3. Test endpoints (call `endpoints.<feature>.<method>`), models (serialization
   round-trip), and database access (`<Model>.db` operations).
4. File: `<project>_server/test/<feature>_endpoint_test.dart`.
5. Flutter-side repository tests mock the generated client — never hit a real
   server in widget/unit tests.

```dart
// <project>_server/test/recipe_endpoint_test.dart
import 'package:serverpod_test/serverpod_test.dart';

void main() {
  withServerpod('given recipe when create then persists',
      (session, endpoints) async {
    final created = await endpoints.recipe.createRecipe(session, /* ... */);
    expect(created.id, isNotNull);
  });
}
```

## Decoupling Validation

**Clean Architecture:**
1. **Domain isolation**: Verify `domain/` files contain zero `package:flutter` imports.
   ```bash
   grep -r "package:flutter" lib/domain/
   ```
   Expected: no matches.

2. **Data isolation**: Verify `data/` files don't import from `presentation/`.
   ```bash
   grep -r "presentation" lib/data/
   ```
   Expected: no matches.

3. **Presentation isolation**: Verify `presentation/` files don't import from `data/`.
   ```bash
   grep -r "lib/data" lib/presentation/
   ```
   Expected: no matches.

4. **UI swap test**: Replace a page widget and confirm ViewModel tests still pass.

**Vertical Slice Architecture:**
1. **Slice isolation**: Verify no cross-feature imports between feature folders.
   ```bash
   grep -r "features/" lib/features/<feature>/
   ```
   Expected: no references to other feature folders.

2. **Shared kernel purity**: Verify `lib/shared/` contains no feature-specific business logic.
   ```bash
   grep -r "Feature" lib/shared/
   ```
   Expected: no feature names referenced.

3. **Contract stability**: Verify contract/event types are not modified without versioning.
   ```bash
   flutter test test/contracts/
   ```
   Expected: all contract tests pass.

4. **Slice independence**: Swap a page widget in one slice and confirm other slices' tests still pass.

**Serverpod:**
1. **Generated code untouched**: Verify no hand edits under the server's
   `lib/src/generated/` — all changes come from `serverpod generate`.
2. **Client behind repositories**: Verify the Flutter app calls the server only
   through the generated client inside `data/` data sources, never directly
   from widgets or ViewModels.

### Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Vertical Slice Architecture Testing

When the project uses VSA, tests follow the slice:

#### Unit Tests (per ViewModel/Cubit)
- Test ViewModel with a mocked repository.
- File: `test/features/<feature>/viewmodels/<feature>_viewmodel_test.dart`
- For Riverpod (default): use `ProviderContainer.test()` / overrides; verify `AsyncValue` transitions (loading → data → error).
- For BLoC/Cubit (only if explicitly enabled): verify state transitions (loading → data → error) with `bloc_test`.

#### Unit Tests (per repository)
- Test repository implementation with a mocked API client.
- File: `test/features/<feature>/data/<feature>_repository_test.dart`
- Verify correct API calls and entity mapping.

#### Widget Tests (per page)
- Mock ViewModel/Cubit — never use real repositories.
- Test widgets render correctly for each state (loading, data, error).
- File: `test/features/<feature>/pages/<feature>_page_test.dart`

#### Integration Tests (per slice)
- Place in `integration_test/features/<feature>/`.
- Test full user flows within the slice.
- Use mocked backend via `MockClient` or similar.

#### Contract Tests (cross-slice)
- Test that shared contracts/events between slices remain compatible.
- File: `test/contracts/<event>_contract_test.dart`

**VSA Testing Rules:**
- Test folders mirror the feature folder structure.
- Each slice is testable independently — no cross-slice test dependencies.
- ViewModel tested without Flutter framework = fast unit tests.
- Widget tests verify UI states, not business logic.
- Integration tests verify the full vertical path within the slice.

## Test Naming Convention
- `test/<layer>/<type>/<name>_test.dart`
- Test names: `should <expected behavior> when <condition>`

## Reference
- Refer to `conventions.md` in the project root for Flutter conventions.
