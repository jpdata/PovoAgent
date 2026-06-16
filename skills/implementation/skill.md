---
name: implementation
description: 'Develops decoupled code for frontend and backend using Clean Architecture (horizontal layers) or Vertical Slice Architecture (feature-vertical organization) as chosen in the Design phase. Use when implementing features, generating code, or setting up project structure to ensure separation of concerns and maintainability.'
---
# Implementation Skill

## Objective
Develop decoupled code for front and back, applying patterns such as MVVM or Clean Architecture.

## Workflow

### Step 0 — Confirm Architecture Style
Read the Design Document to identify whether the project uses Clean Architecture or Vertical Slice Architecture. All subsequent steps follow the relevant path below.

### Clean Architecture Path
1. Read all approved `SPEC_<Feature>.md` documents for the features being implemented.
2. Review the Design Document to confirm architecture, API contracts, and layer boundaries.
3. Set up project structure following horizontal layers (Domain → Application → Infrastructure → Presentation).
4. Implement data models and repository layer, tracing each to the spec's data model reference.
5. Implement business logic (use cases / services), covering every scenario in the relevant spec.
6. Implement API integration layer using contracts defined in the spec's API/contract reference.
7. Implement presentation layer (UI) independently, covering all state scenarios from the spec.
8. Wire layers together through dependency injection or service locators.
9. Verify that each layer compiles and works independently.
10. Confirm every spec acceptance criterion has a corresponding implementation path.

### Vertical Slice Architecture Path
1. Read all approved `SPEC_<Feature>.md` documents — each spec covers a full vertical slice.
2. Review the Design Document for slice boundaries, cross-slice contracts, and data models per slice.
3. For each feature slice, create the full vertical stack in one location:
   - Endpoint / UI handler
   - Request/response DTOs and validation
   - Handler / use case logic
   - Data access (repository or direct query)
4. Implement cross-slice communication through defined contracts (Mediator, event bus, or direct service calls).
5. Verify each slice works independently before testing cross-slice flows.
6. Confirm every spec acceptance criterion has a corresponding implementation path within its slice.

## Inputs
- **Specification Documents** (`SPEC_<Feature>.md`) — primary behavioral reference for all code written.
- **Design Document** (architecture, API contracts, data models) — structural reference.

## Outputs
- **Working decoupled code** with:
  - **Clean Architecture:** Folder structure reflecting horizontal layers. Business logic independent of UI framework. API integration layer with defined contracts. Presentation layer swappable without touching logic.
  - **Vertical Slice Architecture:** Folder structure reflecting feature slices. Each slice contains its full vertical stack. Cross-slice dependencies explicit through contracts.
  - README or inline docs explaining the structure.

## Tools
- As defined by the active technology pattern (see pattern's `conventions.md`)
- IDE: VS Code with Copilot
- State management as chosen in the Design phase
- Dependency injection as chosen in the Design phase

## Acceptance Criteria

### Common
- Code compiles without errors.
- Every spec acceptance criterion has a traceable implementation path.
- Required design patterns are implemented correctly.

### Clean Architecture — Specific
- Business logic has no direct UI dependencies.
- Presentation can be replaced without modifying business logic.
- API layer uses contracts/interfaces, not concrete implementations.
- Folder structure matches horizontal layers in the Design Document.
- SOLID principles are applied in every class and module.
- Required patterns (Repository, DI, Use Case) are implemented correctly.

### Vertical Slice Architecture — Specific
- Each slice is self-contained with its full vertical stack.
- Cross-slice dependencies go through defined contracts only.
- No slice directly imports another slice's internal implementation.
- Each slice can be tested independently.
- Each slice's handler/use case has no dependency on other slices' internals.

## SOLID at Implementation Level

### Clean Architecture
- **S:** Each class has one responsibility. Use cases don't touch UI. Repositories don't contain business rules.
- **O:** New features extend existing abstractions, don't modify them.
- **L:** All implementations are substitutable for their interfaces.
- **I:** Interfaces are small and focused. Split large interfaces into role-specific ones.
- **D:** Constructors receive abstractions, never concrete classes. DI container wires everything at the composition root.

### Vertical Slice Architecture
- **S:** Each slice handles one feature or use case. A slice's handler doesn't also manage unrelated concerns.
- **O:** New features add new slices. Existing slices are not modified for unrelated behavior.
- **L:** Slices exposing the same contract are interchangeable.
- **I:** Cross-slice contracts are narrow — a slice exposes only what other slices need.
- **D:** Slices depend on abstractions (contracts), not on other slices' concretions.

## Decoupling Rule
Presentation logic must reside in components separated from business logic and backend integration.

## Pattern Reference
For technology-specific implementation details (folder structure, packages, code patterns), consult the active pattern's skills and `conventions.md`.