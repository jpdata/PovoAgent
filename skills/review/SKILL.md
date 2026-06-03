---
name: review
description: 'Performs a structured code review validating SOLID compliance, decoupling between layers, naming conventions, and design pattern correctness. Use after implementation or testing to produce a formal review report before merging or releasing.'
---
# Review Skill

## Objective
Perform a structured code review that validates architecture compliance, SOLID principles, decoupling rules, and coding conventions as defined in the active pattern.

## Workflow
1. Read the Design Document and `conventions.md` for the active pattern.
2. Inspect the implementation code layer by layer (Domain → Application → Infrastructure → Presentation).
3. Validate SOLID compliance in every class and module reviewed.
4. Validate decoupling: confirm no cross-layer direct dependencies exist.
5. Validate naming conventions, folder structure, and file organization.
6. Validate correct application of required design patterns (Repository, DI, Use Case).
7. Identify violations, classify them by severity (blocking / warning / suggestion).
8. Produce the Review Report.

## Inputs
- Implementation code (all layers).
- Design Document (architecture, API contracts, layer boundaries).
- `conventions.md` from the active pattern.

## Outputs
- **Review Report** containing:
  - Summary of reviewed files and scope
  - SOLID violations (per principle, per class)
  - Decoupling violations (layer boundary breaches)
  - Convention violations (naming, structure, patterns)
  - Severity classification: `blocking` | `warning` | `suggestion`
  - Required fixes before approval (blocking items only)
  - Recommended improvements (warnings and suggestions)

## Severity Definitions
- **blocking** — Must be fixed before the feature can be considered complete. Examples: business logic inside UI, missing interface abstraction on cross-layer dependency, broken DI wiring.
- **warning** — Should be fixed; represents technical debt or a fragile design. Examples: class with more than one responsibility, unused interface methods.
- **suggestion** — Improvement opportunity with no immediate risk. Examples: rename for clarity, extract helper, add inline comment.

## Acceptance Criteria
- No blocking violations remain unresolved.
- All layer boundaries are confirmed clean.
- Required design patterns are applied correctly.
- Naming and folder structure match `conventions.md`.
- The Review Report is produced and shared with the team.

## SOLID Checklist
- **S:** Each class has exactly one reason to change.
- **O:** New behavior added via extension (new class/interface), not by modifying existing code.
- **L:** Every implementation can replace its interface without changing caller behavior.
- **I:** No class is forced to depend on methods it does not use.
- **D:** High-level modules depend on abstractions; Infrastructure implements, Domain defines.

## Decoupling Checklist
- Presentation layer has no direct reference to Infrastructure.
- Domain layer has no framework imports.
- Application layer orchestrates through interfaces only.
- All cross-layer communication goes through defined contracts.

## Pattern Reference
For technology-specific review criteria (framework idioms, pattern naming, file conventions), consult the active pattern's `conventions.md` and the `reviewer` sub-agent.
