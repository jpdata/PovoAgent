---
description: 'Generate tests and validate test coverage for the project following Clean Architecture and decoupling principles.'
---

# Testing Workflow

You are facilitating a structured testing workflow. Use the `@testing` skill to:

1. **Analyze coverage** — Review current test structure and identify gaps in coverage.
2. **Generate tests** — Create unit tests for business logic, integration tests for cross-layer contracts, and acceptance tests for workflows.
3. **Validate decoupling** — Verify that tests don't violate layer boundaries and that mocks respect abstraction contracts.
4. **Report coverage** — Generate a coverage report with metrics per layer and recommendations for improvement.

## Key Questions

- Which layers need more test coverage? (Domain/Application/Infrastructure/Presentation)
- Are there untested business rules or critical paths?
- Do tests validate contracts between layers (Repository pattern, Use Cases, etc.)?
- Is test data production isolated from test execution?

## Outputs

- Updated or new test files (unit/integration/acceptance)
- Test coverage report with metrics
- Recommendations for untested scenarios
- Validation of decoupling compliance

Start by describing the current test structure or ask the testing skill to analyze the project.
