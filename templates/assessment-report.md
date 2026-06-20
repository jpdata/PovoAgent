# Assessment Report

> Template for reporting the results of a holistic project assessment: architecture, technical, and flow analysis.
> Fill the Metadata section during `change-intake`. Fill the remainder during the `analysis` (Assessment Mode) phase.

## Metadata

| Field | Value |
|---|---|
| ID | ASMT-<NNN> |
| Project | <project name> |
| Type | Assessment |
| Scope | Full / Architecture Only / Technical Only / Flows Only |
| Architecture | Clean Architecture / Vertical Slice Architecture |
| Pattern | <technology pattern> |
| Platform | <AI platform> |
| Author | <author> |
| Date | <date> |

## Executive Summary

<One-paragraph summary of the project's current health, key strengths, critical issues found, and overall recommendation. This is the most important section — it should give a decision-maker everything they need to know at a glance.>

### Health Summary

| Dimension | Rating (1–5) | Summary |
|---|---|---|
| Architecture | <1–5> | <one-line summary> |
| Technical | <1–5> | <one-line summary> |
| Flows | <1–5> | <one-line summary> |
| **Overall** | **<1–5>** | **<one-line summary>** |

### Key Findings at a Glance

| Severity | Count |
|---|---|
| Critical | <N> |
| High | <N> |
| Medium | <N> |
| Low | <N> |

## Scope

| Aspect | Detail |
|---|---|
| Assessment Type | <Full / Architecture / Technical / Flows> |
| Features Analyzed | <list of feature names> |
| Layers Analyzed (CA) | <Presentation / Application / Domain / Infrastructure> |
| Slices Analyzed (VSA) | <list of slice names> |
| Files Reviewed | <N files across M directories> |
| Documents Consulted | <list of PROJECT_INTAKE.md, SPEC_*.md, Design Doc, etc.> |

## Architecture Findings

> _Issues with SOLID principles, layer/slice boundaries, decoupling, design patterns, and folder structure._

| # | Severity | Category | Location | Finding | Recommendation |
|---|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <SOLID / Decoupling / Patterns / Structure / Conventions> | `<file>:<line>` | <description of the issue> | <concrete, actionable fix> |
| 2 | ... | ... | ... | ... | ... |

### Architecture Strengths

<What architectural choices are working well. What patterns are correctly applied. What deserves recognition.>

## Technical Findings

> _Issues with performance, security, maintainability, dependencies, and technical debt._

| # | Severity | Category | Location | Finding | Recommendation |
|---|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <Performance / Security / Maintainability / Dependencies / Debt> | `<file>:<line>` | <description of the issue> | <concrete, actionable fix> |
| 2 | ... | ... | ... | ... | ... |

### Technical Strengths

<What technical aspects are well-handled. Good practices already in place.>

## Flow Findings

> _Issues with user flows, data flows, API contracts, cross-slice communication, and process optimization._

| # | Severity | Category | Location | Finding | Recommendation |
|---|---|---|---|---|---|
| 1 | <Critical / High / Medium / Low> | <User Flow / Data Flow / API Contract / Cross-Slice / Process> | `<file>:<line>` | <description of the issue> | <concrete, actionable fix> |
| 2 | ... | ... | ... | ... | ... |

### Flow Strengths

<What flows work well. Well-designed user journeys or data pipelines.>

## Prioritized Recommendations

### Critical

> _Must fix now. Security vulnerabilities, data loss risks, or architecture violations that block releases._

| Finding # | Recommendation | Linked CR | Effort Estimate | Impact |
|---|---|---|---|---|
| <#> | <recommendation> | CR-<NNN> | <S / M / L / XL> | <what improves> |

### High

> _Should fix in the current cycle. Significant technical debt, performance bottlenecks, or SOLID violations affecting multiple features._

| Finding # | Recommendation | Linked CR | Effort Estimate | Impact |
|---|---|---|---|---|
| <#> | <recommendation> | CR-<NNN> | <S / M / L / XL> | <what improves> |

### Medium

> _Plan for next cycle. Code quality issues, missing patterns, or convention violations with localized impact._

| Finding # | Recommendation | Linked CR | Effort Estimate | Impact |
|---|---|---|---|---|
| <#> | <recommendation> | — | <S / M / L / XL> | <what improves> |

### Low

> _Nice to have; no urgency. Minor improvements, naming suggestions, or optional optimizations._

| Finding # | Recommendation | Effort Estimate |
|---|---|---|
| <#> | <recommendation> | <S / M / L / XL> |

## Generated Change Requests

> _Individual Change Requests created from Critical and High findings._

| CR ID | Finding # | Severity | Title | Status |
|---|---|---|---|---|
| CR-<NNN> | <#> | <Critical / High> | <short title> | Open / In Progress / Done |
| CR-<NNN> | <#> | <Critical / High> | <short title> | Open / In Progress / Done |

## Workflow

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | Intake | `change-intake` (Assessment) | Metadata stub filled |
| 2 | Assessment | `analysis` (Assessment Mode) | `ASSESSMENT_REPORT.md` with findings |
| 3 | Validation | `review` + Reviewer agent | Findings validated against conventions |
| 4 | CR Generation | `change-intake` (per finding) | Individual `CHANGE_REQUEST.md` per finding (optional) |

## Approval

- [ ] Assessment scope confirmed with user
- [ ] Assessment Report reviewed and approved by user
- [ ] Critical and High findings have generated Change Requests (if applicable)
- [ ] Linked CRs tracked in the Generated Change Requests table
