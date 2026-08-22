---
name: flutter-spec
description: 'Translates the Flutter Design Document into formal Specification Documents for Riverpod ViewModels/Notifiers (default) or BLoC/Cubit events and states, use cases, repositories, and widgets. Maps each spec scenario to flutter_test and Riverpod provider-test patterns. Use after Design and before Implementation in Flutter projects.'
argument-hint: 'Feature, ViewModel, BLoC, or widget name to specify'
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
| Riverpod ViewModel / Notifier (default) | Presentation | `AsyncValue` states (loading/data/error), public action methods, provider variant |
| BLoC / Cubit (disabled-by-default sub-option) | Presentation | Event→State transitions, error state, loading state |
| Widget (page / feature) | Presentation | Rendered output per state, user interactions |
| Serverpod model (`.spy.yaml`) | Backend (Serverpod) | `class:` / `table:` / `fields:`, field types, serialization |
| Serverpod endpoint | Backend (Serverpod) | Method signatures (`Session`, typed `Future`/`Stream`), stateless behavior, error types |

> **State management default:** Riverpod 3.x + Codegen following the
> `flutter-riverpod-viewmodel` skill. BLoC/Cubit is only specified when it was
> explicitly enabled in the Design phase.

## Workflow

1. Read the Flutter Design Document (Clean Architecture layers, ViewModel/BLoC design, API contracts).
2. Identify all use cases, ViewModels/BLoCs, repositories, and key widgets that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the Flutter-specific fields below.
5. Map each scenario to a `flutter_test` / Riverpod provider-test pattern (default) or `bloc_test` pattern (only if BLoC was enabled).
6. Verify every ViewModel spec covers `AsyncValue` loading, data, and error states (or `Initial`, `Loading`, `Success`, `Failure` for BLoC).
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
- [ ] Riverpod ViewModel / Notifier (`@riverpod class X extends _$X` — AsyncNotifier or Notifier) [default]
- [ ] Riverpod read-only provider (`@riverpod Future/Stream<X> x(Ref ref, ...)`) [default]
- [ ] BLoC (event-driven) / Cubit (method-driven) [only if explicitly enabled in Design]
- [ ] Widget (page or feature component)

### Riverpod ViewModel → AsyncValue State Map [default]
| Action / Method | Initial State | Expected Next State(s) |
|---|---|---|
| `build()` (async) | `AsyncValue.loading()` | `AsyncValue.data(...)` or `AsyncValue.error(e, stack)` |
| `createX(x)` | `AsyncValue.data(list)` | `AsyncValue.data(updatedList)` or `AsyncValue.error` |
| `refresh()` | `AsyncValue.loading()` | `AsyncValue.data(...)` or `AsyncValue.error(e, stack)` |

- Provider variant (Section 4 of the `flutter-riverpod-viewmodel` skill):
  - Async + reactive → `AsyncNotifier`
  - Sync/simple → `Notifier`
  - Form/draft → `Notifier` + immutable state class + `copyWith`
  - Read-only family data → `@riverpod Future/Stream<X> x(Ref ref, ...)`
- Cleanup: subscriptions cancelled in `ref.onDispose`; controllers disposed in `ref.onDispose`.
- UI never writes `state` — actions are public methods on the Notifier.

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
| State | Expected Widget Output |
|---|---|
| `AsyncValue.loading()` / `XxxLoading` | `CircularProgressIndicator` or skeleton |
| `AsyncValue.data(...)` / `XxxLoaded` | Data widgets rendered with correct values |
| `AsyncValue.error(...)` / `XxxError` | Error message widget with retry option |
| `XxxInitial` (BLoC only) | Empty / placeholder shown |

### flutter_test / Riverpod Provider-Test Pattern Reference [default]
| Scenario | Test Approach |
|---|---|
| Notifier build success | `ProviderContainer.test()`, read provider, assert `AsyncValue.data` |
| Notifier build failure | Override repository/use-case provider to throw, assert `AsyncValue.error` |
| Action method | Read `provider.notifier`, call method, assert state transition |
| Use case success | Mock repo, call `useCase(params)`, assert `Right(result)` |
| Use case failure | Mock repo returns `Left(Failure())`, assert correct `Failure` type |
| Widget render | `pumpWidget` with `ProviderScope(overrides: [...])` providing mocked providers |
| Widget interaction | `tap(find.byKey(...))`, `pumpAndSettle()`, assert action called on notifier |

### bloc_test / flutter_test Pattern Reference [BLoC only — disabled-by-default sub-option]
| Scenario | Test Approach |
|---|---|
| BLoC event success | `blocTest<XxxBloc, XxxState>`, `act: (b) => b.add(LoadXxx())`, `expect: [XxxLoading(), XxxLoaded(data)]` |
| BLoC event failure | Same pattern, mock repo to throw/return `Left(Failure())` |
| Widget render | `pumpWidget` with `BlocProvider` providing mock BLoC, `find.byType / find.text` |
| Widget interaction | `tap(find.byKey(...))`, `pumpAndSettle()`, assert BLoC event added |
````

## Serverpod Specification Fields

Add the following to each spec when the project uses **Serverpod** (see the
`flutter-serverpod` skill):

````markdown
## Serverpod Implementation Hints

### Unit Type
- [ ] Serverpod model (`.spy.yaml` file: `class:`, optional `table:`, `fields:`)
- [ ] Serverpod endpoint (class extends `Endpoint`)

### Model Spec
| Field | Type | Required | DB Column (when `table:` set) |
|---|---|---|---|
| `id` | `int?` | auto | primary key |
| `<field>` | `<Dart type>` | yes/no | `<column>` |

- Serialization is generated — verify `serverpod generate` produces
  `lib/src/generated/<model>.dart` and the client type.

### Endpoint Spec
| Method | Signature | Returns | Stateless? | Error types |
|---|---|---|---|---|
| `create<Feature>` | `(Session session, <Feature> item)` | `Future<<Feature>>` | yes | `ServerpodException` |
| `list<Feature>s` | `(Session session)` | `Future<List<<Feature>>>` | yes | `ServerpodException` |

- First parameter is always `Session session`.
- Return type is `Future<T>`/`Stream<T>` with a serializable `T`.
- No global/static state; each method is a sub-second unit of work.

### Server Test Mapping
| Scenario | Test Approach |
|---|---|
| Endpoint success | `withServerpod(...)` in `<project>_server/test/`, call `endpoints.<feature>.<method>` |
| Endpoint failure | Same helper, arrange failing precondition, assert exception/error |
| Model round-trip | Insert via `endpoints`, read back, assert field equality |
| DB persistence | `withServerpod` + `Model.db.find/insertRow`, assert persisted row |
````

## Acceptance Criteria (Flutter-specific additions)

- [ ] Every Riverpod ViewModel spec covers `AsyncValue` loading, data, and error states (default).
- [ ] Every Riverpod ViewModel spec names the provider variant and its generated provider name.
- [ ] Every BLoC spec maps all events to all reachable states (only in BLoC-enabled projects).
- [ ] Every use case spec lists all `Failure` subtypes that the use case can return.
- [ ] Every widget spec covers all states the widget reacts to (`AsyncValue` states by default).
- [ ] Repository contract specs define return types as `Either<Failure, T>` or equivalent.
- [ ] Domain entity specs verify `Equatable` props and any factory validation.
- [ ] Every Serverpod endpoint spec names each method's `Session` parameter, typed `Future`/`Stream` return, and stateless behavior (only in Serverpod projects).
- [ ] Every Serverpod model spec lists the `class:` / `table:` / `fields:` definitions and field types (only in Serverpod projects).

## Tool References

- **Testing:** `flutter_test` (built-in)
- **Riverpod testing (default):** `ProviderContainer.test()` (from `riverpod`) and `ProviderScope.overrides`
- **BLoC testing:** `bloc_test` package (only in BLoC-enabled projects)
- **Mocking:** `mocktail` or `mockito`
- **Functional types:** `dartz` (`Either<L, R>`) or `fpdart`
- **Dependency injection:** Riverpod `ProviderScope` (default); `get_it` + `injectable` only for non-Riverpod projects

## Pattern Reference

Follow the Clean Architecture conventions defined in `flutter/conventions.md`.
All repository contracts must match the domain port definitions in the Design Document.
