---
name: testing
description: 'Generates and executes test plans for each application layer (Clean Architecture) or each feature slice (Vertical Slice Architecture). Use when writing tests, validating decoupling, checking coverage, or running test suites. Validates that components are properly decoupled and functional.'
---
# Testing Skill

## Objective
Generate and execute test plans for each layer: presentation, business logic, and backend.

## Workflow

### Pre-Step — Read Project Cache
1. If `PROJECT_CACHE.md` exists, read it to locate test files, test directories, and the architecture map — this tells you where existing tests live and how the project is organized for test structuring.
2. **If fresh**: Use the File Index (Test Files section) to find existing tests directly. Use the Symbol Index to find which classes need test coverage.
3. **If stale or absent**: Proceed without it; scan the project structure manually.

### Step 0 — Confirm Architecture Style
Read the Design Document to identify the architecture style. All test organization follows the style below.

### Clean Architecture Path
1. Read all approved `SPEC_<Feature>.md` documents — these are the primary source of test scenarios.
2. Review the Design Document for API contracts and layer boundaries.
3. Review Implementation code structure.
4. Map every spec scenario (Given/When/Then) to one test case. Name tests after the scenario.
5. Write unit tests for business logic (no UI dependencies), covering all spec AC items.
6. Write unit tests for presentation (mocked business logic), covering all state scenarios in specs.
7. Write integration tests for API layer, validating every HTTP status code documented in specs.
8. Run decoupling validation: swap UI components and verify business logic tests still pass.
9. Generate test report with explicit traceability to spec IDs.

### Vertical Slice Architecture Path
1. Read all approved `SPEC_<Feature>.md` documents.
2. Review the Design Document for slice boundaries and cross-slice contracts.
3. For each slice, write unit tests covering the handler/use case logic (mocking data access).
4. Write integration tests for each slice's endpoint (validating HTTP status codes and response shapes as documented in the spec).
5. Write contract tests for cross-slice boundaries (verify that slices honor their published contracts).
6. Run slice isolation validation: verify each slice's tests pass independently without other slices.
7. Generate test report with explicit traceability to spec IDs.

## Inputs
- **Specification Documents** (`SPEC_<Feature>.md`) — primary source of test scenarios and acceptance criteria.
- **Design Document** — architecture style, API contracts, and boundaries (layer boundaries for CA, slice boundaries for VSA).
- **Implementation code.**

## Outputs
- **Test Plan** with coverage per layer (CA) or per slice (VSA), and explicit mapping to spec IDs.
- **Test Suite** (unit + integration tests), where each test is named after its spec scenario.
- **Test Report** with pass/fail results, coverage metrics, and spec AC traceability.
- **Decoupling Validation Report:**
  - CA: confirms UI can be changed without breaking logic.
  - VSA: confirms each slice is independently testable without other slices.

## Tools
- Test framework as defined by the active technology pattern
- Mocking library as defined by the active technology pattern
- Integration test tooling as defined by the active technology pattern
- Coverage tools as defined by the active technology pattern

## Acceptance Criteria

### Common
- Every spec acceptance criterion (AC-NN) has at least one passing test.
- Every spec scenario (Given/When/Then) is covered by a named test case.
- Minimum coverage threshold is met (defined per project).

### Clean Architecture — Specific
- Unit tests exist for every business logic use case.
- Presentation tests run without real backend or business logic.
- Integration tests validate every HTTP status code documented in specs.
- Decoupling validation passes (UI swap test).

### Vertical Slice Architecture — Specific
- Unit tests exist for every slice's handler/use case logic.
- Integration tests exist for every slice's endpoint.
- Contract tests validate cross-slice boundaries.
- Slice isolation validation passes (each slice tested independently).

## Decoupling Rule
- **Clean Architecture:** Presentation tests must be executable independently from business logic and backend.
- **Vertical Slice Architecture:** Each slice's tests must be executable independently from other slices. Cross-slice contracts are verified through contract tests, not by running dependent slices.

## Pattern Reference
For technology-specific testing details (test commands, coverage tools, mocking libraries), consult the active pattern's skills and `conventions.md`.