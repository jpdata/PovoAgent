---
name: implementation
description: 'Develops decoupled code for frontend and backend using MVVM or Clean Architecture patterns. Use when implementing features, generating code, or setting up project structure to ensure separation of concerns and maintainability.'
---
# Implementation Skill

## Objective
Develop decoupled code for front and back, applying patterns such as MVVM or Clean Architecture.

## Workflow
1. Read all approved `SPEC_<Feature>.md` documents for the features being implemented.
2. Review the Design Document to confirm architecture, API contracts, and layer boundaries.
3. Set up project structure following decoupled architecture.
4. Implement data models and repository layer, tracing each to the spec's data model reference.
5. Implement business logic (use cases / services), covering every scenario in the relevant spec.
6. Implement API integration layer using contracts defined in the spec's API/contract reference.
7. Implement presentation layer (UI) independently, covering all state scenarios from the spec.
8. Wire layers together through dependency injection or service locators.
9. Verify that each layer compiles and works independently.
10. Confirm every spec acceptance criterion has a corresponding implementation path.

## Inputs
- **Specification Documents** (`SPEC_<Feature>.md`) — primary behavioral reference for all code written.
- **Design Document** (architecture, API contracts, data models) — structural reference.

## Outputs
- **Working decoupled code** with:
  - Folder structure reflecting layer separation
  - Business logic independent of UI framework
  - API integration layer with defined contracts
  - Presentation layer that can be swapped without touching logic
  - README or inline docs explaining the structure

## Tools
- As defined by the active technology pattern (see pattern's `conventions.md`)
- IDE: VS Code with Copilot
- State management as chosen in the Design phase
- Dependency injection as chosen in the Design phase

## Acceptance Criteria
- Code compiles without errors.
- Business logic has no direct UI dependencies.
- Presentation can be replaced without modifying business logic.
- API layer uses contracts/interfaces, not concrete implementations.
- Folder structure matches the Design Document.
- Every spec acceptance criterion has a traceable implementation path.
- SOLID principles are applied in every class and module.
- Required design patterns (Repository, DI, Use Case) are implemented correctly.

## SOLID at Implementation Level
- **S:** Each class has one responsibility. Use cases don't touch UI. Repositories don't contain business rules.
- **O:** New features extend existing abstractions, don't modify them. Use interfaces and inheritance wisely.
- **L:** All implementations are substitutable for their interfaces. Tests can swap any dependency.
- **I:** Interfaces are small and focused. Split large interfaces into role-specific ones.
- **D:** Constructors receive abstractions, never concrete classes. DI container wires everything at the composition root.

## Decoupling Rule
Presentation logic must reside in components separated from business logic and backend integration.

## Pattern Reference
For technology-specific implementation details (folder structure, packages, code patterns), consult the active pattern's skills and `conventions.md`.