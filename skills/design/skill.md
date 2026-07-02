---
name: design
description: 'Defines decoupled architecture, UI/UX proposals, data modeling, and API contracts. Use when designing a system, defining layers or slices, or creating architecture documents. Supports both Clean Architecture (horizontal layers) and Vertical Slice Architecture (feature-vertical organization) as chosen in the Analysis phase.'
---
# Design Skill

## Objective
Define decoupled architecture, UI/UX proposals, data modeling, and APIs, following the architecture style (Clean Architecture or Vertical Slice Architecture) selected in the Analysis Plan.

## Workflow

### Pre-Step — Read Project Cache
1. If `PROJECT_CACHE.md` exists in the project root, read it first to obtain the architecture map, file index, and domain map.
2. **If fresh** (≤ 30 days old): Use the cache as the primary source for architecture context — layer boundaries, cross-layer contracts, key directories. This avoids re-scanning the entire project.
3. **If stale** (> 30 days old): Note potential drift but continue using the cache. Inform the user:
   > "The project cache is stale. Consider re-assessing the project to refresh it."
4. **If absent**: Proceed without the cache. The agent will scan the project structure directly.

### Step 0 — Confirm Architecture Style
1. Read the Analysis Plan document to identify the architecture style. Cross-reference with the Architecture Map in `PROJECT_CACHE.md` if available.
2. If the style is not explicitly set, **ask the user** to choose:
   - **Clean Architecture** (CA) — horizontal layers.
   - **Vertical Slice Architecture** (VSA) — feature-vertical organization.
   - If the user does not know, use the diagnostic questions from the kickoff skill to help them decide.

### Clean Architecture Path
1. Review the Analysis Plan document.
2. Define the horizontal layers (Presentation, Application, Domain, Infrastructure) and their dependencies.
3. Design API contracts between layers.
4. Create data models per layer.
5. Propose UI/UX prototypes decoupled from logic.
6. Document decoupling strategies (MVVM, Clean Architecture, Repository, Use Case).
7. Produce the Design Document.

### Vertical Slice Architecture Path
1. Review the Analysis Plan document and identify feature slices.
2. For each slice, define its full vertical stack (endpoint/UI, handler/logic, data access, validation).
3. Define cross-slice contracts (events, shared kernel, or API contracts between slices).
4. Design data models per slice (each slice owns its data shape).
5. Propose UI/UX prototypes organized by feature slice.
6. Document slice boundaries and communication patterns (e.g., Mediator, event bus, direct service calls where appropriate).
7. Produce the Design Document.

## Inputs
- **Analysis Plan document** (from Analysis phase) — contains the architecture style and boundary definitions.
- `PROJECT_INTAKE.md` — for technology stack and project context.

## Outputs
- **Design Document** containing:
  - **Architecture style** (Clean Architecture or Vertical Slice Architecture)
  - Architecture diagram:
    - CA: layers and communication flow
    - VSA: slices and cross-slice communication
  - API contract definitions (CA: between layers; VSA: between slices or to external consumers)
  - Data models (CA: per layer; VSA: per slice)
  - UI/UX prototypes or wireframes (CA: decoupled from logic; VSA: organized by feature slice)
  - Decoupling strategy description
  - Technology stack decisions (as defined by the active pattern)

## Tools
- Diagramming (Mermaid, draw.io)
- Prototyping (Figma, Adobe XD)

## Acceptance Criteria

### Common to Both Architectures
- API contracts are defined for all interactions (between layers or between slices).
- UI prototypes can be changed without altering business logic.
- Data models are consistent with API contracts.
- Design patterns are selected and documented.
- Design is approved before moving to Specification (CA) or Implementation (VSA).

### Clean Architecture — Specific
- Architecture clearly separates Presentation, Application, Domain, and Infrastructure.
- SOLID principles are reflected in layer design (single-purpose layers, dependency inversion across boundaries, interface segregation for contracts).
- Required patterns: Repository, DI, Use Case at minimum.

### Vertical Slice Architecture — Specific
- Each feature slice is clearly defined with its own full-stack scope.
- Cross-slice dependencies are explicit and minimized.
- Each slice can be developed, tested, and deployed independently.
- Required patterns: Mediator or Handler per slice, CQRS where beneficial.

## SOLID at Design Level

### Clean Architecture
- Each layer has a single responsibility (S).
- Layer boundaries use abstractions/interfaces so implementations can be swapped (O, L).
- Contracts are granular — no "god interfaces" (I).
- High-level layers (Domain, Application) never depend on low-level layers (Infrastructure, Presentation) (D).

### Vertical Slice Architecture
- Each slice has a single responsibility — one feature or use case (S).
- New features add new slices; existing slices are not modified for unrelated behavior (O).
- Slices are substitutable — any slice can be replaced without affecting others (L).
- Slice contracts are narrow — a slice exposes only what other slices need (I).
- Slices depend on abstractions, not on other slices' concretions (D). Cross-slice communication goes through contracts.

## Decoupling Rule
- **Clean Architecture:** The UI must be changeable without affecting business logic or backend communication. Presentation depends on Application contracts, never on Infrastructure directly.
- **Vertical Slice Architecture:** Each slice must be independently changeable. Changing a slice's internal implementation must not force changes in other slices. Cross-slice contracts are the only allowed coupling surface.

## Pattern Reference
For technology-specific architecture conventions (folder structure, packages, state management options), consult the active pattern's `conventions.md`.