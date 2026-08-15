# Flutter Riverpod ViewModel Pattern

## What Changed

Integrated the **Riverpod 3.x + Codegen ViewModel pattern** as the default
state-management and dependency-injection standard for the Flutter pattern.
The pattern was distilled from a battle-tested Riverpod 3 reference
implementation and generalized into a first-class framework skill.

The integration has four layers:

1. **New pattern skill** — `flutter/skills/flutter-riverpod-viewmodel/SKILL.md`
   codifies the full pattern: dependency set, core rules, DI (repository +
   use-case providers), the seven ViewModel variants (`AsyncNotifier`,
   `Notifier`, immutable state-class, `FutureProvider` family, `StreamProvider`
   family, combined providers, manual `Notifier`), generated provider naming,
   UI consumption, file organization, ViewModel checklist, and the Riverpod
   2.x → 3.x migration table.
2. **Conventions alignment** — `flutter/conventions.md` now states Riverpod 3.x
   as the single state-management + DI mechanism and makes Bloc/Cubit a
   **disabled-by-default sub-option**.
3. **Agent alignment** — the three Flutter agents (architect, developer,
   reviewer) were updated: developer examples use Riverpod 3.x codegen syntax
   (`Ref` unified, `AsyncNotifier`, `AsyncValue`), the reviewer gained 11
   Riverpod 3.x checks (no legacy providers, no external `state` writes, no
   typed refs, no widget references in Notifiers, no Riverpod+Bloc mixing), and
   the architect defaults to the pattern for state management.
4. **Existing skill alignment** — `flutter-spec`, `flutter-testing`,
   `flutter-feature`, and `flutter-scaffold` now route through the Riverpod
   pattern by default and treat BLoC/Cubit as a disabled-by-default sub-option
   that must be explicitly enabled by the user in the Design phase.

## Why It Changed

The Flutter pattern already named Riverpod as the default state management, but
the guidance was inconsistent:

- Code examples used Riverpod 2.x codegen syntax (`UsersRef`, typed refs)
  instead of Riverpod 3.x (`Ref`, unified).
- `flutter-spec` was entirely BLoC/Cubit-centric even though Riverpod is the
  default.
- `flutter-scaffold` offered `flutter_bloc`, `riverpod`, and `provider` as
  equal state-management choices, which contradicted the "Riverpod by default"
  rule.
- No skill captured the Riverpod 3 ViewModel variants, migration rules, and
  anti-patterns (legacy providers, external `state` writes, widget references
  inside Notifiers).

This integration makes Riverpod 3.x + Codegen the unambiguous default and
relegates Bloc/Cubit to an explicitly enabled sub-option, per user request.

## Files Affected

| File                                                 | Change                                                                                                                                                                                                                                                                                                 |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `flutter/skills/flutter-riverpod-viewmodel/SKILL.md` | **New** — Complete Riverpod 3.x ViewModel pattern skill (dependency set, core rules, DI, 7 ViewModel variants, naming, UI consumption, file organization, checklist, 2.x→3.x migration, Bloc/Cubit disabled-by-default section)                                                                        |
| `flutter/conventions.md`                             | **Updated** — State Management section rewritten for Riverpod 3.x + Codegen as single mechanism; Bloc/Cubit as disabled-by-default sub-option; DI pattern (repository + use-case providers); legacy-provider ban; packages table updated (riverpod codegen, `flutter_bloc` marked disabled-by-default) |
| `flutter/agents/flutter-developer.agent.md`          | **Updated** — Riverpod 3.x codegen examples (`Ref`, `AsyncNotifier`, `AsyncValue`); typed refs flagged as 2.x style; legacy-provider ban; `ProviderContainer.test()` for provider testing; updated before-finishing checklist                                                                          |
| `flutter/agents/flutter-reviewer.agent.md`           | **Updated** — Riverpod-Specific Checks replaced with 11 Riverpod 3.x checks (no legacy providers, no external state writes, no typed refs, no widget refs in Notifiers, no Riverpod+Bloc mixing, `AsyncValue` modeling)                                                                                |
| `flutter/agents/flutter-architect.agent.md`          | **Updated** — State management default changed to Riverpod 3.x + Codegen following the skill; Bloc/Cubit as disabled-by-default sub-option                                                                                                                                                             |
| `flutter/skills/flutter-spec/SKILL.md`               | **Updated** — Added Riverpod ViewModel spec path as default (AsyncValue state map, provider variants, provider-test patterns); BLoC path moved to disabled-by-default sub-option; tool references updated                                                                                              |
| `flutter/skills/flutter-testing/SKILL.md`            | **Updated** — Added Riverpod provider test section (`ProviderContainer.test()`, overrides, AsyncValue assertions, dispose verification)                                                                                                                                                                |
| `flutter/skills/flutter-feature/SKILL.md`            | **Updated** — Presentation-layer steps route through the riverpod-viewmodel skill; BLoC/Cubit as disabled-by-default sub-option                                                                                                                                                                        |
| `flutter/skills/flutter-scaffold/SKILL.md`           | **Updated** — State-management question removed (Riverpod 3.x is default, no question); dependency set updated for Riverpod codegen; `ProviderScope` in `main.dart` as default DI; `get_it` only for non-Riverpod projects                                                                             |
| `Docs/framework-ai-enhancement-phase.md`             | **Updated** — Added entry for this change                                                                                                                                                                                                                                                              |
| `VERSION`                                            | **Updated** — Bumped to 0.5.0                                                                                                                                                                                                                                                                          |
| `.github/project-memory.md`                          | **Updated** — Added Riverpod ViewModel Pattern section                                                                                                                                                                                                                                                 |

## Key Rules of the Pattern

- Riverpod is the **single** state-management + DI mechanism (no `get_it`).
- ViewModels/Notifiers never reference widgets (no `BuildContext`).
- Widgets only observe (`ref.watch`) and trigger (`ref.read(provider.notifier).method()`).
- All data access goes through use-case providers, never repositories from widgets.
- Async state is modeled with `AsyncValue` and consumed with `.when()`.
- **Never** use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider` (legacy in 3.x).
- Use `Ref` (unified) — typed refs (`UsersRef`, `GetUsersRef`) are Riverpod 2.x style.
- A project never mixes Riverpod and Bloc/Cubit for the same feature.

## Skill Usage

When implementing Flutter features or ViewModels:

1. The agent invokes `flutter-riverpod-viewmodel` (directly or via the main
   PovoAgent workflow) whenever a ViewModel, provider, or state is needed.
2. The skill guides the variant choice (`AsyncNotifier` / `Notifier` / state
   class / read-only provider) and the DI wiring (repository + use-case
   providers).
3. UI code consumes providers with `ref.watch` + `AsyncValue.when`, triggering
   actions through `provider.notifier`.
4. Tests use `ProviderContainer.test()` and `ProviderScope.overrides`.
