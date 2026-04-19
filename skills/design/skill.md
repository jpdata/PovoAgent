---
name: design
description: 'Defines decoupled architecture, UI/UX proposals, data modeling, and API contracts. Use when designing a system, defining layers, or creating architecture documents. Ensures the presentation layer is independent of business logic and backend.'
---
# Design Skill

## Objective
Define decoupled architecture, UI/UX proposals, data modeling, and APIs.

## Workflow
1. Review the Analysis Plan document.
2. Define the general architecture (presentation, business logic, backend layers).
3. Design API contracts between layers.
4. Create data models.
5. Propose UI/UX prototypes decoupled from logic.
6. Document decoupling strategies (e.g., MVVM, Clean Architecture).
7. Produce the Design Document.

## Inputs
- Analysis Plan document (from Analysis phase).

## Outputs
- **Design Document** containing:
  - Architecture diagram (layers and communication)
  - API contract definitions
  - Data models
  - UI/UX prototypes or wireframes
  - Decoupling strategy description
  - Technology stack decisions (as defined by the active pattern)

## Tools
- Diagramming (Mermaid, draw.io)
- Prototyping (Figma, Adobe XD)

## Acceptance Criteria
- Architecture clearly separates presentation, business logic, and backend.
- API contracts are defined for all layer interactions.
- UI prototypes can be changed without altering business logic.
- Data models are consistent with API contracts.
- SOLID principles are reflected in the architecture (single-purpose layers, dependency inversion across boundaries, interface segregation for contracts).
- Design patterns are selected and documented (Repository, DI, Use Case at minimum; others as needed).
- Design is approved before moving to Implementation.

## SOLID at Design Level
- Each layer has a single responsibility (S).
- Layer boundaries use abstractions/interfaces so implementations can be swapped (O, L).
- Contracts are granular — no "god interfaces" (I).
- High-level layers (Domain, Application) never depend on low-level layers (Infrastructure, Presentation) (D).

## Decoupling Rule
The UI must be changeable without affecting business logic or backend communication.

## Pattern Reference
For technology-specific architecture conventions (folder structure, packages, state management options), consult the active pattern's `conventions.md`.