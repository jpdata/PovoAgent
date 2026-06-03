---
name: planning
description: 'Produces a structured, schematized project plan from the Project Intake Document and Analysis Plan. Use after Kickoff and Analysis to generate a phased plan with Mermaid diagram, milestone table, and phase outputs before Design begins.'
---

# Planning Skill

## Objective

Transform the Project Intake Document (from Kickoff) and the Analysis Plan (from Analysis) into a structured **Project Plan Document** with a schematized lifecycle diagram, phased milestones, and clearly defined outputs per phase.

## When to Use

- After the Kickoff skill has produced the `PROJECT_INTAKE.md`.
- After the Analysis skill has produced the Analysis Plan.
- Before Design begins.

## Workflow

1. Read `PROJECT_INTAKE.md` (from Kickoff).
2. Read the Analysis Plan document (from Analysis).
3. Identify all phases applicable to the project.
4. Define milestones and expected outputs for each phase.
5. Assess scope and note any phases that may be skipped or abbreviated.
6. Generate the **Project Plan Document** including:
   - Mermaid lifecycle diagram
   - Phase table with inputs, outputs, owner skill/agent, and acceptance gate
   - Milestone checklist
   - Risk summary inherited from intake
7. Present the plan to the user for review.
8. Apply corrections if requested, then finalize the document.

## Inputs

- `PROJECT_INTAKE.md` — project identity, scope, technology, and risks.
- Analysis Plan document — confirmed requirements, use cases, and layer boundaries.

## Outputs

- **Project Plan Document** (`PROJECT_PLAN.md`) containing:
  - Project summary
  - Complete lifecycle diagram (Mermaid)
  - Phase table
  - Milestone checklist
  - Risk register (from intake)
  - Technology stack summary
  - Approval gate

## Project Plan Document Structure

````markdown
# Project Plan

## Summary

| Field | Value |
|---|---|
| Project | <name> |
| Goal | <main goal> |
| Pattern | <technology pattern> |
| Platform | <AI platform> |
| Team | <team size> |
| Target | <deadline or window> |

## Lifecycle

```mermaid
flowchart LR
    KO([Kickoff]) --> PL([Planning])
    PL --> AN([Analysis])
    AN --> DE([Design])
    DE --> SC([Scaffold])
    SC --> IM([Implementation])
    IM --> TE([Testing])
    TE --> RE([Review])

    style KO fill:#4a90d9,color:#fff
    style PL fill:#4a90d9,color:#fff
    style AN fill:#7b68ee,color:#fff
    style DE fill:#7b68ee,color:#fff
    style SC fill:#50c878,color:#fff
    style IM fill:#50c878,color:#fff
    style TE fill:#f4a460,color:#fff
    style RE fill:#f4a460,color:#fff
```

## Phase Table

| # | Phase | Skill / Agent | Inputs | Outputs | Gate |
|---|---|---|---|---|---|
| 1 | Kickoff | `kickoff` | User conversation | `PROJECT_INTAKE.md` | User confirms intake |
| 2 | Planning | `planning` | Intake + Analysis Plan | `PROJECT_PLAN.md` | User approves plan |
| 3 | Analysis | `analysis` | Intake doc | Analysis Plan | Plan reviewed |
| 4 | Design | `design` + Architect agent | Analysis Plan | Architecture + API docs | Design approved |
| 5 | Scaffold | `<pattern>-scaffold` | Design docs | Initialized project structure | Structure compiles |
| 6 | Implementation | `implementation` + `<pattern>-feature` | Design docs | Working decoupled code | All features pass |
| 7 | Testing | `testing` + `<pattern>-testing` | Code + Design docs | Test suite + Reports | Coverage met |
| 8 | Review | `review` + Reviewer agent | Code + Conventions | Review Report | No blocking items |

## Milestones

- [ ] **M1 — Kickoff complete:** `PROJECT_INTAKE.md` confirmed by user.
- [ ] **M2 — Plan approved:** `PROJECT_PLAN.md` confirmed by user.
- [ ] **M3 — Analysis complete:** Analysis Plan reviewed and approved.
- [ ] **M4 — Design approved:** Architecture and API contracts approved.
- [ ] **M5 — Scaffold complete:** Project compiles with correct layer structure.
- [ ] **M6 — Implementation complete:** All core features implemented and decoupled.
- [ ] **M7 — Tests passing:** All unit and integration tests pass; coverage met.
- [ ] **M8 — Review approved:** No blocking violations remain.

## Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| <risk from intake> | High / Medium / Low | <mitigation> |

## Technology Stack

| Layer | Technology |
|---|---|
| Pattern | <flutter / react / angular / dotnet / astro> |
| AI Platform | <copilot / opencode / claude / gemini> |
| Integrations | <list> |

## Approval

- [ ] Project Plan confirmed by user
````

## Phase Applicability Rules

When generating the plan, assess which phases apply:

| Condition | Adjustment |
|---|---|
| Project has existing codebase | Mark Analysis and Design as "review and update" rather than "create from scratch" |
| No backend required | Note Infrastructure layer as minimal; skip or abbreviate API contract design |
| Single-developer project | Architect and Reviewer sub-agents still run but review steps may be abbreviated |
| Pattern is "other" (non-standard) | Note in plan that pattern-specific skills (scaffold, feature, testing) must be created or adapted manually |

## Acceptance Criteria

- The Mermaid diagram renders all 8 phases correctly.
- The phase table has no empty cells for active (non-skipped) phases.
- All milestones are listed and unchecked at plan creation.
- The risk register contains at least the risks identified in the intake.
- The user has confirmed the plan before Design begins.
- `PROJECT_PLAN.md` is created at the root of the project.

## Cross-Platform Note

This skill generates Markdown with Mermaid diagrams. Mermaid renders natively in VS Code (Copilot), OpenCode, and most modern Markdown viewers. No platform-specific adaptation is required.

## Cross-Pattern Note

The Phase Table references the active pattern's scaffold, feature, and testing skills using the placeholder `<pattern>`. When generating the document, replace `<pattern>` with the actual pattern name (e.g., `flutter-scaffold`, `react-feature`, `dotnet-testing`).
