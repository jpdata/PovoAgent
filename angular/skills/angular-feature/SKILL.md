---
name: angular-feature
description: 'Create a new feature slice in a modern Angular project (Clean Architecture or Vertical Slice Architecture). Use when adding a route, screen, data workflow, form flow, or user story across domain, data, and UI boundaries (CA) or within a self-contained vertical feature slice (VSA).'
argument-hint: 'Feature name and description'
---

# Angular Feature Implementation

## When to Use
- Adding a new routed feature, dashboard screen, workflow, or form flow to an existing Angular project.
- Implementing a user story that spans domain, data, and UI concerns (CA) or lives within a self-contained vertical slice (VSA).
- Creating a feature slice that keeps components decoupled from transport and infrastructure details.

## Procedure

1. **Define the feature scope**
   - Identify the route entry point, business action(s), data source, and UI states.
   - **Architecture style:** Confirm whether the project uses Clean Architecture or Vertical Slice Architecture. If not decided, refer to the kickoff diagnostic questions.
   - Ask the user if any of these are unclear: rendering requirements, form complexity, authentication context, UI system, or state complexity.

2. **Create the feature slice structure**
   ```
   src/app/features/<feature>/
   ├── domain/
   │   ├── entities/<feature>.ts
   │   ├── ports/<feature>-repository.port.ts
   │   └── use-cases/load-<feature>.use-case.ts
   ├── data/
   │   ├── access/<feature>-api.service.ts
   │   ├── dto/<feature>-dto.ts
   │   └── repositories/<feature>-repository.service.ts
   ├── ui/
   │   ├── components/<feature>-card/<feature>-card.ts
   │   ├── pages/<feature>-page/<feature>-page.ts
   │   └── store/<feature>.facade.ts
   ├── <feature>.routes.ts
   └── index.ts
   ```

3. **Create the Domain layer files**
   - Entity: pure TypeScript type or class.
   - Port: `InjectionToken` or abstract class representing the repository contract.
   - Use case: focused business action that depends only on the domain port.

4. **Create the Data layer files**
   - API service: handles HTTP calls and transport concerns.
   - DTO: typed transport model.
   - Repository service: implements the domain port and maps DTOs into domain entities.
   - Keep backend response mapping here, not in components or facades.

5. **Create the UI layer files**
   - Page component: routed feature entry point.
   - Presentational components: reusable feature UI pieces.
   - Facade/store: owns feature state with signals and orchestrates use cases.
   - Keep templates focused on rendering and user interaction.

6. **Add the route**
   - Create a feature routes file and lazy-load the feature from the root route tree.
   - If route parameters belong directly on the page component, prefer `withComponentInputBinding()` and signal inputs.

7. **Add forms and validation if needed**
   - Use Reactive Forms by default.
   - Move validation and transformation logic out of templates.

8. **Create tests**
   ```
   src/app/features/<feature>/domain/use-cases/load-<feature>.use-case.spec.ts
   src/app/features/<feature>/data/repositories/<feature>-repository.service.spec.ts
   src/app/features/<feature>/ui/store/<feature>.facade.spec.ts
   src/app/features/<feature>/ui/pages/<feature>-page/<feature>-page.spec.ts
   ```
   - Co-locate tests with the code they validate.

### Vertical Slice Architecture Path

When the project uses VSA, create a flat per-action feature slice:

1. **Create the VSA feature slice structure**
   ```
   src/app/features/<feature>/
   ├── index.ts                                   ← Public API barrel export
   ├── list/
   │   ├── list.component.ts
   │   ├── list.component.html
   │   ├── list.component.scss
   │   └── list.component.spec.ts
   ├── create/
   │   ├── create.component.ts
   │   ├── create.component.html
   │   ├── create.component.scss
   │   └── create.component.spec.ts
   ├── detail/
   │   ├── detail.component.ts
   │   ├── detail.component.html
   │   ├── detail.component.scss
   │   └── detail.component.spec.ts
   ├── models/
   │   └── <feature>.ts                           ← Entity + DTOs
   └── services/
       ├── <feature>-api.service.ts                ← HTTP calls scoped to this feature
       └── <feature>.service.ts                    ← Business logic service
   ```

2. **Create the entity and services**
   - Entity: plain TypeScript type or class at `models/<feature>.ts`.
   - API service: HTTP calls scoped to this feature only at `services/<feature>-api.service.ts`.
   - Business service: orchestrates logic, injected into components.

3. **Create components per action**
   - Each action (list, create, detail, edit) gets its own subfolder with `.ts`, `.html`, `.scss`, `.spec.ts`.
   - Component injects the feature-scoped service directly (no facade indirection needed).
   - Use standalone components with `imports` for shared UI pieces.

4. **Add the route** via lazy loading:
   ```ts
   // src/app/app.routes.ts
   {
     path: '<feature>',
     loadComponent: () =>
       import('./features/<feature>/list/list.component').then(m => m.ListComponent),
   },
   {
     path: '<feature>/create',
     loadComponent: () =>
       import('./features/<feature>/create/create.component').then(m => m.CreateComponent),
   },
   ```

5. **Create tests** (co-located per action)
   ```
   src/app/features/<feature>/list/list.component.spec.ts
   src/app/features/<feature>/create/create.component.spec.ts
   src/app/features/<feature>/services/<feature>.service.spec.ts
   ```

**VSA Key Rules:**
- No separate `domain/`, `data/`, `ui/` subfolders — each action folder is self-contained.
- Components inject the feature-scoped service directly.
- `src/app/shared/` provides reusable cross-slice UI, pipes, and directives.
- `src/app/core/contracts/` defines shared event types for cross-slice communication.
- Features do not import from other features.

## Decoupling Checklist

**Clean Architecture:**
- [ ] Domain files contain zero Angular imports.
- [ ] Data files do not import from `ui/`.
- [ ] UI files do not call `HttpClient` or API services directly.
- [ ] Writable signals remain private to the facade/store.
- [ ] Route loading does not bypass the feature boundary.
- [ ] Swapping the page component does not require changes to the data or domain layers.

**Vertical Slice Architecture:**
- [ ] Each feature slice is self-contained — no imports from other feature slices.
- [ ] `src/app/shared/` contains only reusable cross-slice code, no feature-specific logic.
- [ ] `src/app/core/contracts/` defines shared event types for cross-slice communication.
- [ ] Component can be tested with mocked services (no HTTP).
- [ ] Swapping the component doesn't affect other slices.

## Reference
- Refer to `conventions.md` in the project root for Angular conventions.