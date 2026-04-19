---
title: Implementation Skill
description: Develops decoupled code for frontend and backend using MVVM or Clean Architecture patterns to ensure separation of concerns and maintainability.
name: implementation
mutable: false
---
# Implementation Skill

## Objective
Develop decoupled code for front and back, applying patterns such as MVVM or Clean Architecture.

## Workflow
1. Review the Design Document.
2. Set up project structure following decoupled architecture.
3. Implement data models and repository layer.
4. Implement business logic (use cases / services).
5. Implement API integration layer.
6. Implement presentation layer (UI) independently.
7. Wire layers together through dependency injection or service locators.
8. Verify that each layer compiles and works independently.

## Inputs
- Design Document (architecture, API contracts, data models).

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