---
name: flutter-riverpod-viewmodel
description: 'Implement the Riverpod 3.x + Codegen ViewModel pattern for Flutter state management and dependency injection. Use when creating ViewModels/Notifiers, providers, repository/use-case providers, consuming AsyncValue in widgets, or migrating Riverpod 2.x code. This is the default state-management pattern for Flutter; Bloc/Cubit is a disabled-by-default sub-option.'
argument-hint: 'ViewModel, provider, or feature name'
---

# Riverpod ViewModel Pattern (Riverpod 3.x + Codegen)

> **Status:** Reference pattern — default for any new Flutter feature or project
> in this framework. Bloc/Cubit is only available as a **disabled-by-default
> sub-option** and must be explicitly enabled by the user in the Design phase.

---

## 1. Dependency Set

Riverpod 3 splits the runtime from the code-generation packages. The codegen
major version (4.x) is independent of the runtime major version (3.x).

```yaml
dependencies:
  flutter_riverpod: ^3.4.2   # Flutter bindings + runtime re-export
  riverpod: ^3.4.2           # Pure-Dart runtime (needed by riverpod_annotation)
  riverpod_annotation: ^4.0.6 # @riverpod annotations (runtime dependency)

dev_dependencies:
  build_runner: ^2.4.15
  riverpod_generator: ^4.0.8 # code generator
  custom_lint: ^0.7.0        # optional: lint host for riverpod_lint
  riverpod_lint: ^2.6.0      # optional: Riverpod-specific lint rules
```

**Never** use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider`
in new code. They are legacy in 3.x (importable from
`package:flutter_riverpod/legacy.dart`) but are discouraged and may be removed
in 4.0.

---

## 2. Core Rules

- **Riverpod is the single state-management + DI mechanism.** No `get_it`,
  no manual service locators. DI is wired through `ProviderScope` (and
  `overrides` in tests).
- **ViewModels/Notifiers never reference widgets.** No `BuildContext`, no
  `ScaffoldMessenger`, no `TextEditingController` lifecycle outside the
  Notifier's own `build()`/`ref.onDispose()`.
- **Widgets only observe and trigger.** Widgets call `ref.watch` to read state
  and `ref.read(provider.notifier).method()` to trigger actions. They never
  mutate state directly.
- **All data access goes through use-case providers**
  (`ref.read(xUseCaseProvider).call(...)`), never through repositories directly
  from widgets.
- **Asynchronous state is modeled with `AsyncValue`** (loading/data/error) —
  the UI switches on it with `.when()` / pattern matching.

---

## 3. Dependency Injection Pattern (Repository + Use Cases)

Every repository and use case is a plain `Provider`. Use cases receive
dependencies through the constructor and are wired with `ref.watch`.

```dart
// ---- Repository ----
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return FirestoreGameRepository();
});

// ---- Use cases ----
final getGamesUseCaseProvider = Provider<GetGamesUseCase>((ref) {
  return GetGamesUseCase(ref.watch(gameRepositoryProvider));
});
final createGameUseCaseProvider = Provider<CreateGameUseCase>((ref) {
  return CreateGameUseCase(ref.watch(gameRepositoryProvider));
});
// ...one provider per use case, named `<action>UseCaseProvider`
```

---

## 4. ViewModel Patterns

### 4.1 Async ViewModel (list / CRUD) → `AsyncNotifier`

Use when the state is loaded asynchronously and/or the ViewModel reacts to a
stream. Annotate a class with `@riverpod`; the generator produces an
`AsyncNotifierProvider`.

```dart
@riverpod
class ArticlesViewModel extends _$ArticlesViewModel {
  StreamSubscription? _subscription;

  @override
  FutureOr<List<ArticleModel>> build() async {
    state = const AsyncValue.loading();
    _listenToArticles(); // push data/error into state reactively

    ref.onDispose(() => _subscription?.cancel()); // cleanup
    return [];
  }

  void _listenToArticles() {
    _subscription = ref.read(getArticlesUseCaseProvider).call().listen(
      (articles) => state = AsyncValue.data(articles),
      onError: (e, stack) => state = AsyncValue.error(e, stack),
    );
  }

  // Actions = public methods; read use cases, then let the stream update state.
  Future<void> createArticle(ArticleModel article) async {
    await ref.read(createArticleUseCaseProvider).call(article: article);
  }

  Future<void> deleteArticle(String id) async {
    await ref.read(deleteArticleUseCaseProvider).call(id);
  }
}
```

**Rules:**

- `build()` returns `FutureOr<State>`; start with
  `state = const AsyncValue.loading()`.
- Push reactive updates with `state = AsyncValue.data(...)` /
  `AsyncValue.error(e, stack)`.
- Cancel subscriptions in `ref.onDispose(() => sub?.cancel())`.
- Public methods are the **only** way the UI triggers actions.

### 4.2 Sync ViewModel → `Notifier`

Use for synchronous, simple state (e.g., auth session, filters, counters).

```dart
@riverpod
class Auth extends _$Auth {
  @override
  User? build() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = null;
  }
}
```

Generated provider: `authProvider` (a `NotifierProvider<Auth, User?>` with
`isAutoDispose: true`).

### 4.3 State-Class ViewModel (form / draft) → `Notifier` + immutable state

For forms or drafts, model state as an immutable class with `copyWith` and keep
any controller lifecycle inside the Notifier.

```dart
class GameDraftState {
  final Game? draft;
  final bool isNew;
  final bool isSaving;

  const GameDraftState({this.draft, this.isNew = false, this.isSaving = false});

  GameDraftState copyWith({Game? draft, bool? isNew, bool? isSaving}) {
    return GameDraftState(
      draft: draft ?? this.draft,
      isNew: isNew ?? this.isNew,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@riverpod
class GameDraft extends _$GameDraft {
  TextEditingController? _nameController;

  @override
  GameDraftState build() {
    ref.onDispose(_disposeControllers);
    return const GameDraftState();
  }

  void startEditing(Game? game, {bool isNew = false}) {
    _disposeControllers();
    _nameController = TextEditingController(text: game?.name ?? '');
    state = GameDraftState(draft: game, isNew: isNew);
  }

  void updateDraftName(String name) {
    if (state.draft == null) return;
    state = state.copyWith(draft: state.draft!.copyWith(name: name));
  }
}
```

**Rules:**
- State class is immutable; every mutation goes through `copyWith`.
- Controllers are created lazily and disposed in `ref.onDispose`.
- The UI never owns the controllers — it reads them via getters on the Notifier.

### 4.4 Simple family data → `@riverpod` function (FutureProvider / family)

Use for read-only async data with parameters (the function parameters become the
family arguments).

```dart
@riverpod
Future<ArticleModel?> articleViewModel(Ref ref, String articleId) async {
  return ref.read(getArticleByIdUseCaseProvider).call(articleId);
}
```

Usage: `ref.watch(articleViewModelProvider(articleId))`.

Reactivity (auto-invalidate when a dependency changes) can be wired with
`ref.listen` + `ref.invalidateSelf()`:

```dart
@riverpod
Future<ArticleModel?> articleViewModel(Ref ref, String articleId) async {
  ref.listen(articlesStreamProvider, (previous, next) {
    if (next.hasValue) ref.invalidateSelf();
  });
  return ref.read(getArticleByIdUseCaseProvider).call(articleId);
}
```

### 4.5 Simple stream family → `@riverpod` function (StreamProvider)

```dart
@riverpod
Stream<MedicineSchedule?> medicineSchedule(Ref ref, String userId) {
  return ref.watch(medicineRepositoryProvider).getMedicineSchedule(userId);
}
```

### 4.6 Combined providers → `@riverpod` function returning `AsyncValue`

```dart
@riverpod
AsyncValue<(List<UserModel>, UserModel?)> combinedCaregiversAndUsersData(Ref ref) {
  final usersAsync = ref.watch(usersStreamProvider);
  final currentUserAsync = ref.watch(currentUserProvider);

  return usersAsync.when(
    data: (users) => currentUserAsync.when(
      data: (loggedInUser) => AsyncValue.data((users, loggedInUser)),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}
```

### 4.7 Manual Notifier (no codegen) for trivial UI state

Codegen is preferred, but for a one-off trivial notifier a manual declaration
is acceptable:

```dart
final caregiversFilterTriggerProvider =
    NotifierProvider<CaregiversFilterTrigger, int>(CaregiversFilterTrigger.new);

class CaregiversFilterTrigger extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}
```

---

## 5. Generated Provider Naming

The generator derives the provider name from the annotated symbol:

| Source                                                         | Generated provider                 | Type                    |
| -------------------------------------------------------------- | ---------------------------------- | ----------------------- |
| `@riverpod class ArticlesViewModel`                            | `articlesViewModelProvider`        | `AsyncNotifierProvider` |
| `@riverpod class Auth`                                         | `authProvider`                     | `NotifierProvider`      |
| `@riverpod Future<X> articleViewModel(Ref ref, String id)`     | `articleViewModelProvider(id)`     | `FutureProvider.family` |
| `@riverpod Stream<X> medicineSchedule(Ref ref, String userId)` | `medicineScheduleProvider(userId)` | `StreamProvider.family` |

Default naming can be tuned in `build.yaml` (`provider_name_prefix`,
`provider_name_suffix`, `provider_name_strip_pattern: "Notifier$"`).

---

## 6. UI Consumption Pattern

```dart
class ArticlesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesViewModelProvider);

    return articlesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (articles) => ListView(...),
    );
  }
}
```

- Read state: `ref.watch(xProvider)` → `AsyncValue` → `.when(...)` or pattern match.
- Trigger actions: `ref.read(xProvider.notifier).createArticle(a)`.
- One-shot operations: `ref.read(someUseCaseProvider).call(...)`.
- Out-of-view widgets are automatically **paused** (TickerMode) — no manual
  cleanup needed for visibility.

---

## 7. File Organization

Vertical Slice Architecture (VSA) layout:

```
lib/
└── features/
    └── <feature_name>/
        ├── presentation/
        │   ├── pages/            # Screen-level widgets
        │   ├── widgets/          # Feature-scoped widgets
        │   └── viewmodel/        # Riverpod providers + ViewModels (or providers/)
        ├── domain/               # Pure Dart (entities, use cases, repository interfaces)
        ├── data/                 # Data sources + repository implementations
        └── <feature>_module.dart # Slice DI registration
```

> Both `viewmodel/` and `providers/` folder names are valid — keep the folder
> name consistent within a project and keep provider files co-located with their
> slice. Clean Architecture layout places the ViewModels under
> `lib/presentation/viewmodels/`.

---

## 8. Checklist — Adding a New ViewModel

1. Add the feature slice (if new): `domain/`, `data/`, `presentation/`.
2. Declare repository + use-case `Provider`s in the slice (Section 3).
3. Pick the ViewModel variant (Section 4):
   - Async + reactive → `@riverpod class X extends _$X` (AsyncNotifier)
   - Sync/simple → `@riverpod class X extends _$X` (Notifier)
   - Form/draft → `Notifier` + immutable state class + `copyWith`
   - Read-only family data → `@riverpod Future/Stream<X> x(Ref ref, ...)`
4. Add `part 'file.g.dart';` and run `dart run build_runner build -d`.
5. Expose actions as public methods; never leak `ref` to the UI.
6. Consume in the UI with `ref.watch(...)` + `AsyncValue.when`.
7. Test the Notifier in isolation with `ProviderContainer.test()` / overrides.

---

## 9. Migration Mapping (Riverpod 2.x → 3.x)

| Riverpod 2.x (legacy)                              | Riverpod 3.x (this pattern)                                       |
| -------------------------------------------------- | ----------------------------------------------------------------- |
| `StateNotifierProvider<T, S>` + `StateNotifier<S>` | `@riverpod class X extends _$X` (Notifier) or AsyncNotifier       |
| `StateProvider<T>`                                 | `NotifierProvider<X, T>` + `Notifier<T>` with `build()`           |
| `ChangeNotifierProvider`                           | `NotifierProvider`                                                |
| `Provider.autoDispose` / `.family`                 | Same syntax works; prefer `isAutoDispose: true` constructor param |
| `FutureProvider.autoDispose.family<T, A>`          | `@riverpod Future<T> x(Ref ref, A arg)`                           |
| `ref.read(p.notifier).state = v`                   | `ref.read(p.notifier).method(v)` (no external `state` writes)     |
| `AsyncValue.valueOrNull`                           | `AsyncValue.value` (returns `null` on error)                      |
| `AutoDisposeNotifier` / `FamilyNotifier`           | `Notifier` (unified)                                              |
| `ProviderRef`, `FutureProviderRef`, ...            | `Ref` (unified, no type parameter)                                |

---

## 10. Bloc/Cubit — Disabled-by-Default Sub-Option

- Bloc/Cubit is **not** part of the default Flutter pattern. It is a
  **disabled-by-default sub-option** that must be explicitly enabled by the
  user in the Design phase.
- When enabled, Bloc/Cubit follows the existing `flutter` pattern conventions
  (`flutter-spec`, `flutter-testing`): events/states, `bloc_test`,
  `BlocProvider`/`BlocBuilder` in widgets.
- A project must **never mix** Riverpod and Bloc/Cubit for the same feature.
- If a project is generated with Riverpod (default), Bloc/Cubit is not listed
  in scaffolding options unless the user explicitly asks for it.

## Reference
- Refer to `conventions.md` in the project root for Flutter conventions.
- Riverpod 3 official docs: https://riverpod.dev
