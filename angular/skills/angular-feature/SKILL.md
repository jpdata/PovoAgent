---
name: angular-feature
description: 'Create a new feature slice in a modern Angular project. Use when adding a route, screen, data workflow, form flow, or user story across domain, data, and UI boundaries in a feature-first Angular application.'
argument-hint: 'Feature name and description'
---

# Angular Feature Implementation

## When to Use
- Adding a new routed feature, dashboard screen, workflow, or form flow to an existing Angular project.
- Implementing a user story that spans domain, data, and UI concerns.
- Creating a feature slice that keeps components decoupled from transport and infrastructure details.

## Procedure

1. **Define the feature scope**
   - Identify the route entry point, business action(s), data source, and UI states.
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

## Decoupling Checklist
- [ ] Domain files contain zero Angular imports.
- [ ] Data files do not import from `ui/`.
- [ ] UI files do not call `HttpClient` or API services directly.
- [ ] Writable signals remain private to the facade/store.
- [ ] Route loading does not bypass the feature boundary.
- [ ] Swapping the page component does not require changes to the data or domain layers.

## Reference
- Refer to `conventions.md` in the project root for Angular conventions.