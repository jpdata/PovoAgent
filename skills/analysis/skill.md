---
name: analysis
description: 'Manages requirements gathering, use case analysis, user flows, dependencies, and risk identification for new projects. Also performs holistic assessments of existing projects to identify architectural, technical, and flow improvements. Use when starting a new project, defining scope, creating an analysis plan, or auditing an existing project for improvements. Ensures boundaries are clearly defined — either horizontal layers (Clean Architecture) or vertical feature slices (Vertical Slice Architecture) — according to the architecture style.'
---
# Analysis Skill

## Modes

This skill operates in two modes, selected based on the entry point:

1. **New Project Analysis** — When invoked from `kickoff` (new project lifecycle). Performs requirements gathering, use case analysis, user flows, dependencies, and risk identification. Produces an Analysis Plan document.
2. **Existing Project Assessment** — When invoked from `change-intake` (evolutionary lifecycle, Assessment type). Performs a systematic audit of an existing project across architecture, technical, and flow dimensions. Produces an Assessment Report with prioritized recommendations.

## Mode 1 — New Project Analysis

### Objective
Manage requirements gathering, use case analysis, user flows, dependencies, and risk identification.

### Workflow
1. Gather user requirements (functional and non-functional).
2. Identify and document main use cases.
3. Map user flows for each use case.
4. Identify dependencies and boundaries according to the architecture style:
   - **Clean Architecture:** identify dependencies between horizontal layers (Presentation, Application, Domain, Infrastructure).
   - **Vertical Slice Architecture:** identify dependencies between feature slices (each slice owns its full vertical stack; cross-slice dependencies must be explicit).
5. Assess risks and document mitigation strategies.
6. Produce the Analysis Plan document.

## Mode 1 Inputs
- `PROJECT_INTAKE.md` — project identity, scope, technology stack, and **architecture style** (Clean Architecture or Vertical Slice Architecture).
- User requirements (text, conversation, or brief).
- Existing project context (if any).

## Mode 1 Outputs
- **Analysis Plan Document** containing:
  - Analysis objectives
  - Functional and non-functional requirements
  - Main use cases
  - User flows
  - **Architecture style** (from PROJECT_INTAKE.md)
  - **Boundaries:**
    - Clean Architecture: layer boundaries (Presentation, Application, Domain, Infrastructure)
    - Vertical Slice Architecture: feature slice boundaries (each slice identified with its own full-stack scope)
  - Risk identification and mitigation
  - Dependencies

## Mode 1 Acceptance Criteria
- All user requirements are captured and categorized.
- Use cases cover all main user interactions.
- Boundaries are explicitly defined: horizontal layers for Clean Architecture, vertical feature slices for Vertical Slice Architecture.
- Risks are identified with mitigation strategies.
- The document is reviewed and approved before moving to Design.

## Mode 2 — Existing Project Assessment

### Objective
Perform a holistic audit of an existing project to identify improvement opportunities across architecture, technical aspects, and flows. Produce a prioritized Assessment Report with concrete, actionable recommendations. Optionally generate individual Change Requests for high-priority findings.

### When to Use
- A user says "assess my project", "analyze my project for improvements", "audit the architecture", or similar.
- The `change-intake` skill routes an **Assessment** type change to this mode.
- There is an existing project with source code, configuration, and ideally some design documents.

### Mode 2 Workflow

#### Step 1 — Confirm Scope
1. Read the `ASSESSMENT_REPORT.md` intake stub (metadata section) produced by `change-intake`.
2. Confirm the assessment scope with the user:
   - **Full** — All three dimensions (Architecture, Technical, Flows).
   - **Architecture only** — SOLID, decoupling, design patterns, folder structure.
   - **Technical only** — Performance, security, maintainability, dependencies, technical debt.
   - **Flows only** — User flows, data flows, API contracts, cross-slice communication.

#### Step 2 — Gather Context
1. Read available project documents: `PROJECT_INTAKE.md`, `PROJECT_PLAN.md`, `SPEC_*.md`, Design Document.
2. Read the active pattern's `conventions.md` for technology-specific standards.
3. Identify the **architecture style** (Clean Architecture or Vertical Slice Architecture) from project documents.

#### Step 3 — Architecture Assessment
Review the codebase for architecture compliance:

**For Clean Architecture:**
- Layer boundaries: Does Presentation reference Infrastructure directly? Does Domain have framework imports?
- SOLID compliance: Check each principle per class/module.
- Decoupling: Are all cross-layer dependencies through interfaces?
- Design patterns: Are Repository, DI, Use Case patterns applied correctly?
- Folder structure: Does it match the conventions?

**For Vertical Slice Architecture:**
- Slice boundaries: Does any slice import another slice's internal implementation?
- Slice completeness: Does each slice own its full vertical stack?
- Cross-slice contracts: Is communication through defined contracts only?
- SOLID adapted for VSA: Single-responsibility per slice, open for extension via new slices.
- Folder structure: Does it match the conventions?

Output: Architecture findings table (severity, category, finding, recommendation).

#### Step 4 — Technical Assessment
Review the codebase for technical health:

- **Performance:** Inefficient queries, missing caching, N+1 problems, large payloads, blocking operations.
- **Security:** Input validation gaps, missing authentication checks, exposed secrets, insecure dependencies.
- **Maintainability:** Code duplication, magic numbers, excessively long methods/files, complex conditionals.
- **Dependencies:** Outdated packages, unused dependencies, version conflicts, transitive dependency risk.
- **Technical Debt:** TODO/FIXME comments, commented-out code, inconsistent patterns, missing error handling.

Output: Technical findings table (severity, category, finding, recommendation).

#### Step 5 — Flow Assessment
Review the codebase for flow and process issues:

- **User Flows:** Are user journeys complete? Are edge cases handled? Is error feedback clear?
- **Data Flows:** Are transformations correct? Are there data consistency risks? Is validation complete?
- **API Contracts:** Are contracts stable and versioned? Are error responses consistent? Is documentation accurate?
- **Cross-Slice Communication (VSA):** Are events or mediator calls correctly routed? Are there missing handlers?
- **Process Optimization:** Are there redundant steps? Can flows be simplified?

Output: Flow findings table (severity, category, finding, recommendation).

#### Step 6 — Prioritize and Produce Report
1. Assign severity to each finding:
   - **Critical** — Security vulnerability, data loss risk, or architecture violation that blocks releases.
   - **High** — Significant technical debt, performance bottleneck, or SOLID violation that affects multiple features.
   - **Medium** — Code quality issue, missing pattern, or convention violation with localized impact.
   - **Low** — Minor improvement, naming suggestion, or optional optimization.
2. Produce the full `ASSESSMENT_REPORT.md` filling in all sections.
3. Present the Executive Summary to the user for review.

#### Step 7 — Generate Change Requests (Optional)
1. For Critical and High findings, ask the user: "Should I generate Change Requests for these N findings?"
2. If confirmed, invoke `change-intake` for each selected finding to produce individual `CHANGE_REQUEST.md` documents.
3. Link each CR back to the Assessment Report in the **Generated Change Requests** table.
4. CRs follow the Feature workflow (Spec → Implementation → Testing → Review) or Modification workflow depending on whether they add new capability or modify existing behavior.

### Mode 2 Inputs
- Intake stub in `ASSESSMENT_REPORT.md` (metadata filled by `change-intake`).
- Existing project source code.
- Available project documents: `PROJECT_INTAKE.md`, `PROJECT_PLAN.md`, `SPEC_*.md`, Design Document.
- Active pattern's `conventions.md`.

### Mode 2 Outputs
- **Assessment Report Document** (`ASSESSMENT_REPORT.md`) containing:
  - Executive Summary
  - Architecture Findings (SOLID, decoupling, patterns, structure)
  - Technical Findings (performance, security, maintainability, dependencies, debt)
  - Flow Findings (user flows, data flows, API contracts, cross-slice)
  - Prioritized Recommendations (Critical / High / Medium / Low)
  - Generated Change Requests table (if applicable)

### Mode 2 Acceptance Criteria
- All three dimensions (or the scoped subset) have been systematically reviewed.
- Each finding includes a concrete recommendation.
- Severity classification is consistent and justified.
- The Executive Summary accurately reflects the project's health.
- The user has reviewed and approved the Assessment Report.
- Optional: Change Requests are generated for Critical and High findings and linked back to the report.

## Decoupling Rule

**For new projects (Mode 1):** The analysis must clearly identify boundaries appropriate to the architecture style:
- **Clean Architecture:** boundaries between Presentation, Application, Domain, and Infrastructure layers.
- **Vertical Slice Architecture:** boundaries between feature slices; each slice is autonomous and owns its full stack.

**For existing projects (Mode 2):** The assessment must validate that existing boundaries are respected:
- **Clean Architecture:** Verify no direct cross-layer dependencies exist. Identify any boundary breaches.
- **Vertical Slice Architecture:** Verify slices are autonomous. Identify any direct slice-to-slice implementation imports.

## Pattern Reference
For technology-specific analysis considerations (both modes), consult the active pattern's `conventions.md`.
