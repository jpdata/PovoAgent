# Project Instructions

## Project Context

This project uses the PovoAgent AI framework. It follows decoupled architecture principles with separation between presentation (UI), business logic, and backend. Refer to `conventions.md` for technology-specific rules and `povo` agent for the development lifecycle.

## Architecture Rules

- Frontend and backend must be fully decoupled. Communication only through defined APIs/contracts.
- Within the frontend, presentation (UI) must be decoupled from business logic and backend interaction.
- UI changes must not require modifications to business logic or backend communication.
- Apply MVVM or Clean Architecture patterns to enforce separation of concerns.

## SOLID Principles

All code must comply with SOLID:
- **Single Responsibility:** One class = one reason to change.
- **Open/Closed:** Extend via abstractions, don't modify existing code.
- **Liskov Substitution:** Implementations must be interchangeable through their interfaces.
- **Interface Segregation:** Small, focused interfaces. No unused dependencies.
- **Dependency Inversion:** Depend on abstractions, not concretions. DI for all cross-layer communication.

## Design Patterns

- **Required:** Repository, Dependency Injection, Use Case/Interactor.
- **Recommended (when applicable):** Factory, Strategy, Observer, Adapter, Facade, Builder.
- Do not force patterns where they add unnecessary complexity.

## Project Lifecycle

Every project follows these phases in strict order:

1. **Analysis** → Produces an Analysis Plan document.
2. **Design** → Produces Architecture & API design documents.
3. **Implementation** → Produces working decoupled code.
4. **Testing** → Produces test reports & decoupling validation.

Each phase must complete its outputs before the next phase begins.

## Coding Standards

### Separation of Concerns
- Domain layer: pure business logic, no framework dependencies.
- Application layer: orchestration, depends only on Domain.
- Infrastructure layer: external services, databases, APIs. Implements interfaces from Domain/Application.
- Presentation layer: UI only. Depends on Application, never on Infrastructure directly.

### General Rules
- All code must pass decoupling validation before merge.
- Every feature must include unit tests for business logic.
- All .md files and documentation must be written in English.
- User questions can be in any language; all responses must match the user's language.

## Skills

This project uses PovoAgent lifecycle and pattern skills. Invoke them with `@<skill-name>` or let the `povo` agent select the appropriate skill for each phase.

Available lifecycle skills: `analysis`, `design`, `implementation`, `testing`.

## Memory

All corrections, lessons learned, and reusable knowledge must be recorded in the project memory file (`AGENTS.md` or a dedicated memory section).
