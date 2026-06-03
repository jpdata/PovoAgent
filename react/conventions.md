# React + TypeScript Conventions

## Decision Protocol

When a technology choice or architectural decision is not explicitly defined in the project, **ask the user before assuming**. Ask at the appropriate phase:

- **Analysis phase:** App type (SPA / SSR / SSG), SEO requirements, authentication method, back-end API shape (REST / GraphQL), target browsers, accessibility level.
- **Design phase:** Framework (Vite SPA vs Next.js), routing mode, authentication flow, form complexity, i18n needs, SSR requirements.
- **Implementation phase:** Error boundary strategy, custom theming tokens, additional Zustand slices, optimistic updates strategy.

**Default choices** (used when the user does not specify):

| Concern            | Default                                   |
|--------------------|-------------------------------------------|
| Build              | Vite + React + TypeScript (strict)        |
| Styling            | Tailwind CSS v4                           |
| Components         | shadcn/ui (headless + Tailwind)           |
| Server state       | TanStack Query v5                         |
| Client state       | Zustand                                   |
| Routing            | React Router v7                           |
| HTTP client        | Axios                                     |
| Schema validation  | Zod (Application layer only)              |
| Forms              | React Hook Form + Zod resolver            |
| Testing            | Vitest + React Testing Library + MSW      |
| Linting            | ESLint (flat config) + Prettier           |

## Project Structure (Clean Architecture for React)

The project uses four global layers. The `presentation/` layer is **globally swappable** — it can be replaced entirely without modifying any other layer.

```text
src/
├── presentation/                      ← SWAPPABLE — pure UI, Tailwind, shadcn/ui
│   ├── components/
│   │   ├── ui/                        ← Design system primitives (shadcn/ui + Tailwind)
│   │   └── {feature}/                 ← Feature-scoped presentational components
│   ├── layouts/                       ← Layout shells (sidebar, header, page frame)
│   └── pages/                         ← Route entry points: compose layout + components + view-model
├── application/                       ← Business logic as custom hooks
│   ├── use-cases/                     ← useXxxUseCase hooks: orchestrate domain + infra calls
│   ├── store/                         ← Zustand slices for client-owned state
│   ├── interfaces/                    ← TypeScript repository and service contracts
│   └── types/                         ← Application DTOs and request/response shapes
├── domain/                            ← Pure TypeScript, zero framework dependencies
│   ├── entities/                      ← Domain entity interfaces and types
│   └── validators/                    ← Pure validation functions, no side effects
├── infrastructure/                    ← Implements Application contracts
│   ├── http/                          ← Axios instance, interceptors, auth token injection
│   ├── repositories/                  ← Concrete IXxxRepository implementations
│   └── adapters/                      ← Pure functions: ApiXxxDto → XxxEntity
└── main.tsx                           ← Bootstrap: providers, router, DI wiring
```

## Decoupling Rules

```
Presentation  ──►  Application  ──►  Domain
Infrastructure ──►  Application  ──►  Domain
Presentation  ✗──►  Infrastructure   (FORBIDDEN)
Infrastructure ✗──►  Presentation    (FORBIDDEN)
Application   ✗──►  Presentation    (FORBIDDEN)
```

**Detailed rules:**

- `domain/` contains pure TypeScript only. No React, no Axios, no Zustand, no library imports.
- `domain/validators/` returns `{ valid: boolean; errors: string[] }`. No Zod schemas in this layer.
- `application/use-cases/` hooks orchestrate domain rules and call `application/interfaces/` contracts. They never import from `presentation/`.
- `application/interfaces/` defines TypeScript contracts (`IUserRepository`). It never provides implementations.
- `infrastructure/repositories/` implements `application/interfaces/` contracts. No UI imports.
- `infrastructure/adapters/` are pure functions with no side effects.
- `presentation/components/` receive all data and actions via **props only**. No direct imports from `infrastructure/` or `application/use-cases/`.
- `presentation/pages/` wire the use-case hook output to the component tree. This is the **only** place where hooks and components are connected.

**Swappability test:** A different design system can replace `src/presentation/` without any changes in `application/`, `domain/`, or `infrastructure/`.

## SOLID in React

- **S:** Each component renders one concern. Each hook manages one use case. Each repository targets one aggregate. Validators validate one entity.
- **O:** New features add new hooks, components, repositories, and entities. Existing ones are not modified for unrelated requirements.
- **L:** Hooks and repositories implementing the same interface are interchangeable. A mock repository replacing a real one must satisfy all consumers.
- **I:** Props interfaces contain only what the component uses. Repository interfaces split by read and write concerns when consumers differ.
- **D:** Pages depend on use-case hook outputs (abstractions). They never import concrete repositories or HTTP clients.

## Design Patterns in React

- **Repository pattern:** `application/interfaces/IXxxRepository.ts` defines the contract. `infrastructure/repositories/xxx-repository.ts` implements it.
- **Use Case / View Model Hook:** `application/use-cases/use-xxx-use-case.ts` — a custom hook that encapsulates one business operation and returns the view-model the page needs.
- **Adapter pattern:** `infrastructure/adapters/xxx-adapter.ts` — pure function mapping API DTO → domain entity.
- **Strategy via props:** Pass the use-case hook result into the component tree via props to allow the same components to work with different data sources.
- **Composition over inheritance:** Build complex UI by composing small, focused presentational components. No class inheritance in React components.

## Presentation Layer Conventions

### Components

- Presentational components are pure functions. They render props and call callback props. No business logic.
- `presentation/components/ui/` — shadcn/ui primitives installed with `npx shadcn@latest add <component>`. These are owned source files, not black-box npm imports.
- `presentation/components/{feature}/` — Feature-scoped presentational components. Named by feature (`UserCard`, `OrderSummary`).
- Components with visual variants use `cva()` (class-variance-authority). No scattered conditional class strings.
- All conditional class merging uses `cn()` (clsx + tailwind-merge).

### Tailwind CSS

- All layout, spacing, typography, and color uses Tailwind utility classes.
- No `style=` attributes that duplicate Tailwind utilities.
- No hardcoded color hex/rgb values — use Tailwind theme tokens (`text-primary`, `bg-background`).
- Responsive design uses Tailwind breakpoint prefixes: `sm:`, `md:`, `lg:`, `xl:`.
- Dark mode via `dark:` prefix and a `ThemeProvider` wrapping the app.
- Custom tokens defined in `tailwind.config.ts` under `theme.extend`.

### Layouts

- `presentation/layouts/` contains layout shells only (header, sidebar, footer, main frame).
- Layouts accept a `children` prop. They do not fetch data.
- Pages choose which layout to render.

### Pages

- `presentation/pages/` contains one file per route (`UsersPage.tsx`, `UserDetailPage.tsx`).
- A page's job: call the use-case hook(s), pass the result down as props to components.
- A page may handle navigation (`useNavigate`) and URL parameters (`useParams`), since routing is a presentation concern.

## Application Layer Conventions

### Use-Case Hooks

```ts
// application/use-cases/use-get-users.ts
export function useGetUsers() {
  const repo = useUserRepository(); // injected via context
  return useQuery({
    queryKey: ['users'],
    queryFn: () => repo.getAll(),
  });
}
```

- One hook = one use case.
- Named `useXxxUseCase` or `useGetXxx` / `useCreateXxx` for clarity.
- Mutations use TanStack Query `useMutation` with `onSuccess` cache invalidation.
- The hook returns data, loading state, and action functions — the page's complete view-model.

### Zustand Store

- One slice per domain concern (`useUserStore`, `useCartStore`).
- Slice file: `application/store/user-store.ts`.
- Client state only: UI-owned state (filters, selection, pagination cursor). Never cache server data here.
- Exported as a hook: `export const useUserStore = create<UserStore>(...)`.

### Interfaces

```ts
// application/interfaces/i-user-repository.ts
export interface IUserRepository {
  getAll(): Promise<UserEntity[]>;
  getById(id: string): Promise<UserEntity>;
  create(data: CreateUserDto): Promise<UserEntity>;
}
```

- Named `IXxxRepository` or `IXxxService`.
- Only defines the contract. No implementation details.

## Domain Layer Conventions

### Entities

```ts
// domain/entities/user-entity.ts
export interface UserEntity {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}
```

- Pure TypeScript interfaces or types. No classes required.
- No library imports (`zod`, `axios`, `react`).

### Validators

```ts
// domain/validators/user-validator.ts
export function validateCreateUser(
  input: unknown
): { valid: boolean; errors: string[] } { ... }
```

- Pure functions, no side effects.
- Zod schemas that power validators live in `application/types/` and call these validator functions.

## Infrastructure Layer Conventions

### HTTP Client

```ts
// infrastructure/http/axios-instance.ts
export const httpClient = axios.create({ baseURL: import.meta.env.VITE_API_URL });
httpClient.interceptors.request.use(authInterceptor);
```

- Single Axios instance. Auth token injected via request interceptor.
- Response errors normalized via response interceptor.

### Repositories

```ts
// infrastructure/repositories/user-repository.ts
export class UserRepository implements IUserRepository {
  async getAll(): Promise<UserEntity[]> {
    const { data } = await httpClient.get<ApiUserDto[]>('/users');
    return data.map(adaptUser);
  }
}
```

- One class per repository. Implements the interface from `application/interfaces/`.
- Uses the Axios instance from `infrastructure/http/`.
- Calls the adapter to transform API DTOs.

### Adapters

```ts
// infrastructure/adapters/user-adapter.ts
export function adaptUser(dto: ApiUserDto): UserEntity {
  return { id: dto.id, name: dto.name, email: dto.email, createdAt: new Date(dto.created_at) };
}
```

- Pure functions. Input: API DTO. Output: domain entity.

## Dependency Injection Pattern

Repositories are injected via React Context, not imported directly.

```ts
// main.tsx (or a dedicated provider file)
const userRepo = new UserRepository();
<UserRepositoryContext.Provider value={userRepo}>
  <App />
</UserRepositoryContext.Provider>
```

```ts
// application/use-cases/use-get-users.ts
const repo = useContext(UserRepositoryContext);
```

- Context providers are created near the repository class.
- In testing, substitute the real repository with a mock that implements the same interface.

## Naming Conventions

| Artifact           | Convention              | Example                         |
|--------------------|-------------------------|---------------------------------|
| Component          | `PascalCase.tsx`        | `UserCard.tsx`                  |
| Page               | `PascalCase.tsx`        | `UsersPage.tsx`                 |
| Hook               | `use-xxx.ts`            | `use-get-users.ts`              |
| Hook export        | `useXxx`                | `useGetUsers`                   |
| Repository file    | `xxx-repository.ts`     | `user-repository.ts`            |
| Adapter file       | `xxx-adapter.ts`        | `user-adapter.ts`               |
| Interface          | `i-xxx-repository.ts`   | `i-user-repository.ts`          |
| Domain entity      | `xxx-entity.ts`         | `user-entity.ts`                |
| DTO                | `xxx-dto.ts`            | `create-user-dto.ts`            |
| Store              | `xxx-store.ts`          | `user-store.ts`                 |
| Test file          | same base + `.test.*`   | `user-validator.test.ts`        |
| Folders            | `kebab-case`            | `use-cases/`, `user-detail/`    |
| Type / Interface   | `PascalCase`            | `UserEntity`, `IUserRepository` |
| Variables / props  | `camelCase`             | `userId`, `onSubmit`            |

## Testing

- Co-locate test files with the code they validate.
- `domain/validators/` — pure TypeScript tests, no React rendering.
- `application/use-cases/` — hook tests with `renderHook` + MSW for API mocking.
- `infrastructure/repositories/` — test with MSW; verify adapter transforms.
- `presentation/components/` — React Testing Library, user-facing assertions.
- `presentation/pages/` — integration tests with mock repository context.

## Common Packages

| Package                        | Purpose                             |
|--------------------------------|-------------------------------------|
| `vite`                         | Build tool                          |
| `react`, `react-dom`           | UI framework                        |
| `typescript`                   | Type safety (strict mode)           |
| `tailwindcss` v4               | Utility-first styling               |
| `@shadcn/ui` (via CLI)         | Component primitives                |
| `class-variance-authority`     | Component variant management        |
| `clsx` + `tailwind-merge`      | Class name composition (`cn()`)     |
| `react-router-dom` v7          | Routing                             |
| `@tanstack/react-query` v5     | Server state management             |
| `zustand`                      | Client state management             |
| `axios`                        | HTTP client                         |
| `zod`                          | Schema validation (Application layer)|
| `react-hook-form`              | Form state management               |
| `@hookform/resolvers`          | Zod integration for forms           |
| `vitest`                       | Unit test runner                    |
| `@testing-library/react`       | Component testing                   |
| `msw`                          | API mocking in tests                |
| `eslint` (flat config)         | Linting                             |
| `prettier`                     | Code formatting                     |

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
