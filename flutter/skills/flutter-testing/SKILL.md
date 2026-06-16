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

### Integration Tests
1. Place in `integration_test/` folder.
2. Test full user flows across screens.
3. Use `IntegrationTestWidgetsFlutterBinding`.

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
- Verify state transitions (loading → data → error).

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
