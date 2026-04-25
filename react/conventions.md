# React + TypeScript Conventions

## Decision Protocol

When a technology choice, library, or architectural decision is not explicitly defined in the project, **ask the user before assuming**. The question should be asked at the appropriate lifecycle phase:

- **Analysis phase:** app type (dashboard, public site, back-office, PWA, marketing site), SEO or SSR needs, target browsers, accessibility level, and backend integration boundaries.
- **Design phase:** React framework vs start-from-scratch approach, routing mode, data-loading strategy, UI system, authentication approach, forms complexity, and i18n needs.
- **Implementation phase:** server-state library choice, shared client-state complexity, validation library choice, testing depth, browser/e2e coverage, and performance-sensitive interactions.

**Default choices** (used when the user does not specify):

- React: latest stable React with TypeScript.
- Bootstrapping: if the project needs full-stack React features such as SSR, SSG, streaming, route loaders/actions, or server components, choose a React framework during analysis and design. For start-from-scratch client apps without those requirements, use Vite.
- Routing: React Router for start-from-scratch routed apps.
- Styling: no fixed visual baseline at the pattern level. Choose the design system, component library, and styling strategy during the analysis and design phases of the real project.
- Local state: component state first, reducer when state transitions become complex.
- Shared client state: Context for stable cross-tree concerns; introduce Zustand, Redux, or another global store only when the application's complexity justifies it.
- Server state: prefer framework data APIs when using a React framework. Otherwise, choose TanStack Query when the project needs caching, invalidation, background refresh, or pagination beyond simple fetch hooks.
- Forms: controlled or native forms for simple cases; choose React Hook Form or another form library during design for complex workflows.
- Testing: Vitest + React Testing Library. Playwright only when browser-level validation is required.

## Project Structure (Feature-First React Frontend)

```text
src/
├── app/
│   ├── providers/                     ← Root providers and app composition
│   ├── router/                        ← Route tree and router setup
│   └── layout/                        ← App shell and shared layout primitives
├── shared/                            ← Reusable UI and general-purpose modules
│   ├── ui/
│   ├── hooks/
│   ├── lib/
│   └── types/
├── features/
│   └── <feature>/
│       ├── domain/                    ← Pure business rules, no React imports
│       │   ├── entities/
│       │   ├── contracts/
│       │   └── use-cases/
│       ├── data/                      ← API access, DTOs, repository adapters
│       │   ├── api/
│       │   ├── dto/
│       │   └── repositories/
│       ├── ui/                        ← Pages, components, feature hooks
│       │   ├── components/
│       │   ├── pages/
│       │   └── hooks/
│       ├── route.tsx
│       └── index.ts
├── styles/
├── main.tsx
└── vite-env.d.ts                      ← When using Vite
```

- Framework-based React projects may adapt the outer project structure to framework conventions, but the separation between `domain/`, `data/`, and `ui/` should remain explicit.

## Decoupling Rules for React

- `domain/` must contain pure TypeScript only. No React imports, browser APIs, routing APIs, or transport libraries.
- `data/` implements contracts defined in `domain/`. It may call HTTP or framework data APIs, but must not import from `ui/`.
- `ui/pages/` and `ui/components/` must not call `fetch`, repository adapters, or transport clients directly.
- `ui/hooks/` may orchestrate use cases, server-state hooks, or repository calls for the owning feature, but presentational components should stay focused on rendering and interaction.
- `app/` owns provider composition, router setup, and app shell concerns. It must not become a dumping ground for feature logic.
- `shared/` contains reusable UI primitives and generic helpers only. Keep feature-specific rules out of it.

## SOLID in React

- **S:** Components render UI. Hooks encapsulate reusable UI behavior or feature orchestration. Repository adapters call transport layers. Use cases express business actions.
- **O:** Extend the app by adding new feature slices, contracts, and adapters instead of editing unrelated global modules.
- **L:** Any adapter implementing a feature contract must be swappable without changing the consumer.
- **I:** Keep contracts, hooks, and providers focused. Split broad repositories or contexts into narrower concerns when consumers do not need everything.
- **D:** High-level feature logic depends on domain contracts and use cases. Concrete API or storage adapters sit at the edge and are wired through composition.

## Design Patterns in React

- **Repository / Adapter:** Define feature contracts in `domain/contracts/` and implement them in `data/repositories/`.
- **Use Case / Service Function:** Represent business actions as pure functions or service modules in `domain/use-cases/`.
- **Custom Hooks:** Encapsulate reusable UI orchestration and component-facing logic in `ui/hooks/`.
- **Reducer:** Use `useReducer` when state transitions are complex or action-based.
- **Context Provider:** Use Context for stable cross-tree dependencies and truly shared state, not as the default storage for everything.
- **Composition over Inheritance:** Prefer component composition and render boundaries over inheritance-based reuse.

## Components, Hooks, and Effects

- Components and hooks must stay pure with respect to rendering.
- Do not mutate objects or variables that existed before render.
- Derive what you can during render instead of storing redundant state.
- Use `useEffect` only to synchronize with external systems. Do not use it for derived values or event-specific logic that belongs in event handlers.
- Prefer lifting state up before introducing global state.
- Use stable keys from domain data when rendering lists.
- Extract reusable logic into custom hooks instead of repeating effect-heavy component code.
- Keep `StrictMode` enabled so React can surface purity and effect problems early.

## State Management

- Start with local component state.
- Lift state up to the closest common owner when multiple components must stay in sync.
- Use `useReducer` for complex local workflows instead of scattering related `useState` calls across handlers.
- Combine reducer and context for complex screen- or feature-level state when necessary.
- Prefer `useSyncExternalStore` or a proper provider wrapper for external mutable sources rather than ad hoc subscriptions in effects.
- Introduce a dedicated global store only when there is proven cross-feature complexity that local state, reducers, and context no longer handle cleanly.

## Data Fetching and Server State

- If the project uses a React framework, prefer the framework's data-loading and mutation model where appropriate.
- In start-from-scratch React apps, simple custom hooks are acceptable for small cases, but non-trivial server state should use a dedicated library such as TanStack Query.
- Do not treat server state as generic client state by default.
- If raw effects are used for fetching, include cleanup logic to avoid race conditions and stale updates.
- Keep transport, caching, retry, and invalidation concerns outside presentational components.

## Routing and Rendering

- Choose the routing and rendering model during analysis and design.
- For full-stack React capabilities, choose a React framework rather than improvising SSR or server components inside a bare client setup.
- For start-from-scratch routed apps, React Router is the default routing library.
- React Router offers declarative, data, and framework modes. Choose the mode that fits the project instead of assuming one globally.
- There is no fixed SSR, SSG, or server-components baseline at the pattern level. Those decisions belong to the real project's analysis and design.

## Styling and Modern Design

- Do not impose a fixed visual baseline from the React pattern itself.
- Define the design system, component baseline, and visual direction during the analysis and design phases of each real project.
- Keep tokens, theme configuration, and shared visual primitives explicit and centralized.
- If the project uses a component library, customize it through supported theming APIs rather than brittle DOM overrides.
- If the project uses utility-first CSS, configure it as an intentional project-level choice.
- Keep reusable primitives in `shared/ui/` and page composition in feature pages.

## Performance and Concurrent UX

- Prefer simple, pure render logic before optimization.
- Do not add `useMemo` or `useCallback` by default. Use them when profiling or API stability requirements justify them.
- Consider `startTransition` or `useDeferredValue` for non-urgent updates when the interaction model benefits from them.
- Split components and keep data locality tight before reaching for broader optimizations.
- If the project adopts React Compiler, follow its conventions and avoid redundant manual memoization where it no longer adds value.

## Naming Conventions

- Feature folders and route segments: `kebab-case`
- Components, pages, and providers: `PascalCase.tsx`
- Hooks: `useSomething.ts`
- Utilities, repositories, and service modules: `camelCase.ts`
- Test files: same base name with `.test.ts` or `.test.tsx`
- Types, interfaces, and enums: `PascalCase`
- Variables, functions, props, and parameters: `camelCase`

## Testing

- Co-locate tests with the code under test.
- Use Vitest as the default unit test runner.
- Use React Testing Library for component tests and favor user-facing assertions over implementation details.
- Test pure domain logic without rendering React.
- Test feature hooks, reducers, and repository adapters in isolation where practical.
- Use browser-mode tests or Playwright only when real browser behavior matters.

## Common Packages

- Build tool: `vite`. Default for non-framework start-from-scratch React apps.
- Routing: `react-router-dom`. Default for routed, non-framework React apps.
- Server state: `@tanstack/react-query`. Optional, when project needs structured server-state management.
- Testing: `vitest`, `@testing-library/react`. Default.
- Browser/e2e testing: `playwright`. Optional.
- Forms: `react-hook-form`, `zod`. Optional, for more complex form workflows.
- Shared client state: built-in React hooks by default; Zustand or Redux only when justified.
- Linting: `eslint-plugin-react-hooks`. Recommended.
