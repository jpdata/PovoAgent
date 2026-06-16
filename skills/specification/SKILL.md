---
name: specification
description: 'Transforms the Design Document into formal Specification Documents (SPEC_<feature>.md) for each feature, module, or contract. Use after Design and before Scaffold/Implementation. Each spec defines behavior through preconditions, postconditions, concrete scenarios, and verifiable acceptance criteria. Works with both Clean Architecture (specs organized by layer) and Vertical Slice Architecture (specs organized by slice). Specs are the primary input for Implementation and Testing.'
---

# Specification Skill

## Objective

Transform the Design Document into a set of formal **Specification Documents** — one per feature, module, or contract — that precisely define expected behavior through scenarios and verifiable acceptance criteria before any implementation begins.

## When to Use

- After the Design Document has been produced and approved.
- Before Scaffold or Implementation begins.
- When a new feature is added to an existing project that needs formal behavioral definition.

## Workflow

1. Read the Design Document to identify the architecture style (Clean Architecture or Vertical Slice Architecture).
2. Identify all features, use cases, and contracts that require a specification.
3. For each identified unit, write one Specification Document following the structure below.
   - **Clean Architecture:** each spec targets a specific layer (e.g., Domain entity, Application use case, Presentation component).
   - **Vertical Slice Architecture:** each spec covers a full vertical slice (endpoint → handler → data access).
4. Ensure every scenario is concrete: real inputs, real expected outputs, no vague language.
5. Ensure every acceptance criterion is verifiable by a test without ambiguity.
6. Cross-check specs against Design Document API contracts and data models for consistency.
7. Present the set of specs to the user for review.
8. Apply corrections, then finalize. No implementation starts until all specs are approved.

## Inputs

- **Design Document** — architecture style, API contracts, data models, layer or slice boundaries.
- **Analysis Plan** — use cases and user flows for behavioral coverage verification.

## Outputs

- One **Specification Document** per feature / module / contract:
  - File name: `SPEC_<FeatureName>.md`
  - Stored alongside the project's design artifacts or in a `specs/` folder as defined per project.

## Specification Document Structure

````markdown
# Specification: <Feature Name>

## Metadata
| Field | Value |
|---|---|
| ID | SPEC-<NNN> |
| Feature | <feature name> |
| Architecture | <Clean Architecture | Vertical Slice Architecture> |
| Layer / Slice | <Layer name for CA (e.g., Domain, Application) | Slice name for VSA (e.g., Orders, Products)> |
| Status | Draft / Approved |
| Author | <author> |
| Date | <date> |

## Description

One paragraph describing what this feature does, from the user's or system's perspective.

## Preconditions

- List of conditions that must be true before any scenario in this spec can execute.
- Example: User is authenticated. Cart contains at least one item.

## Postconditions

- List of observable state changes guaranteed after a successful scenario.
- Example: Order record exists in the database. Confirmation email is queued.

## Scenarios

### Scenario 1 — <Happy Path Name>

**Given:** <concrete initial state>
**When:** <concrete action or event>
**Then:** <concrete expected outcome>
**And:** <additional observable outcomes, if any>

### Scenario 2 — <Alternative / Edge Case Name>

**Given:** ...
**When:** ...
**Then:** ...

### Scenario 3 — <Error / Failure Case Name>

**Given:** ...
**When:** ...
**Then:** <error response or rollback behavior>

## Acceptance Criteria

- [ ] AC-01: <Criterion stated as a verifiable statement>
- [ ] AC-02: <Criterion stated as a verifiable statement>
- [ ] AC-03: <Criterion stated as a verifiable statement>

## API / Contract Reference

Links or inline definitions of the contracts this spec depends on (from the Design Document).

| Contract | Method / Event | Request Shape | Response Shape |
|---|---|---|---|
| <ContractName> | <GET /resource> | `{ field: type }` | `{ field: type }` |

## Data Model Reference

Relevant domain entities or DTOs as defined in the Design Document.

## Exclusions

Explicit list of behaviors this spec does NOT cover (to avoid scope creep during implementation).

## Open Questions

- List any unresolved decisions that must be answered before implementation starts.
````

## Specification Quality Rules

A spec is only ready for Implementation when it meets all of the following:

1. **Every scenario uses concrete values** — no "some data", no "valid input". Use real example values.
2. **Every acceptance criterion is binary** — it either passes or fails; no subjective judgment.
3. **No implementation detail** — specs describe *what*, not *how*. No code, no algorithm descriptions.
4. **Consistent with Design Document** — all referenced contracts and entities exist in the Design Document.
5. **Complete coverage** — every use case from the Analysis Plan has at least one scenario in some spec.
6. **No open questions remain** — all open questions are resolved before the spec is approved.

## Acceptance Criteria (for the Specification phase itself)

- All features identified in the Design Document have a corresponding SPEC file.
- Every SPEC file passes the six Specification Quality Rules above.
- The user has reviewed and approved all specs.
- No spec has remaining open questions.
- Specs are consistent with API contracts defined in the Design Document.

## Decoupling Rule

- **Clean Architecture:** Specifications are layer-aware but layer-neutral: a spec for a Domain entity must not reference UI components, and a spec for a Presentation component must not describe persistence logic. Each spec covers exactly one layer boundary.
- **Vertical Slice Architecture:** Each spec covers a complete vertical slice (UI contract → handler behavior → data access expectations). The spec describes the slice as a cohesive unit; internal slice structure is an implementation detail. Cross-slice references go through defined contracts only.

## Pattern Reference

For technology-specific scenario formatting, test-mapping conventions, or tooling (e.g., BDD runners, contract testing tools), consult the active pattern's `<platform>-spec` skill.
