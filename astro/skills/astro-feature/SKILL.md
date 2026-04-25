---
name: astro-feature
description: 'Create a new feature slice in a modern Astro project. Use when adding a route, content-driven section, data workflow, or interactive island while preserving Astro’s static-first and selective-hydration architecture.'
argument-hint: 'Feature name and description'
---

# Astro Feature Implementation

## When to Use
- Adding a new route, content-driven section, landing page section, listing flow, or interactive island to an existing Astro project.
- Implementing a user story that spans routing, content, data, and optional island behavior.
- Creating a feature slice that keeps route files thin and hydration selective.

## Procedure

1. **Define the feature scope**
   - Identify the route entry point, content source, data source, and any interactive behavior.
   - Ask the user if any of these are unclear: static vs on-demand rendering, CMS integration, React-island need, form complexity, auth, i18n, or view transitions.

2. **Create the feature slice structure**
   ```text
   src/features/<feature>/
   ├── components/<Feature>Section.astro
   ├── islands/<Feature>Widget.tsx        ← optional when using React islands
   ├── data/<feature>Dto.ts               ← optional when remote data exists
   ├── services/load<Feature>.ts
   └── index.ts

   src/pages/<route>.astro
   ```
   - If the feature introduces structured content, also update:
   ```text
   src/content/<collection>/...
   src/content.config.ts
   ```

3. **Create the route file**
   - Keep `src/pages/...` focused on route composition, metadata, and calling helpers.
   - Use static generation by default.
   - Add `getStaticPaths()` only when the route is a dynamic static route.

4. **Create feature services and data modules**
   - Put content querying, sorting, filtering, and normalization in `services/`.
   - Put DTOs, API calls, or CMS adapters in `data/` when remote data exists.
   - Keep route files and templates free from repeated transport or CMS logic.

5. **Create Astro components and optional islands**
   - Use `.astro` components for static sections and composition.
   - Add a framework island only for the specific interactive surface that needs it.
   - If using React, keep the React component isolated in `islands/` and pass serializable props from Astro.

6. **Add content collections if needed**
   - Define or update the collection schema in `src/content.config.ts`.
   - Use a schema whenever practical for repeatable structured content.
   - Prefer build-time collections unless the feature truly needs runtime freshness.

7. **Add forms, transitions, or runtime behavior only when justified**
   - Prefer native HTML forms and links first.
   - Use view transitions only if the feature benefits from enhanced navigation.
   - Use on-demand rendering only when the feature requires request-time behavior.

8. **Create tests**
   ```text
   src/features/<feature>/services/load<Feature>.test.ts
   src/features/<feature>/data/<feature>Adapter.test.ts
   tests/<feature>.spec.ts                ← optional Playwright browser flow
   ```
   - Co-locate unit tests where practical.
   - Use browser tests only for actual route or interactivity behavior.

## Decoupling Checklist
- [ ] Route files stay thin and do not own avoidable data orchestration.
- [ ] Static markup remains in `.astro` components instead of unnecessary islands.
- [ ] Interactive islands are explicit and minimal.
- [ ] Framework islands do not import `.astro` components directly.
- [ ] Props passed to hydrated components are serializable.
- [ ] Content schemas and remote data logic are centralized.

## Reference
- Refer to `conventions.md` in the project root for Astro conventions.