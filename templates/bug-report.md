# Bug Report

> Template for reporting and tracking a bug fix on an existing project.
> Fill sections 1–4 during `change-intake`. Fill sections 5–6 during Diagnosis and Verification.

## 1. Metadata

| Field | Value |
|---|---|
| ID | BUG-<NNN> |
| Project | <project name> |
| Priority | Critical / High / Medium / Low |
| Architecture | Clean Architecture / Vertical Slice Architecture |
| Author | <author> |
| Date | <date> |

## 2. Description

**Observed Behavior:** <What actually happens. Be concrete: error message, wrong output, crash, visual glitch.>

**Expected Behavior:** <What should happen instead.>

**Steps to Reproduce:**
1. <Step 1 — be precise: which page, which action, which input>
2. <Step 2>
3. <Step 3>
4. <Observe the bug>

## 3. Environment

| Aspect | Detail |
|---|---|
| Pattern / Framework | <e.g., React + Vite, .NET 8, Flutter 3.x> |
| Architecture | Clean Architecture / Vertical Slice Architecture |
| Browser / Device | <if applicable> |
| OS | <if applicable> |
| Commit / Version | <git hash or version tag> |

## 4. Affected Area

| Aspect | Detail |
|---|---|
| Feature(s) | <list of feature names> |
| Layer / Slice | <Presentation / Application / Domain / Infrastructure, or Slice name> |
| Suspected Files | <list of files likely containing the bug> |
| Related Specs | <SPEC_<Feature>.md references> |
| Related Tests | <list of test files covering this area> |

## 5. Diagnosis

> _Fill during the Diagnosis phase — before writing any fix code._

### Root Cause

<Description of what code or logic is wrong. Be specific: which file, which function, which line. What is it doing vs. what should it do?>

### Fix Strategy

<How the bug will be corrected. What files change. What approach (e.g., fix condition, add validation, update contract).>

### Affected Contracts

<Any interfaces, API contracts, or cross-slice events that need updating as part of the fix. None if not applicable.>

## 6. Verification

> _Fill after the fix is implemented and tested._

| Check | Status |
|---|---|
| Fix applied in | <list of changed files> |
| All existing tests pass | ☐ |
| New regression tests pass | ☐ |
| Steps to reproduce no longer trigger the bug | ☐ |
| Review approved | ☐ |

### New Regression Tests

| Test | Scenario Covered |
|---|---|
| <test name> | <what scenario it prevents from recurring> |
| <test name> | <what scenario it prevents from recurring> |

## 7. Workflow

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Diagnosis | `analysis` (scoped) | Root cause + fix strategy |
| 2 | Implementation | `implementation` + `<pattern>-feature` | Fix applied |
| 3 | Testing | `testing` + `<pattern>-testing` | Regression tests + validation |
| 4 | Review | `review` + Reviewer agent | Review report |

## Approval

- [ ] Bug report reviewed and approved by user
- [ ] Diagnosis confirmed before implementation
- [ ] Fix verified and reviewed
