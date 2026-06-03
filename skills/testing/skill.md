---
name: testing
description: 'Generates and executes test plans for each application layer. Use when writing tests, validating decoupling, checking coverage, or running test suites. Validates that presentation, business logic, and backend are properly decoupled and functional.'
---
# Testing Skill

## Objective
Generate and execute test plans for each layer: presentation, business logic, and backend.

## Workflow
1. Read all approved `SPEC_<Feature>.md` documents — these are the primary source of test scenarios.
2. Review the Design Document for API contracts and layer boundaries.
3. Review Implementation code structure.
4. Map every spec scenario (Given/When/Then) to one test case. Name tests after the scenario.
5. Write unit tests for business logic (no UI dependencies), covering all spec AC items.
6. Write unit tests for presentation (mocked business logic), covering all state scenarios in specs.
7. Write integration tests for API layer, validating every HTTP status code documented in specs.
8. Run decoupling validation: swap UI components and verify business logic tests still pass.
9. Generate test report with explicit traceability to spec IDs.

## Inputs
- **Specification Documents** (`SPEC_<Feature>.md`) — primary source of test scenarios and acceptance criteria.
- **Design Document** (API contracts, layer boundaries).
- **Implementation code.**

## Outputs
- **Test Plan** with coverage per layer and explicit mapping to spec IDs.
- **Test Suite** (unit + integration tests), where each test is named after its spec scenario.
- **Test Report** with pass/fail results, coverage metrics, and spec AC traceability.
- **Decoupling Validation Report**: confirms UI can be changed without breaking logic.

## Tools
- Test framework as defined by the active technology pattern
- Mocking library as defined by the active technology pattern
- Integration test tooling as defined by the active technology pattern
- Coverage tools as defined by the active technology pattern

## Acceptance Criteria
- Every spec acceptance criterion (AC-NN) has at least one passing test.
- Every spec scenario (Given/When/Then) is covered by a named test case.
- Unit tests exist for every business logic use case.
- Presentation tests run without real backend or business logic.
- Integration tests validate every HTTP status code documented in specs.
- Decoupling validation passes (UI swap test).
- Minimum coverage threshold is met (defined per project).

## Decoupling Rule
Presentation tests must be executable independently from business logic and backend.

## Pattern Reference
For technology-specific testing details (test commands, coverage tools, mocking libraries), consult the active pattern's skills and `conventions.md`.