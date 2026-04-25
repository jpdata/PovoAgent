---
name: react-feature
description: 'Create a new feature slice in a modern React project. Use when adding a route, screen, server-data workflow, form flow, or user story across domain, data, and UI boundaries in a feature-first React application.'
argument-hint: 'Feature name and description'
---

# React Feature Implementation

## When to Use
- Adding a new routed feature, workflow, page, or form flow to an existing React project.
- Implementing a user story that spans domain, data, and UI concerns.
- Creating a feature slice that keeps components decoupled from transport and persistence details.

## Procedure

1. **Define the feature scope**
   - Identify the route entry point, business action(s), data source, and UI states.
   - Ask the user if any of these are unclear: rendering constraints, framework context, form complexity, authentication context, server-state complexity, or UI system.

2. **Create the feature slice structure**
   ```text
   src/features/<feature>/
   ├── domain/
   │   ├── entities/<Feature>.ts
   │   ├── contracts/<feature>Repository.ts
   │   └── use-cases/load<Feature>.ts
   ├── data/
   │   ├── api/<feature>Api.ts
   │   ├── dto/<feature>Dto.ts
   │   └── repositories/<feature>Repository.ts
   ├── ui/
   │   ├── components/<Feature>Card.tsx
   │   ├── pages/<Feature>Page.tsx
   │   └── hooks/use<Feature>Controller.ts
   ├── route.tsx
   └── index.ts
   ```

3. **Create the Domain layer files**
   - Entity: pure TypeScript type or class.
   - Contract: repository or service interface defining the feature boundary.
   - Use case: focused business action that depends only on contracts and domain logic.

4. **Create the Data layer files**
   - API module: handles network access and transport details.
   - DTO: typed transport model.
   - Repository adapter: implements the domain contract and maps DTOs into domain entities.
   - Keep backend response mapping here, not in pages or presentational components.

5. **Create the UI layer files**
   - Page component: routed feature entry point.
   - Presentational components: reusable feature UI pieces.
   - Feature controller hook: owns feature orchestration, server-state interaction, and component-facing behavior.
   - Keep pages and presentational components focused on rendering and interaction.

6. **Add the route**
   - Create the feature route entry and wire it into the app router or framework route tree.
   - Keep routing boundaries explicit; do not bypass the feature slice with arbitrary deep imports.

7. **Add forms and validation if needed**
   - Use simple controlled forms for simple workflows.
   - Introduce a form library and schema validation only when the project's design decisions justify it.
   - Keep validation rules out of presentational components when they encode business rules.

8. **Create tests**
   ```text
   src/features/<feature>/domain/use-cases/load<Feature>.test.ts
   src/features/<feature>/data/repositories/<feature>Repository.test.ts
   src/features/<feature>/ui/hooks/use<Feature>Controller.test.tsx
   src/features/<feature>/ui/pages/<Feature>Page.test.tsx
   ```
   - Co-locate tests with the code they validate.

## Decoupling Checklist
- [ ] Domain files contain zero React imports.
- [ ] Data files do not import from `ui/`.
- [ ] Page and presentational component files do not call `fetch` or repository adapters directly.
- [ ] Feature controller hooks or use cases own async orchestration.
- [ ] Route registration does not bypass the feature boundary.
- [ ] Swapping the page component does not require changes to the data or domain layers.

## Reference
- Refer to `conventions.md` in the project root for React conventions.