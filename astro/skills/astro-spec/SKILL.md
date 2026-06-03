---
name: astro-spec
description: 'Translates the Astro Design Document into formal Specification Documents for pages, content collections, islands, API endpoints, and data-fetching logic. Maps each spec scenario to Vitest and Playwright/Cypress test patterns. Use after Design and before Implementation in Astro projects.'
argument-hint: 'Page, island, or endpoint name to specify'
---

# Astro Specification

## When to Use

- After the Astro architecture Design Document is approved.
- Before writing any page, island component, API route, or content schema.
- When adding a new feature to an existing Astro project.

## Astro-Specific Specification Units

| Unit Type | Layer | Spec Focus |
|---|---|---|
| Content collection schema | Data / Domain | Schema shape, required fields, type constraints |
| Data-fetching utility | Application | Fetch logic, error handling, return type |
| API route (`/api/*`) | Infrastructure | HTTP method, request validation, response shape, status codes |
| Astro page (`.astro`) | Presentation | Rendered HTML structure, SEO metadata, data passed to islands |
| Island component (React/Vue/Svelte) | Presentation | Interactive behavior, props contract, client:* directive choice |
| Layout component | Presentation | Slot structure, shared metadata, navigation state |

## Workflow

1. Read the Astro Design Document (routing, content collections, islands, API routes, rendering mode).
2. Identify all pages, islands, API routes, and data utilities that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the Astro-specific fields below.
5. Map each scenario to a Vitest (unit) or Playwright/Cypress (E2E) test pattern.
6. Verify every page spec covers static render output and SEO metadata.
7. Verify every island spec covers all interactive states and the correct `client:*` directive.

## Astro-Specific Spec Fields

Add the following section to each spec in an Astro project:

````markdown
## Astro Implementation Hints

### Unit Type
- [ ] Content collection schema (Zod-based)
- [ ] Data-fetching utility (`src/lib/`)
- [ ] API route (`src/pages/api/`)
- [ ] Astro page (`.astro` file)
- [ ] Island component (React / Vue / Svelte / Solid)
- [ ] Layout component

### Rendering Mode
- [ ] Static (SSG) — pre-rendered at build time
- [ ] Server-rendered (SSR) — rendered on each request
- [ ] Hybrid — page-level `export const prerender`

### Page / Island Props Contract
```typescript
// Astro.props shape for pages, or island component props interface goes here
```

### Content Collection Schema (if applicable)
```typescript
// z.object({ ... }) schema definition
```

### API Route Contract
| Field | Value |
|---|---|
| Method | GET / POST / PUT / DELETE |
| Route | `/api/resource` |
| Auth | None / Cookie / Header |
| Request body | `{ field: type }` |
| 200 response | `{ field: type }` |
| 400 / 422 response | Validation error shape |
| 500 response | Internal error shape |

### Test Pattern Reference
| Scenario | Test Approach |
|---|---|
| Content schema validation | Vitest: pass valid/invalid objects through Zod schema, assert parse result |
| Data-fetch utility | Vitest: mock `fetch`, call utility, assert return value and error handling |
| API route | Vitest with `Request` mock or `fetch` against dev server, assert `Response` |
| Page static output | Playwright/Cypress: navigate to route, assert visible text, headings, meta tags |
| Island interaction | Playwright/Cypress: click/type in island, assert reactive UI update |
| SEO metadata | Playwright: `page.title()`, `page.locator('meta[name="description"]')` |
````

## Acceptance Criteria (Astro-specific additions)

- [ ] Every page spec documents the rendering mode (SSG / SSR / hybrid) and why.
- [ ] Every island spec specifies the `client:*` directive and justifies the hydration strategy.
- [ ] Every API route spec lists all HTTP status codes and response shapes.
- [ ] Content collection schema specs verify required fields and type constraints with Zod.
- [ ] SEO-relevant pages have a metadata scenario covering `<title>` and `<meta description>`.

## Tool References

- **Unit testing:** Vitest
- **E2E testing:** Playwright (preferred) or Cypress
- **Schema validation:** Zod (Astro content collections)
- **API testing:** `Request`/`Response` Web API mocks in Vitest

## Pattern Reference

Follow the routing and island conventions defined in `astro/conventions.md`.
All API route contracts must match the Design Document endpoint definitions.
