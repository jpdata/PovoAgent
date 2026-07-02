---
name: review
description: 'Performs a structured code review validating compliance with the chosen architecture style (Clean Architecture or Vertical Slice Architecture), SOLID compliance, decoupling between layers or slices, naming conventions, and design pattern correctness. Use after implementation or testing to produce a formal review report before merging or releasing.'
---
# Review Skill

## Objective
Perform a structured code review that validates architecture compliance, SOLID principles, decoupling rules, and coding conventions as defined in the active pattern.

## Workflow

### Pre-Step — Read Project Cache
1. If `PROJECT_CACHE.md` exists, read it to understand the project's architecture, layer/slice boundaries, and key files — this focuses the review on the correct structure.
2. **If fresh**: Use the Architecture Map to validate that the implementation matches the documented structure. Use the Symbol Index to verify contracts and interfaces are respected.
3. **If stale or absent**: Proceed without it; review against the Design Document and conventions only.

### Step 0 — Confirm Architecture Style
Read the Design Document to identify whether the project uses Clean Architecture or Vertical Slice Architecture. All review criteria follow the relevant path below.

### Common Steps
1. Read all approved `SPEC_<Feature>.md` documents for the scope being reviewed.
2. Read the Design Document and `conventions.md` for the active pattern.
3. Validate **spec conformance**: confirm every AC in every spec is covered by at least one test and one implementation path. Flag missing coverage as `blocking`.
4. Validate correct application of required design patterns.
5. Identify violations, classify them by severity (blocking / warning / suggestion).
6. Produce the Review Report.

### Clean Architecture — Specific Review Steps
- Inspect the implementation code layer by layer (Domain → Application → Infrastructure → Presentation).
- Validate SOLID compliance in every class and module reviewed.
- Validate decoupling: confirm no cross-layer direct dependencies exist (Presentation → Infrastructure, Domain → framework, etc.).
- Validate naming conventions, folder structure, and file organization match horizontal layers.

### Vertical Slice Architecture — Specific Review Steps
- Inspect the implementation code slice by slice.
- For each slice, validate that it contains its full vertical stack (endpoint, handler, validation, data access).
- Validate that no slice directly imports another slice's internal implementation.
- Validate that all cross-slice communication goes through defined contracts only.
- Validate SOLID principles adapted for VSA (single-responsibility per slice, open for extension via new slices, etc.).

## Inputs
- **Specification Documents** (`SPEC_<Feature>.md`) — primary behavioral reference for conformance validation.
- **Implementation code** (all layers).
- **Design Document** (architecture, API contracts, layer boundaries).
- **`conventions.md`** from the active pattern.

## Outputs
- **Review Report** containing:
  - Summary of reviewed files, scope, and specs covered
  - **Spec conformance summary**: which ACs pass, which are missing implementation or test coverage
  - SOLID violations (per principle, per class)
  - Decoupling violations (layer boundary breaches)
  - Convention violations (naming, structure, patterns)
  - Severity classification: `blocking` | `warning` | `suggestion`
  - Required fixes before approval (blocking items only)
  - Recommended improvements (warnings and suggestions)

## Severity Definitions
- **blocking** — Must be fixed before the feature can be considered complete. Examples: business logic inside UI, missing interface abstraction on cross-layer dependency, broken DI wiring, spec AC with no test coverage, spec scenario with no implementation path.
- **warning** — Should be fixed; represents technical debt or a fragile design. Examples: class with more than one responsibility, unused interface methods.
- **suggestion** — Improvement opportunity with no immediate risk. Examples: rename for clarity, extract helper, add inline comment.

## Acceptance Criteria
- All spec acceptance criteria are covered by implementation and tests (no missing coverage).
- No blocking violations remain unresolved.
- All layer boundaries are confirmed clean.
- Required design patterns are applied correctly.
- Naming and folder structure match `conventions.md`.
- The Review Report is produced and shared with the team.

## SOLID Checklist

### Clean Architecture
- **S:** Each class has exactly one reason to change.
- **O:** New behavior added via extension (new class/interface), not by modifying existing code.
- **L:** Every implementation can replace its interface without changing caller behavior.
- **I:** No class is forced to depend on methods it does not use.
- **D:** High-level modules depend on abstractions; Infrastructure implements, Domain defines.

### Vertical Slice Architecture
- **S:** Each slice handles exactly one feature or use case. A slice's handler has one reason to change.
- **O:** New features add new slices. Existing slices are not modified for unrelated features.
- **L:** Slices implementing the same contract are interchangeable without affecting consumers.
- **I:** Cross-slice contracts are narrow. No slice exposes methods that no other slice consumes.
- **D:** Slices depend on contract abstractions, not on other slices' concrete implementations.

## Decoupling Checklist

### Clean Architecture
- Presentation layer has no direct reference to Infrastructure.
- Domain layer has no framework imports.
- Application layer orchestrates through interfaces only.
- All cross-layer communication goes through defined contracts.

### Vertical Slice Architecture
- No slice directly imports another slice's handler or internal implementation.
- All cross-slice communication goes through contracts (Mediator, event bus, or defined service interfaces).
- Each slice can be compiled and tested in isolation.
- Shared kernel (if any) is explicit and contains only cross-cutting types, not business logic.

## Pattern Reference
For technology-specific review criteria (framework idioms, pattern naming, file conventions), consult the active pattern's `conventions.md` and the `reviewer` sub-agent.
