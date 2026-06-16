---
name: angular-scaffold
description: 'Scaffold a new Angular project with a modern feature-first architecture. Use when creating a new Angular app, setting up standalone bootstrapping, routing, feature boundaries, state, forms, HTTP, theming, and testing foundations.'
argument-hint: 'Project name, application type, and main features'
---

# Angular Project Scaffolding

## When to Use
- Creating a new Angular application from scratch.
- Setting up a feature-first project structure with explicit domain, data, and UI boundaries (Clean Architecture) or Vertical Slice Architecture feature organization.
- Configuring standalone bootstrapping, routing, HTTP, and testing foundations while leaving project-specific UI baseline decisions to analysis and design.

## Procedure

1. **Define key decisions before scaffolding**
   - Architecture style: Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.
   - Ask the user if these are unclear: rendering mode (CSR / SSR / hybrid), UI system (Angular Material / custom design system / utility-first CSS), state complexity, authentication, and i18n requirements.
   - Do not impose a fixed visual baseline from the Angular pattern. The real project's analysis and design phases must decide the design system, visual direction, and shared UI primitives.

2. **Create the Angular project**
   ```bash
   ng new <project_name> --routing --style=scss
   ```
   - If SSR or hybrid rendering is required:
     ```bash
     ng new <project_name> --routing --style=scss --ssr
     ```
   - Current Angular versions create standalone applications by default.

3. **Set up the project folder structure**

   **Clean Architecture (feature-first with domain/data/ui):**
   ```
   src/
   ├── app/
   │   ├── app.config.ts
   │   ├── app.routes.ts
   │   ├── core/
   │   │   ├── config/
   │   │   ├── http/interceptors/
   │   │   ├── layout/
   │   │   └── services/
   │   ├── shared/
   │   │   ├── ui/
   │   │   ├── pipes/
   │   │   └── directives/
   │   └── features/
   ├── assets/
   └── styles.scss
   ```

   **Vertical Slice Architecture:**
   ```
   src/
   ├── app/
   │   ├── app.config.ts
   │   ├── app.routes.ts
   │   ├── core/
   │   │   ├── http/interceptors/
   │   │   ├── layout/
   │   │   └── config/
   │   └── contracts/
   │       └── events/
   ├── features/
   │   └── <feature-name>/
   │       ├── index.ts
   │       ├── <action>/
   │       │   ├── <action>.component.ts
   │       │   ├── <action>.component.html
   │       │   ├── <action>.component.scss
   │       │   └── <action>.component.spec.ts
   │       └── services/
   ├── shared/
   │   ├── ui/
   │   ├── pipes/
   │   └── directives/
   ├── assets/
   └── styles.scss
   ```

4. **Add core dependencies**
   - UI system: add only the packages required by the UI strategy chosen in design.
   - `@angular/material` + `@angular/cdk` if the project chooses Angular Material.
   - State: built-in signals + RxJS interop (no extra package required for default approach).
   - Forms: Reactive Forms.
   - Browser/e2e tests: Playwright only if the project needs browser automation.
   - Localization: `@angular/localize` only if needed.

5. **Create base application files**
   - `src/app/app.config.ts` — root providers with `provideRouter(...)` and `provideHttpClient(...)`
   - `src/app/app.routes.ts` — root lazy routes
   - `src/app/core/layout/` — app shell and top-level layout
   - `src/app/core/http/interceptors/` — auth, logging, caching, or retry interceptors
   - `src/app/core/config/` — environment-aware configuration tokens
   - `src/styles.scss` — global design tokens, theme setup, and app-level styles

6. **Set up the chosen UI foundations**
   - If using Angular Material:
     ```bash
     ng add @angular/material
     ```
   - If using Angular Material, create a custom theme using Material tokens and explicit `color-scheme`.
   - Keep global layout, typography, and visual-system decisions in `styles.scss` or the selected design-system files, not inside feature components.
   - If the project uses a custom design system, scaffold only the neutral structure and leave project-specific UI primitives to the design output.

7. **Set up testing foundations**
   - Keep `.spec.ts` files co-located with source files.
   - Use Angular CLI's default Vitest setup.
   - Add shared test providers if global HTTP or router testing setup is needed.

8. **Verify**
   - Run `npm install`.
   - Run `ng build` — no errors.
   - Run `ng test --no-watch --no-progress` — no failing unit tests.
   - Confirm no Angular imports appear inside future `domain/` folders.

## Decoupling Validation

**Clean Architecture:**
- `domain/` folders must contain pure TypeScript only.
- `data/` adapts backend and external systems behind domain ports.
- `ui/` depends on facades, use cases, or domain models rather than HTTP details.
- Feature routes lazy-load features instead of centralizing all UI in the app shell.

**Vertical Slice Architecture:**
- Each feature under `src/app/features/<name>/` contains all its own components, services, and data access.
- `src/app/shared/` contains only reusable cross-slice code (no feature-specific business logic).
- Features do not import from other feature slices.
- `src/app/core/contracts/` defines shared event types and interface contracts between slices.

## Reference
- Refer to `conventions.md` in the project root for Angular conventions.