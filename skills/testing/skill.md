---
title: Testing Skill
description: Generates and executes test plans for each application layer, validating that presentation, business logic, and backend are properly decoupled and functional.
name: testing
mutable: false
---
# Testing Skill

## Objective
Generate and execute test plans for each layer: presentation, business logic, and backend.

## Workflow
1. Review Design Document and Implementation code.
2. Create test plan covering all layers.
3. Write unit tests for business logic (no UI dependencies).
4. Write unit tests for presentation (mocked business logic).
5. Write integration tests for API layer.
6. Run decoupling validation: swap UI components and verify business logic still passes.
7. Generate test report.

## Inputs
- Design Document (expected behavior, API contracts).
- Implementation code.

## Outputs
- **Test Plan** with coverage per layer.
- **Test Suite** (unit + integration tests).
- **Test Report** with pass/fail results and coverage metrics.
- **Decoupling Validation Report**: confirms UI can be changed without breaking logic.

## Tools
- Test framework as defined by the active technology pattern
- Mocking library as defined by the active technology pattern
- Integration test tooling as defined by the active technology pattern
- Coverage tools as defined by the active technology pattern

## Acceptance Criteria
- Unit tests exist for every business logic use case.
- Presentation tests run without real backend or business logic.
- Integration tests validate API contracts.
- Decoupling validation passes (UI swap test).
- Minimum coverage threshold is met (defined per project).

## Decoupling Rule
Presentation tests must be executable independently from business logic and backend.

## Pattern Reference
For technology-specific testing details (test commands, coverage tools, mocking libraries), consult the active pattern's skills and `conventions.md`.