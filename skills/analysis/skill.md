---
title: Analysis Skill
description: Manages requirements gathering, use case analysis, user flows, dependencies, and risk identification. Ensures the analysis phase clearly defines boundaries between presentation, business logic, and backend.
name: analysis
mutable: false
---
# Analysis Skill

## Objective
Manage requirements gathering, use case analysis, user flows, dependencies, and risk identification.

## Workflow
1. Gather user requirements (functional and non-functional).
2. Identify and document main use cases.
3. Map user flows for each use case.
4. Identify dependencies between presentation, business logic, and backend.
5. Assess risks and document mitigation strategies.
6. Produce the Analysis Plan document.

## Inputs
- User requirements (text, conversation, or brief).
- Existing project context (if any).

## Outputs
- **Analysis Plan Document** containing:
  - Analysis objectives
  - Functional and non-functional requirements
  - Main use cases
  - User flows
  - Layer boundaries (presentation, business logic, backend)
  - Risk identification and mitigation
  - Dependencies

## Acceptance Criteria
- All user requirements are captured and categorized.
- Use cases cover all main user interactions.
- Layer boundaries are explicitly defined.
- Risks are identified with mitigation strategies.
- The document is reviewed and approved before moving to Design.

## Decoupling Rule
The analysis must clearly identify the boundaries between presentation, business logic, and backend.

## Pattern Reference
For technology-specific analysis considerations, consult the active pattern's `conventions.md`.
