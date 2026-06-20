---
name: change-intake
description: 'Guides the intake conversation for changes to an existing project: new features, modifications, bug fixes, refactors, or assessments. Use when working on an existing project before any implementation begins. Produces a Change Request, Bug Report, or Assessment Report document that routes to the appropriate lightweight workflow.'
---

# Change Intake Skill

## Objective

Collect all information needed to work on an **existing project** through an interactive conversation. At the end, produce either a **Change Request Document** (for features, modifications, or refactors), a **Bug Report Document** (for bug fixes), or an **Assessment Report Document** (for project assessments). The document type determines which lightweight workflow is followed.

## When to Use

- A user says "I need to add a feature to my project", "I found a bug in...", "I want to refactor module X", "I want to assess my project for improvements", or describes work on an already-initialized project.
- Before any Implementation, Testing, or Review work begins on an existing project.
- When the user explicitly mentions an existing project name or references artifacts like `PROJECT_INTAKE.md`, `PROJECT_PLAN.md`, or `SPEC_*.md`.
- Do **not** use this skill for new projects — use `kickoff` instead.

## Pre-Intake Check

Before starting the conversation, ask the user:

> "Is this work on an existing project? If so, does the project have a `PROJECT_INTAKE.md` or design documents I can read?"

If available, read the existing project documents to pre-fill as much context as possible. This reduces repetitive questions.

## Conversation Flow

Conduct the intake as a guided interview. Ask questions in the following order. Wait for and confirm each answer before continuing. Keep questions short and friendly. **Skip any question whose answer is already clear from the existing project documents.**

### Block 1 — Existing Project Context

1. **Project reference** — What is the name of the existing project?
2. **Technology stack** — What pattern, framework, and AI platform does it use? (Read from `PROJECT_INTAKE.md` if available; otherwise ask.)
3. **Architecture style** — Clean Architecture or Vertical Slice Architecture? (Read from `PROJECT_INTAKE.md` if available; otherwise ask.)
4. **Current state** — Is the project already deployed? In development? Which features are already built?

### Block 2 — Change Type and Motivation

5. **Change type** — What kind of change is this?
   - **New feature** — Adding a new capability that does not exist yet.
   - **Modification** — Changing the behavior, UI, or logic of an existing feature.
   - **Bug fix** — Correcting unintended or incorrect behavior.
   - **Refactor** — Restructuring code without changing external behavior.
   - **Assessment** — Holistic analysis of an existing project to identify improvements across architecture, technical aspects, and flows. Produces an `ASSESSMENT_REPORT.md` with prioritized findings and optional generated Change Requests.
6. **Motivation** — Why is this change needed? What problem does it solve or what value does it add?
7. **Priority** — How urgent or important is this change? (Critical / High / Medium / Low)

### Block 3 — Scope and Impact

8. **Affected features** — Which existing feature(s) does this change touch?
9. **Affected layers or slices** — For Clean Architecture: which layers (Presentation, Application, Domain, Infrastructure)? For Vertical Slice Architecture: which slices?
10. **Affected files** — If known, which specific files or modules need to change?
11. **Cross-slice or cross-layer dependencies** — Does this change affect contracts between slices (VSA) or interfaces between layers (CA)?
12. **Expected behavior** — What should happen after this change? Be concrete: what does the user see? What does the system return?

### Block 4 — Risks and Verification

13. **Existing tests** — Are there tests covering the affected area? If so, which test files?
14. **New tests needed** — Should new tests be written for this change? What scenarios need coverage?
15. **Breaking changes** — Could this change break anything else? Any dependent features, APIs, or integrations?
16. **Rollback plan** — If this change causes problems, how would we undo it?

### Confirmation Step

After all questions are answered, present a summary and ask:

> "Does this summary look correct? Should I adjust anything before generating the document?"

Apply corrections if needed, then generate the appropriate document.

## Routing — Which Workflow Follows

The change type determines which skills are invoked next. The intake skill itself does not invoke them — it produces the document that guides the next agent turn.

### Feature

```
Change Intake → Specification → Implementation → Testing → Review
```

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Specification | `specification` + `<pattern>-spec` | `SPEC_<Feature>.md` |
| 2 | Implementation | `implementation` + `<pattern>-feature` | Working decoupled code |
| 3 | Testing | `testing` + `<pattern>-testing` | Test suite + reports |
| 4 | Review | `review` + Reviewer agent | Review report |

### Modification

```
Change Intake → Implementation → Testing → Review
```

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Implementation | `implementation` + `<pattern>-feature` | Updated code on affected layers/slices |
| 2 | Testing | `testing` + `<pattern>-testing` | Updated test suite + regression report |
| 3 | Review | `review` + Reviewer agent | Review report |

If the modification changes contracts or APIs, insert `design` before `implementation`.

### Bug Fix

```
Change Intake → Diagnosis → Implementation → Testing → Review
```

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Diagnosis | `analysis` (scoped to the bug) | Root cause analysis in the bug report |
| 2 | Implementation | `implementation` + `<pattern>-feature` | Fix applied |
| 3 | Testing | `testing` + `<pattern>-testing` | Regression tests + fix validation |
| 4 | Review | `review` + Reviewer agent | Review report |

The **diagnosis step** reads the affected code, traces the bug to its root cause, and documents the fix strategy in the bug report before implementation begins.

### Refactor

```
Change Intake → Pre-Review → Implementation → Testing → Post-Review
```

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Pre-Review | `review` + Reviewer agent | Current-state review identifying violations |
| 2 | Implementation | `implementation` + `<pattern>-feature` | Refactored code (behavior unchanged) |
| 3 | Testing | `testing` + `<pattern>-testing` | Confirmation: all existing tests still pass |
| 4 | Post-Review | `review` + Reviewer agent | Final review confirming violations resolved |

### Assessment

```
Change Intake → Analysis (Assessment Mode) → Assessment Report → (optional) Generate Change Requests
```

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Analysis (Assessment) | `analysis` (assessment mode) | `ASSESSMENT_REPORT.md` with categorized findings |
| 2 | Review | `review` + Reviewer agent | Validation of findings against conventions |
| 3 | Generate CRs | `change-intake` (per finding) | Individual `CHANGE_REQUEST.md` per high-priority finding (optional) |

The **analysis (assessment mode)** step performs a systematic review of the existing project across three dimensions:
- **Architecture:** SOLID compliance, layer/slice boundaries, decoupling, design patterns, folder structure.
- **Technical:** Performance, security, maintainability, code quality, dependency health, technical debt.
- **Flows:** User flows, data flows, API contracts, cross-slice communication, process optimization.

Each finding is categorized by severity (Critical / High / Medium / Low) and includes a concrete recommendation. High and Critical findings may optionally spawn individual Change Requests for execution.

## Inputs

- User responses during the conversation.
- Existing project documents if available: `PROJECT_INTAKE.md`, `PROJECT_PLAN.md`, `SPEC_*.md`, Design Document, source code.

## Outputs

### Change Request Document (`CHANGE_REQUEST.md`)

Produced for **feature**, **modification**, and **refactor** changes.

```markdown
# Change Request

## Metadata

| Field | Value |
|---|---|
| ID | CR-<NNN> |
| Project | <project name> |
| Type | Feature / Modification / Refactor |
| Priority | Critical / High / Medium / Low |
| Author | <author> |
| Date | <date> |

## Motivation

<Why this change is needed. What problem it solves or value it adds.>

## Current State

<What currently exists. Reference existing specs, features, or behavior.>

## Expected State

<Concrete description of what should exist after the change.>

## Scope

- **Affected Features:** <list>
- **Affected Layers (CA):** <Presentation / Application / Domain / Infrastructure>
- **Affected Slices (VSA):** <list of slices>
- **Affected Files:** <list of known files or modules>
- **Cross-Slice / Cross-Layer Dependencies:** <list of contracts or interfaces affected>

## Architecture Impact

- **Contracts Changed:** <yes / no, and which ones>
- **New Dependencies:** <list of new external or internal dependencies>
- **Breaking Changes:** <yes / no, and description if yes>

## Testing

- **Existing Tests Covering This Area:** <list of test files>
- **New Tests Required:** <list of test scenarios>
- **Regression Risk:** <High / Medium / Low>

## Rollback

<How to undo this change if it causes problems.>

## Approval

- [ ] Change request reviewed and approved by user
- [ ] Specification / Design updated (if applicable)
```

### Bug Report Document (`BUG_REPORT.md`)

Produced for **bug fix** changes. Note: the **Root Cause** and **Fix Strategy** sections are filled in during the Diagnosis phase, not during the intake.

```markdown
# Bug Report

## Metadata

| Field | Value |
|---|---|
| ID | BUG-<NNN> |
| Project | <project name> |
| Priority | Critical / High / Medium / Low |
| Author | <author> |
| Date | <date> |

## Description

**Observed Behavior:** <What actually happens. Be concrete: error message, wrong output, crash.>

**Expected Behavior:** <What should happen instead.>

**Steps to Reproduce:**
1. <Step 1>
2. <Step 2>
3. <Step 3>

## Environment

- **Pattern / Framework:** <pattern + version>
- **Architecture:** <Clean Architecture / Vertical Slice Architecture>
- **Browser / Device:** <if applicable>
- **OS:** <if applicable>

## Affected Area

- **Feature(s):** <list>
- **Layer / Slice:** <Presentation / Application / Domain / Infrastructure | Slice name>
- **Suspected Files:** <list of files likely containing the bug>

## Diagnosis

> _Filled during the Diagnosis phase._

- **Root Cause:** <description of what code or logic is wrong>
- **Fix Strategy:** <how the bug will be corrected>
- **Affected Contracts:** <any interfaces or API contracts that need updating>

## Testing

- **Existing Tests:** <list of test files covering this area>
- **New Regression Tests:** <list of scenarios to prevent recurrence>

## Verification

> _Filled after the fix is implemented and tested._

- [ ] Fix applied in <files>
- [ ] All existing tests pass
- [ ] New regression tests pass
- [ ] Review approved

## Approval

- [ ] Bug report reviewed and approved by user
```

### Assessment Report Document (`ASSESSMENT_REPORT.md`)

Produced for **assessment** type changes.

```markdown
# Assessment Report

## Metadata

| Field | Value |
|---|---|
| ID | ASMT-<NNN> |
| Project | <project name> |
| Type | Assessment |
| Priority | <overall priority> |
| Architecture | Clean Architecture / Vertical Slice Architecture |
| Author | <author> |
| Date | <date> |

## Executive Summary

<One-paragraph summary of the project's current health, key strengths, and critical issues found.>

## Scope

- **Assessment Type:** <Architecture / Technical / Flows / Full>
- **Features Analyzed:** <list>
- **Layers / Slices Analyzed:** <list>
- **Files Reviewed:** <count and key files>

## Architecture Findings

| # | Severity | Category | Finding | Recommendation | 
|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <SOLID / Decoupling / Patterns / Structure> | <description> | <concrete action> |

## Technical Findings

| # | Severity | Category | Finding | Recommendation |
|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <Performance / Security / Maintainability / Dependencies / Debt> | <description> | <concrete action> |

## Flow Findings

| # | Severity | Category | Finding | Recommendation |
|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <User Flow / Data Flow / API Contract / Cross-Slice> | <description> | <concrete action> |

## Prioritized Recommendations

### Critical
<Must fix now. List with linked CRs.>

### High
<Should fix in the current cycle.>

### Medium
<Plan for next cycle.>

### Low
<Nice to have; no urgency.>

## Generated Change Requests

| CR ID | Finding Reference | Priority | Status |
|---|---|---|---|
| CR-<NNN> | <finding #> | <priority> | Open / In Progress / Done |

## Approval

- [ ] Assessment report reviewed and approved by user
- [ ] Critical and High findings have generated Change Requests (if applicable)
```

## Acceptance Criteria

- All 16 questions have been answered (or skipped because the answer was available from existing project documents).
- The user has confirmed the summary before the document is generated.
- The correct document type is produced: `CHANGE_REQUEST.md` for features/modifications/refactors, `BUG_REPORT.md` for bug fixes, `ASSESSMENT_REPORT.md` for assessments.
- The document clearly states the **change type** and the **recommended workflow** (which skills to invoke next).
- The Diagnosis section of the bug report is filled before implementation begins.

## Cross-Platform Note

This skill operates through conversation and reading existing project files. It has no platform-specific behavior. It works identically on Copilot, OpenCode, Claude, Gemini, and any other AI platform.

## Cross-Pattern Note

The technology pattern and architecture style are read from the existing project's documents. This skill itself does not apply any pattern; pattern-specific behavior begins during Implementation, Testing, and Review.

## Relationship to Other Skills

- **`kickoff`** — Use for new projects. This skill is the counterpart for existing projects.
- **`analysis`** — May be invoked scoped to the change request for impact analysis, bug diagnosis, or in assessment mode for a full project audit.
- **`specification`** — Invoked for new features on existing projects to produce `SPEC_<Feature>.md`.
- **`design`** — Invoked only if the change modifies contracts or architecture.
- **`implementation`** — Always invoked after intake to apply the change.
- **`testing`** — Always invoked after implementation to validate the change.
- **`review`** — Always invoked after testing to validate compliance. For refactors, also invoked before implementation.
