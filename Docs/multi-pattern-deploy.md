# Multi-Pattern Deploy Support

## What Changed

Both `deploy.ps1` and `deploy.sh` now accept one or more technology patterns in a single deploy run instead of requiring a separate run for each pattern.

### Bug Fix (2026-06-05)

- Fixed `deploy.ps1` single-pattern parsing to always produce an array for `$Patterns`.
- This prevents a strict-mode runtime failure at pattern-conventions step when checking `$Patterns.Count`.
- Added an early validation guard in `deploy.ps1` that fails fast when parsed pattern input is empty (for example, `-t ","`).
- Added the same early empty-pattern validation guard in `deploy.sh` so both scripts fail fast with a clear message.

## Why It Changed

Projects that combine multiple technology stacks (e.g. a .NET backend with an Angular frontend) needed a way to deploy all relevant conventions, agents, and skills in one step.

## How It Works

### PowerShell (`deploy.ps1`)

- The `-Pattern` parameter now accepts a comma-separated string (e.g. `"flutter,dotnet"`).
- In interactive mode, the new `Select-MultiOption` function lets you choose multiple patterns by entering comma-separated numbers (e.g. `1,3`).
- A `$Patterns` array is derived by splitting the input on commas/semicolons.

### Bash (`deploy.sh`)

- The `-t` flag now accepts a comma-separated value (e.g. `-t flutter,dotnet`).
- In interactive mode, the new `select_multiple` function allows comma-separated number input.
- A `PATTERNS` array is built by splitting the `PATTERN` string on commas.

### Conventions File Naming

| Patterns supplied | File name |
|---|---|
| Single pattern | `conventions.md` (backward compatible) |
| Multiple patterns | `conventions-{pattern}.md` per pattern |

### Agents and Skills

Pattern agents and skills from each pattern are deployed into the same target agents and skills directories. Files from different patterns coexist because each pattern uses distinct file names.

### `.gitignore`

The PovoAgent-managed block in `.gitignore` correctly lists all deployed convention files, agents, and skill directories for every pattern that was deployed.

## Files Affected

- `deploy.ps1`
- `deploy.sh`
