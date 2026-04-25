---
name: react-scaffold
description: 'Scaffold a new React project with a modern feature-first architecture. Use when creating a new React app, setting up feature boundaries, routing, providers, testing foundations, and a neutral technical base while leaving project-specific UI baseline decisions to analysis and design.'
argument-hint: 'Project name, application type, and main features'
---

# React Project Scaffolding

## When to Use
- Creating a new React application from scratch.
- Setting up a feature-first project structure with explicit domain, data, and UI boundaries.
- Configuring routing, providers, data-loading, and testing foundations while leaving project-specific UI baseline decisions to analysis and design.

## Procedure

1. **Define key decisions before scaffolding**
   - Ask the user if these are unclear: React framework vs start-from-scratch React, rendering needs (CSR / SSR / SSG), routing mode, server-state strategy, UI system, authentication, forms complexity, and i18n requirements.
   - Do not impose a fixed visual baseline from the React pattern. The real project's analysis and design phases must decide the design system, visual direction, and shared UI primitives.

2. **Choose the scaffold path**
   - If the project needs full-stack React capabilities, ask the user to choose the framework path and scaffold with that framework.
   - For a start-from-scratch client React app, use Vite:
     ```bash
     npm create vite@latest <project_name> -- --template react-ts
     ```
   - If the project explicitly chooses React Router framework mode:
     ```bash
     npx create-react-router@latest
     ```

3. **Set up the feature-first folder structure**
   ```text
   src/
   ├── app/
   │   ├── providers/
   │   ├── router/
   │   └── layout/
   ├── shared/
   │   ├── ui/
   │   ├── hooks/
   │   ├── lib/
   │   └── types/
   ├── features/
   ├── styles/
   └── main.tsx
   ```

4. **Add core dependencies**
   - Routing: `react-router-dom` if the project is a routed, non-framework React app.
   - Server state: `@tanstack/react-query` when the project needs caching, invalidation, pagination, or background refresh.
   - Testing: `vitest` and `@testing-library/react`.
   - Browser/e2e testing: `playwright` only if the project needs browser automation.
   - Forms: `react-hook-form` and a schema library only if the project chooses them in design.
   - UI system: add only the packages required by the chosen design-system strategy.

5. **Create base application files**
   - `src/main.tsx` — application bootstrap
   - `src/app/providers/AppProviders.tsx` — root providers
   - `src/app/router/router.tsx` or framework routing entry — route composition
   - `src/app/layout/AppShell.tsx` — app shell and top-level layout
   - `src/shared/lib/env.ts` — environment and configuration helpers
   - `src/styles/` — global tokens, theme setup, and app-level styles

6. **Set up the chosen UI foundations**
   - Keep global layout, typography, and visual-system decisions in the styling layer, not inside feature components.
   - If the project uses a component library, configure it through its supported setup and theming APIs.
   - If the project uses a custom design system, scaffold only the neutral structure and leave project-specific UI primitives to the design output.

7. **Set up testing foundations**
   - Add a Vitest test command and setup file.
   - Add React Testing Library setup and shared test utilities.
   - Keep tests co-located with the code they validate.

8. **Verify**
   - Run `npm install`.
   - Run `npm run build` — no errors.
   - Run `npx vitest run` — no failing unit tests.
   - Confirm no React imports appear inside future `domain/` folders.

## Decoupling Validation
- `domain/` folders must contain pure TypeScript only.
- `data/` adapts external systems behind feature contracts.
- `ui/` components depend on hooks, use cases, props, or state ownership boundaries rather than direct transport code.
- Provider composition and routing stay in `app/`, not inside feature presentation modules.

## Reference
- Refer to `conventions.md` in the project root for React conventions.