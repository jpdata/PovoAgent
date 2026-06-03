---
name: flutter-spec
description: 'Translates the Flutter Design Document into formal Specification Documents for BLoC/Cubit events and states, use cases, repositories, and widgets. Maps each spec scenario to flutter_test and bloc_test patterns. Use after Design and before Implementation in Flutter projects.'
argument-hint: 'Feature, BLoC, or widget name to specify'
---

# Flutter Specification

## When to Use

- After the Flutter architecture Design Document is approved.
- Before writing any BLoC, use case, repository, or widget.
- When adding a new feature to an existing Flutter project.

## Flutter-Specific Specification Units

| Unit Type | Layer | Spec Focus |
|---|---|---|
| Domain entity / value object | Domain | Immutability, equality (`Equatable`), validation |
| Use case | Domain / Application | Single-responsibility business logic, input→output, error types |
| Repository contract | Domain | Abstract interface: method signatures, return types (`Either<Failure, T>`) |
| Repository implementation | Data | Actual data source calls, error mapping to `Failure` types |
| BLoC / Cubit | Presentation | Event→State transitions, error state, loading state |
| Widget (page / feature) | Presentation | Rendered output per BLoC state, user interactions |

## Workflow

1. Read the Flutter Design Document (Clean Architecture layers, BLoC events/states, API contracts).
2. Identify all use cases, BLoC/Cubits, repositories, and key widgets that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the Flutter-specific fields below.
5. Map each scenario to a `bloc_test` or `flutter_test` pattern.
6. Verify every BLoC spec covers `Initial`, `Loading`, `Success`, and `Failure` states.
7. Verify every use-case spec covers the success path and each failure type.

## Flutter-Specific Spec Fields

Add the following section to each spec in a Flutter project:

````markdown
## Flutter Implementation Hints

### Unit Type
- [ ] Domain entity / value object (`Equatable`)
- [ ] Use case (returns `Either<Failure, T>` or `Result<T>`)
- [ ] Repository contract (abstract class)
- [ ] Repository implementation (data layer)
- [ ] BLoC (event-driven)
- [ ] Cubit (method-driven)
- [ ] Widget (page or feature component)

### BLoC / Cubit Event → State Map
| Event / Method | Initial State | Expected Next State(s) |
|---|---|---|
| `LoadXxx` | `XxxInitial` | `XxxLoading` → `XxxLoaded` or `XxxError` |
| `SubmitXxx` | `XxxLoaded` | `XxxSubmitting` → `XxxSuccess` or `XxxError` |

### Use Case Contract
```dart
// Input entity or parameters class
// Output: Either<Failure, OutputEntity> or Result<OutputEntity>
// Failure types: list all possible Failure subtypes
```

### Widget State Scenarios
| BLoC State | Expected Widget Output |
|---|---|
| `XxxInitial` | Empty / placeholder shown |
| `XxxLoading` | `CircularProgressIndicator` or skeleton |
| `XxxLoaded` | Data widgets rendered with correct values |
| `XxxError` | Error message widget with retry option |

### bloc_test / flutter_test Pattern Reference
| Scenario | Test Approach |
|---|---|
| BLoC event success | `blocTest<XxxBloc, XxxState>`, `act: (b) => b.add(LoadXxx())`, `expect: [XxxLoading(), XxxLoaded(data)]` |
| BLoC event failure | Same pattern, mock repo to throw/return `Left(Failure())` |
| Use case success | Mock repo, call `useCase(params)`, assert `Right(result)` |
| Use case failure | Mock repo returns `Left(Failure())`, assert correct `Failure` type |
| Widget render | `pumpWidget` with `BlocProvider` providing mock BLoC, `find.byType / find.text` |
| Widget interaction | `tap(find.byKey(...))`, `pumpAndSettle()`, assert BLoC event added |
````

## Acceptance Criteria (Flutter-specific additions)

- [ ] Every BLoC spec maps all events to all reachable states.
- [ ] Every use case spec lists all `Failure` subtypes that the use case can return.
- [ ] Every widget spec covers all BLoC states the widget reacts to.
- [ ] Repository contract specs define return types as `Either<Failure, T>` or equivalent.
- [ ] Domain entity specs verify `Equatable` props and any factory validation.

## Tool References

- **Testing:** `flutter_test` (built-in)
- **BLoC testing:** `bloc_test` package
- **Mocking:** `mocktail` or `mockito`
- **Functional types:** `dartz` (`Either<L, R>`) or `fpdart`
- **Dependency injection:** `get_it` + `injectable`

## Pattern Reference

Follow the Clean Architecture conventions defined in `flutter/conventions.md`.
All repository contracts must match the domain port definitions in the Design Document.
