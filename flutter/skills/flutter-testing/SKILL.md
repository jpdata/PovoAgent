---
name: flutter-testing
description: 'Generate and run tests for a Flutter Clean Architecture project. Use when writing unit tests, widget tests, integration tests, validating decoupling between layers, or checking test coverage for a Flutter app.'
argument-hint: 'Feature or layer to test'
---

# Flutter Testing

## When to Use
- Writing or generating tests for a feature or layer.
- Validating that architectural decoupling is maintained.
- Checking test coverage.

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

### Decoupling Validation
1. **Domain isolation**: Verify `domain/` files contain zero `package:flutter` imports.
   ```bash
   grep -r "package:flutter" lib/domain/
   ```
   Expected result: no matches.

2. **Data isolation**: Verify `data/` files don't import from `presentation/`.
   ```bash
   grep -r "presentation" lib/data/
   ```
   Expected result: no matches.

3. **Presentation isolation**: Verify `presentation/` files don't import from `data/`.
   ```bash
   grep -r "lib/data" lib/presentation/
   ```
   Expected result: no matches.

4. **UI swap test**: Replace a page widget and confirm ViewModel tests still pass.

### Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Naming Convention
- `test/<layer>/<type>/<name>_test.dart`
- Test names: `should <expected behavior> when <condition>`

## Reference
- [Flutter Conventions](../conventions.md)
