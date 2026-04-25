---
name: angular-testing
description: 'Generate and run tests for a modern Angular project. Use when writing unit tests, validating feature boundaries, testing components, facades, HTTP services, routing, or checking coverage in a standalone Angular application.'
argument-hint: 'Feature or layer to test'
---

# Angular Testing

## When to Use
- Writing or generating tests for a feature or layer.
- Validating that architectural decoupling is maintained.
- Checking unit test coverage and browser-sensitive behavior.

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

### Decoupling Validation
1. **Domain isolation**: verify `domain/` files contain zero Angular imports.
   ```bash
   rg "from '@angular|from \"@angular" src/app/features/**/domain
   ```
   Expected result: no matches.

2. **Data isolation**: verify `data/` files do not import from `ui/`.
   ```bash
   rg "from '.*ui/|from \".*ui/" src/app/features/**/data
   ```
   Expected result: no matches.

3. **UI isolation**: verify `ui/` files do not import from `data/access/` or concrete repositories.
   ```bash
   rg "data/access|data/repositories" src/app/features/**/ui
   ```
   Expected result: no matches.

4. **HTTP isolation**: verify `HttpClient` is not used in page or presentational components.
   ```bash
   rg "HttpClient" src/app/features/**/ui
   ```
   Expected result: no matches.

### Coverage
```bash
ng test --coverage --no-watch --no-progress
```

## Test Naming Convention
- File: same source file name with `.spec.ts`
- Test name: `should <expected behavior> when <condition>`

## Reference
- Refer to `conventions.md` in the project root for Angular conventions.