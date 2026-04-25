---
name: astro-testing
description: 'Generate and run tests for a modern Astro project. Use when validating route behavior, content loading, service logic, optional React islands, or browser navigation flows in a static-first Astro application.'
argument-hint: 'Feature or layer to test'
---

# Astro Testing

## When to Use
- Writing or generating tests for an Astro feature or layer.
- Validating that route composition, content loading, and island boundaries are maintained.
- Checking browser behavior for navigation, forms, or hydrated islands.

## Procedure

### Unit Tests (Services and Data)
1. Test loaders, service modules, DTO mapping, and data normalization with Vitest.
2. Keep these tests free from browser navigation concerns.
3. File: co-located `.test.ts` next to the service or data module.

### Content Validation
1. Validate collection schemas through Astro content definitions.
2. Test sorting, filtering, and slug generation logic when the site depends on it.
3. Keep collection definitions centralized and predictable.

### Route and Browser Tests
1. Use Playwright when route behavior, navigation, forms, or hydrated islands must be validated in a browser.
2. Assert user-visible behavior such as page titles, navigation, rendered content, and interactive island outcomes.
3. Avoid implementation-detail assertions for templates when rendered output is the real contract.

### Island Tests
1. Test hydrated React or other framework islands at the framework level only when their logic is substantial.
2. Keep browser-level tests focused on whether the island actually behaves correctly once hydrated.
3. Do not treat every static Astro component as a client-side unit test target.

### Decoupling Validation
1. **Hydration audit**: verify `client:*` directives are intentional and not spread through mostly static markup.
   ```bash
   rg "client:(load|idle|visible|media|only)" src
   ```
   Expected result: a deliberate, reviewable set of hydrated islands.

2. **Framework boundary**: verify framework components do not import `.astro` files directly.
   ```bash
   rg "\.astro'|\.astro\"" src --glob "*.tsx" --glob "*.jsx"
   ```
   Expected result: no direct `.astro` imports from framework component files.

3. **Route thinness**: verify route files are not full of repeated direct transport logic.
   ```bash
   rg "fetch\(|axios|createClient|graphql" src/pages
   ```
   Expected result: only justified route-level usage, with most logic extracted.

4. **Collection centralization**: verify collection definitions stay centralized.
   ```bash
   rg "defineCollection|defineLiveCollection" src
   ```
   Expected result: definitions live in `src/content.config.ts` or `src/live.config.ts`.

### Coverage
```bash
npx vitest run --coverage
```

### Browser Validation
```bash
npx playwright test
```

## Test Naming Convention
- File: same source file name with `.test.ts` for unit tests
- Browser tests: project convention, typically `*.spec.ts`
- Test name: `should <expected behavior> when <condition>`

## Reference
- Refer to `conventions.md` in the project root for Astro conventions.