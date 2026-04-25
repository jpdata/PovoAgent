# Angular + TypeScript Conventions

## Decision Protocol

When a technology choice, library, or architectural decision is not explicitly defined in the project, **ask the user before assuming**. The question should be asked at the appropriate lifecycle phase:

- **Analysis phase:** app type (dashboard, public site, back-office, PWA), SEO/SSR needs, target browsers, accessibility level.
- **Design phase:** rendering mode (CSR / SSR / hybrid), UI system (Angular Material / custom design system / utility-first CSS), authentication approach, i18n needs, and route strategy.
- **Implementation phase:** state strategy (signals-only vs NgRx), form system (Reactive Forms vs Signal Forms), test depth (unit only vs browser/e2e), and API concerns such as auth headers, caching, or retry policies.

**Default choices** (used when the user does not specify):

- Angular: latest stable Angular CLI defaults.
- Components: standalone components and standalone routing.
- Styling: `SCSS`.
- Rendering: CSR by default. Use SSR/hybrid rendering only when SEO, first paint, or route-level rendering requirements justify it.
- State management: Angular signals for local and feature state, RxJS for async streams and external event composition.
- UI system: no fixed visual baseline at the pattern level. Choose Angular Material, a custom design system, or another UI approach during the analysis and design phases of the real project.
- Forms: Reactive Forms.
- HTTP: `HttpClient` with functional interceptors.
- Testing: Angular CLI unit testing with Vitest + `jsdom`; browser/e2e testing only when explicitly required.

## Project Structure (Feature-First Clean Frontend)

```text
src/
├── app/
│   ├── app.config.ts                     ← Root providers
│   ├── app.routes.ts                     ← Root routes
│   ├── core/                             ← Singleton app services and shell concerns
│   │   ├── config/
│   │   ├── http/
│   │   │   ├── interceptors/
│   │   │   └── tokens/
│   │   ├── layout/
│   │   ├── guards/
│   │   └── services/
│   ├── shared/                           ← Reusable UI and pure utilities
│   │   ├── ui/
│   │   ├── pipes/
│   │   ├── directives/
│   │   └── utils/
│   └── features/
│       └── <feature>/
│           ├── domain/                   ← Pure business rules, no Angular imports
│           │   ├── entities/
│           │   ├── ports/
│           │   └── use-cases/
│           ├── data/                     ← DTOs, API clients, repository implementations
│           │   ├── access/
│           │   ├── dto/
│           │   └── repositories/
│           ├── ui/                       ← Presentation layer for the feature
│           │   ├── components/
│           │   ├── pages/
│           │   └── store/
│           ├── <feature>.routes.ts
│           └── index.ts
├── assets/
├── styles.scss
└── main.ts
```

## Decoupling Rules for Angular

- `domain/` must contain pure TypeScript only. No Angular decorators, `inject()`, `HttpClient`, router, or browser APIs.
- `data/` implements ports defined in `domain/`. It may use Angular HTTP and DI, but must not import from `ui/`.
- `ui/` depends on feature state, use cases, or domain models. It must not call API clients directly.
- `core/` holds app-wide providers, interceptors, layout shell, and bootstrap concerns. It must not become a dumping ground for feature logic.
- `shared/` contains reusable presentation utilities and components. Keep feature-specific rules out of it.
- Route configuration should lazy-load feature entry points to keep boundaries explicit and bundles smaller.

## SOLID in Angular

- **S:** Components render UI. Facades/stores coordinate state. Repository implementations call APIs. Use cases express business actions.
- **O:** Add features by creating new slices, tokens, and use cases instead of editing unrelated shells.
- **L:** Any implementation provided for a domain port must be swappable without changing the consumer.
- **I:** Keep ports, facades, and services focused. Split read and write responsibilities when consumers do not need both.
- **D:** High-level feature logic depends on domain ports and use cases. Concrete data services are bound through DI using tokens.

## Design Patterns in Angular

- **Repository / Port Adapter:** Define feature ports in `domain/ports/` and implement them in `data/repositories/`.
- **Use Case / Interactor:** Model each business action in `domain/use-cases/` as a focused class or pure service.
- **Facade / Store:** Expose readonly signals and methods from `ui/store/` so components stay presentation-focused.
- **Dependency Injection:** Prefer `inject()` over constructor injection when it improves readability and keeps setup close to usage.
- **Adapter:** Wrap third-party SDKs, browser APIs, and backend peculiarities behind services in `core/` or `data/`.
- **Observer / Reactive State:** Use `signal`, `computed`, and `effect` for local or feature state; use RxJS where asynchronous composition is the real concern.

## Domain Ports and Tokens

- TypeScript interfaces disappear at runtime, so DI-facing domain ports must be represented with an abstract class or an `InjectionToken`.
- Keep the port definition in `domain/ports/` and bind it in feature providers.
- Prefer one token per clear responsibility rather than one broad service contract.

## Components and Templates

- Prefer standalone components. Angular creates standalone components by default in current versions.
- Default to `ChangeDetectionStrategy.OnPush` for predictable rendering.
- Keep templates declarative and move non-trivial logic into `computed()` or named methods.
- Prefer Angular's modern control flow blocks: `@if`, `@for`, `@switch`, and `@empty`.
- Always provide a stable `track` expression in `@for` blocks, typically `id` or another unique key.
- Prefer `class` and `style` bindings over `NgClass` and `NgStyle`.
- Use `protected` for members used only by the template and `readonly` for Angular-managed inputs, outputs, models, and queries.

## State Management

- Use signals as the default state model for components and feature facades.
- Expose readonly signals from stores or facades and keep writable signals private.
- Use `computed()` for derived state and keep `effect()` for integration with non-reactive APIs.
- Read signals before asynchronous boundaries inside effects to avoid losing dependency tracking.
- Use RxJS for streams from `HttpClient`, websockets, router events, or complex orchestration. Convert to signals at the UI boundary when helpful.
- Introduce NgRx only if the application has proven cross-feature complexity, advanced devtools requirements, or event-heavy workflows that justify it.

## Routing

- Configure routing with `provideRouter(...)` in `app.config.ts`.
- Prefer route-level lazy loading with `loadChildren` or `loadComponent`.
- Use `withComponentInputBinding()` when route params, query params, or resolved data belong directly on component inputs.
- Define a wildcard `**` route for 404 handling.
- Keep route guards and resolvers in `core/` or inside the owning feature, not in shared UI folders.

## Forms

- Prefer Reactive Forms for scalability, explicit state, validation reuse, and easier testing.
- Use template-driven forms only for very small, low-complexity inputs.
- Consider Signal Forms only when the project explicitly opts into that approach and the Angular version supports it in the target environment.
- Keep validation logic in reusable validators or feature services rather than embedding business rules in templates.

## HTTP and Backend Communication

- Use `provideHttpClient()` in root providers.
- Prefer functional interceptors with `withInterceptors(...)` because Angular recommends them for more predictable behavior in complex setups.
- Keep DTOs separate from domain entities.
- Map transport responses in the data layer before they reach the UI.
- Centralize auth, caching, retry, deadline, and logging concerns in interceptors or data-access services.
- Use typed requests and responses consistently.

## SSR, Hydration, and Rendering Modes

- Use `@angular/ssr` only when SEO, first paint, or route-specific rendering modes justify the extra complexity.
- For SSR or hybrid rendering, keep browser-only code behind safe boundaries and prefer platform-specific providers over ad hoc browser checks.
- Avoid direct `window`, `document`, `navigator`, or `location` access in shared code. Inject `DOCUMENT` or use render hooks where appropriate.
- Keep server and browser markup consistent to avoid hydration mismatches.
- Use static prerendering for public routes that do not need user-specific data.

## Styling and Modern Design

- Use SCSS tokens, CSS custom properties, and a deliberate theme system from the start.
- Do not impose a fixed visual baseline from the Angular pattern itself. Define the design system, visual direction, and component baseline during the analysis and design phases of each real project.
- If Angular Material is chosen for a project, use a custom theme via `mat.theme(...)`, explicit `color-scheme`, and token-based overrides rather than unsupported DOM-level CSS overrides.
- Enable strong focus indicators when accessibility needs demand them.
- Use Angular Material theming APIs or design tokens to customize components; avoid relying on internal DOM structure.
- Keep reusable visual primitives in `shared/ui/` and page composition in feature pages.
- If the user wants a utility-first workflow, ask before introducing Tailwind or a similar tool.

## Naming Conventions

- Files: `kebab-case.ts`, `kebab-case.html`, `kebab-case.scss`
- Test files: same file name with `.spec.ts`
- Classes, types, enums: `PascalCase`
- Variables, methods, properties: `camelCase`
- Component selectors: use the project prefix consistently
- Feature folders: `kebab-case`

## Testing

- Co-locate unit test files with the code under test using `.spec.ts`.
- Angular CLI defaults to Vitest + `jsdom` for unit testing in new projects.
- Test domain logic without rendering Angular.
- Test data-access services with `provideHttpClientTesting()`.
- Test components with mocked facades/use cases rather than real repositories.
- Use browser-mode tests or Playwright only for scenarios that truly depend on browser APIs or full flows.

## Common Packages

- UI framework: `@angular/material`, `@angular/cdk`. Optional, when chosen in design.
- Styling: `SCSS`. Default.
- State: Angular `signal`, `computed`, `effect`. Default.
- Async composition: `rxjs`. Built-in Angular ecosystem.
- HTTP: `HttpClient`. Default.
- Interceptors: functional interceptors + `withInterceptors`. Preferred.
- Forms: `ReactiveFormsModule`. Default.
- Rendering: `@angular/ssr`. Ask before adding.
- Testing: `vitest`, `jsdom` via Angular CLI. Default.
- Browser/e2e testing: Playwright. Optional.
- Localization: `@angular/localize`. Ask.
