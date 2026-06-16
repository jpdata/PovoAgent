---
name: angular-testing
description: 'Generate and run tests for a modern Angular project (Clean Architecture or Vertical Slice Architecture). Use when writing unit tests, validating feature boundaries/slices, testing components, facades, HTTP services, routing, or checking coverage.'
argument-hint: 'Feature or layer to test'
---

# Angular Testing

## When to Use
- Writing or generating tests for a feature, layer (CA), or slice (VSA).
- Validating that architectural decoupling is maintained.
- Checking unit test coverage and browser-sensitive behavior.

## Pre-Testing Questions
- **Architecture style:** Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.

## Procedure

### Unit Tests (Domain)
1. Test domain entities, ports, and use cases as pure TypeScript.
2. Keep these tests free from Angular rendering concerns.
3. File: co-located `.spec.ts` next to the domain file.

### Unit Tests (Data)
1. Test repository services and API services with `provideHttpClientTesting()`.
2. Verify DTO-to-domain mapping and error handling.
3. File: co-located `.spec.ts` next to the data file.

### Unit Tests (UI State)
1. Test feature facades/stores directly.
2. Verify signal updates, computed state, loading flows, and error transitions.
3. Avoid using real HTTP or repositories; provide mocks for domain ports or use cases.

### Component Tests
1. Test routed pages and presentational components with mocked facades.
2. Keep components presentation-focused and assert rendered states, not transport details.
3. Prefer simple, deterministic tests over full integration unless behavior truly spans layers.

### Routing and Navigation Tests
1. Test lazy route boundaries and navigation only where behavior depends on route data or guards.
2. Use route input binding or router testing utilities when route params drive feature behavior.

### Browser-Specific Tests
1. Default unit tests run with Vitest + `jsdom` through Angular CLI.
2. Use browser mode or Playwright only when browser APIs or real rendering behavior matter.

## Decoupling Validation

**Clean Architecture:**
1. **Domain isolation**: verify `domain/` files contain zero Angular imports.
   ```bash
   rg "from '@angular|from \"@angular" src/app/features/**/domain
   ```
   Expected: no matches.

2. **Data isolation**: verify `data/` files do not import from `ui/`.
   ```bash
   rg "from '.*ui/|from \".*ui/" src/app/features/**/data
   ```
   Expected: no matches.

3. **UI isolation**: verify `ui/` files do not import from `data/access/` or concrete repositories.
   ```bash
   rg "data/access|data/repositories" src/app/features/**/ui
   ```
   Expected: no matches.

4. **HTTP isolation**: verify `HttpClient` is not used in page or presentational components.
   ```bash
   rg "HttpClient" src/app/features/**/ui
   ```
   Expected: no matches.

**Vertical Slice Architecture:**
1. **Slice isolation**: verify no cross-feature imports between feature slices.
   ```bash
   rg "from '.*features/" src/app/features/<feature>/ | rg -v "features/<feature>"
   ```
   Expected: no matches.

2. **Shared purity**: verify `shared/` contains no feature-specific business logic.
   ```bash
   rg "Feature" src/app/shared/
   ```
   Expected: no feature names referenced.

3. **Contract stability**: verify shared contracts are tested and compatible.
   ```bash
   ng test --include "src/app/core/contracts/**/*.spec.ts"
   ```
   Expected: all contract tests pass.

4. **Component isolation**: verify components don't import from other feature slices' services.
   ```bash
   rg "from '.*features/.*services" src/app/features/<feature>/ | rg -v "features/<feature>/services"
   ```
   Expected: no matches.

### Coverage
```bash
ng test --coverage --no-watch --no-progress
```

### Vertical Slice Architecture Testing

When the project uses VSA, tests follow the per-action slice structure:

#### Unit Tests (feature services)
- Test business logic services with mocked `HttpClient`.
- File: `src/app/features/<feature>/services/<feature>.service.spec.ts`
- Verify data transformation, error handling, and state logic.

#### Component Tests (per action component)
- Mock the feature-scoped service — no real HTTP.
- Test component rendering for each UI state (loading, empty, error, success).
- File: `src/app/features/<feature>/<action>/<action>.component.spec.ts`
- Use `TestBed.configureTestingModule` with mocked service providers.

#### Integration Tests (per slice)
- Test the full vertical slice: service → component → template.
- Provide a mocked HTTP interceptor for deterministic responses.
- File: `src/app/features/<feature>/<feature>.integration.spec.ts`

#### Contract Tests (cross-slice)
- Test that shared contracts/events in `src/app/core/contracts/` remain consistent.
- File: `src/app/core/contracts/events/<event>.contract.spec.ts`

**VSA Testing Rules:**
- Test files co-located per action folder — no separate test tree.
- Component tests mock the feature service, not HTTP directly.
- Each slice is independently testable — no cross-slice test dependencies.
- Integration tests verify the full vertical path within the slice.

## Test Naming Convention
- File: same source file name with `.spec.ts`
- Test name: `should <expected behavior> when <condition>`

## Reference
- Refer to `conventions.md` in the project root for Angular conventions.