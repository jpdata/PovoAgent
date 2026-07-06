# Flutter Hook System

## Overview

The PovoAgent framework provides **pattern-aware Git hooks** that are deployed alongside the AI agent configuration. When deploying the Flutter pattern, a specialized pre-commit hook is used instead of the generic one, ensuring proper version synchronization between `VERSION` and `pubspec.yaml`.

## Motivation

Flutter projects use `pubspec.yaml` to declare the application version (e.g., `version: 1.2.3+4`), which is used by `flutter build` to set the app version in Android, iOS, and other platforms. The generic pre-commit hook only updates the root `VERSION` file, leaving `pubspec.yaml` out of sync. The Flutter-specific hook solves this by keeping both files aligned on every commit.

## Hook Selection Logic

The deploy scripts (`deploy.ps1` and `deploy.sh`) automatically select the correct hook based on the patterns requested:

| Pattern(s)                         | Hook Deployed              | Behavior                       |
|------------------------------------|----------------------------|--------------------------------|
| Flutter (alone or with others)     | `pre-commit-flutter`       | Bumps `VERSION` + syncs `pubspec.yaml` |
| Any non-Flutter pattern            | `pre-commit`               | Bumps `VERSION` only            |

> **Note:** When deploying multiple patterns including Flutter (e.g., `-Pattern "flutter,dotnet"`), the Flutter hook is used because the Flutter project needs `pubspec.yaml` synced. The hook is harmless for non-Flutter projects — if `pubspec.yaml` is absent, it logs a warning and skips the sync.

## Flutter Hook Behavior (`pre-commit-flutter`)

On every `git commit`, the hook performs the following steps:

1. **Read or create** `VERSION` file at the Git repository root.
2. **Increment** the patch version (e.g., `0.1.0` → `0.1.1`).
3. **Write** the new version to `VERSION` and stage it.
4. **Read** `pubspec.yaml` from the repository root.
5. **Parse** the existing `version:` field. If it contains a build number (`+N`), preserve it.
6. **Replace** the semantic part of the `version:` field with the new version, keeping the build number intact.
7. **Stage** `pubspec.yaml`.

### Build Number Preservation

The hook intelligently handles the `+N` build suffix:

- `version: 1.2.3+4` → `version: 1.2.4+4` (build number preserved)
- `version: 1.2.3` → `version: 1.2.4` (no build number)
- No `version:` field → warning logged, `pubspec.yaml` not modified

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| `VERSION` file missing | Created with `0.1.0` |
| `pubspec.yaml` missing | Warning logged, only `VERSION` is bumped |
| `pubspec.yaml` has no `version:` field | Warning logged, only `VERSION` is bumped |
| `pubspec.yaml` has `version: 1.0.0+5` | New version: `1.0.1+5` |
| First commit in a new repo | `VERSION` created as `0.1.0`, `pubspec.yaml` synced if present |

## How to Use

### During Deploy (recommended)

```powershell
# Deploy with Flutter-specific hook
.\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp -GitHooks
```

```bash
# Deploy with Flutter-specific hook
./deploy.sh -p copilot -t flutter -d /path/to/project -g
```

### Manual Install

If you already have a PovoAgent-deployed project and want to add the Flutter hook manually:

```bash
cp hooks/pre-commit-flutter /path/to/project/.git/hooks/pre-commit
chmod +x /path/to/project/.git/hooks/pre-commit
```

## Files Changed

| File | Change |
|------|--------|
| `hooks/pre-commit-flutter` | **New** — Flutter-specific pre-commit hook |
| `deploy.ps1` | **Updated** — Step 7 selects hook by pattern; Flutter-aware summary |
| `deploy.sh` | **Updated** — Step 7 selects hook by pattern; Flutter-aware summary |

## See Also

- `Docs/evolutionary-lifecycle.md` — Overall project lifecycle documentation
- `hooks/pre-commit` — Generic pre-commit hook (VERSION only)
- `hooks/pre-commit-flutter` — Flutter-specific pre-commit hook (VERSION + pubspec.yaml)
