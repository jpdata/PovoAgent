---
name: react-testing
description: 'Generate and run tests for a modern React project. Use when writing unit tests, validating feature boundaries, testing components, hooks, reducers, data modules, or checking coverage in a feature-first React application.'
argument-hint: 'Feature or layer to test'
---

# React Testing

## When to Use
- Writing or generating tests for a feature or layer.
- Validating that architectural decoupling is maintained.
- Checking unit test coverage and browser-sensitive behavior.

## Procedure

### Unit Tests (Domain)
1. Test domain entities, contracts, and use cases as pure TypeScript.
2. Keep these tests free from React rendering concerns.
3. File: co-located `.test.ts` next to the domain file.

### Unit Tests (Data)
1. Test repository adapters and API modules with mocked transport.
2. Verify DTO-to-domain mapping, error handling, and contract compliance.
3. File: co-located `.test.ts` next to the data file.

### Unit Tests (UI Logic)
1. Test feature hooks, reducers, and providers in isolation where practical.
2. Verify loading, success, error, and state transition behavior.
3. Avoid using real network calls in these tests.

### Component Tests
1. Test pages and presentational components with React Testing Library.
2. Favor queries and assertions that resemble how users interact with the UI.
3. Avoid implementation-detail assertions against internal component structure.

### Routing and Form Tests
1. Test routing flows where behavior depends on route parameters, navigation, or guards.
2. Test forms through user interactions and validation outcomes, not internal field implementation details.

### Browser-Specific Tests
1. Default unit and component tests run with Vitest.
2. Use Playwright or browser-mode tests only when real browser behavior matters.

### Decoupling Validation
1. **Domain isolation**: verify `domain/` files contain zero React imports.
   ```bash
   rg "from 'react|from \"react" src/features/**/domain
   ```
   Expected result: no matches.

2. **Data isolation**: verify `data/` files do not import from `ui/`.
   ```bash
   rg "from '.*ui/|from \".*ui/" src/features/**/data
   ```
   Expected result: no matches.

3. **UI transport isolation**: verify page and presentational component files do not call raw transport directly.
   ```bash
   rg "fetch\(|axios|Repository" src/features/**/ui/pages src/features/**/ui/components
   ```
   Expected result: no transport usage except intentional prop or type names.

4. **Boundary validation**: verify feature routes import through the feature entry or route module, not arbitrary internals from unrelated features.
   ```bash
   rg "features/.+features/" src/app src/features/**/route.tsx
   ```
   Expected result: no cross-feature deep-import chains.

### Coverage
```bash
npx vitest run --coverage
```

## Test Naming Convention
- File: same source file name with `.test.ts` or `.test.tsx`
- Test name: `should <expected behavior> when <condition>`

## Reference
- Refer to `conventions.md` in the project root for React conventions.