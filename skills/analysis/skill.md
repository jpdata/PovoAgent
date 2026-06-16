---
name: analysis
description: 'Manages requirements gathering, use case analysis, user flows, dependencies, and risk identification. Use when starting a new project, defining scope, or creating an analysis plan. Ensures the analysis phase clearly defines boundaries — either horizontal layers (Clean Architecture) or vertical feature slices (Vertical Slice Architecture) — according to the architecture style chosen in kickoff.'
---
# Analysis Skill

## Objective
Manage requirements gathering, use case analysis, user flows, dependencies, and risk identification.

## Workflow
1. Gather user requirements (functional and non-functional).
2. Identify and document main use cases.
3. Map user flows for each use case.
4. Identify dependencies and boundaries according to the architecture style:
   - **Clean Architecture:** identify dependencies between horizontal layers (Presentation, Application, Domain, Infrastructure).
   - **Vertical Slice Architecture:** identify dependencies between feature slices (each slice owns its full vertical stack; cross-slice dependencies must be explicit).
5. Assess risks and document mitigation strategies.
6. Produce the Analysis Plan document.

## Inputs
- `PROJECT_INTAKE.md` — project identity, scope, technology stack, and **architecture style** (Clean Architecture or Vertical Slice Architecture).
- User requirements (text, conversation, or brief).
- Existing project context (if any).

## Outputs
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

## Acceptance Criteria
- All user requirements are captured and categorized.
- Use cases cover all main user interactions.
- Boundaries are explicitly defined: horizontal layers for Clean Architecture, vertical feature slices for Vertical Slice Architecture.
- Risks are identified with mitigation strategies.
- The document is reviewed and approved before moving to Design.

## Decoupling Rule
The analysis must clearly identify boundaries appropriate to the architecture style:
- **Clean Architecture:** boundaries between Presentation, Application, Domain, and Infrastructure layers.
- **Vertical Slice Architecture:** boundaries between feature slices; each slice is autonomous and owns its full stack.

## Pattern Reference
For technology-specific analysis considerations, consult the active pattern's `conventions.md`.
