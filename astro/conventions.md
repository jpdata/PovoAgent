# Astro + TypeScript Conventions

## Decision Protocol

When a technology choice, library, or architectural decision is not explicitly defined in the project, **ask the user before assuming**. The question should be asked at the appropriate lifecycle phase:

- **Analysis phase:** site type (marketing site, docs, blog, content hub, ecommerce storefront, support portal, app shell), SEO needs, content update frequency, target deployment model, accessibility level, i18n scope, and backend or CMS boundaries.
- **Design phase:** static vs on-demand rendering, adapter choice, content collections vs live data, Astro-only vs framework islands, React integration needs, authentication approach, view transitions, and UI system decisions.
- **Implementation phase:** which components truly need hydration, which client directives fit each island, middleware and auth requirements, CMS or data loader choice, testing depth, and browser-level validation needs.

**Default choices** (used when the user does not specify):

- Astro: latest stable Astro with TypeScript.
- Bootstrapping: start with `npm create astro@latest`.
- Rendering: static output and prerendering by default. Use on-demand rendering only when the project has clear runtime or freshness requirements.
- Routing: Astro file-based routing under `src/pages/`.
- Content: use content collections with schemas for structured content. Prefer build-time collections; use live collections only when runtime freshness justifies the tradeoff.
- Interactivity: Astro components and plain HTML first. If the project needs interactive islands and the user does not specify a different integration, React via the official Astro integration is the default UI-framework option.
- Navigation: standard browser navigation by default. Use Astro view transitions or `<ClientRouter />` only when the UX requirement justifies extra client-side navigation behavior.
- Styling: no fixed visual baseline at the pattern level. Choose the design system, component library, and styling strategy during the analysis and design phases of the real project.
- Testing: Vitest for utilities and service logic; Playwright for browser flows and hydrated-island behavior when needed.

## Project Structure (Content-First Astro Frontend)

```text
src/
├── pages/                            ← File-based route entry points
├── layouts/                          ← Shared page shells and document structure
├── components/
│   ├── astro/                        ← Static Astro components
│   └── islands/                      ← Shared hydrated framework islands
├── features/
│   └── <feature>/
│       ├── components/               ← Feature-specific Astro components
│       ├── islands/                  ← Feature-specific interactive islands
│       ├── data/                     ← DTOs, API modules, CMS adapters
│       └── services/                 ← Feature loading/orchestration helpers
├── content/                          ← Local content entries for collections
├── lib/                              ← Shared utilities and integrations
├── styles/
├── content.config.ts                 ← Build-time content collections
├── live.config.ts                    ← Optional runtime collections
├── middleware.ts                     ← Optional request handling
└── env.d.ts

public/                               ← Static assets copied as-is
astro.config.mjs                      ← Astro configuration
```

- Route files belong in `src/pages/`, but route files should stay thin and import helpers from `features/`, `lib/`, or `content` APIs.
- Framework islands can live either in shared `components/islands/` or inside their owning feature.

## Decoupling Rules for Astro

- `src/pages/` defines routes and top-level page composition only. Do not bury data-access or CMS logic directly inside route files when it can live in services or adapters.
- `layouts/` own document shell concerns such as metadata, shared head content, top-level structure, and optional navigation behavior.
- Static Astro components belong in `.astro` files and should stay HTML-first.
- Interactive framework components belong in `islands/` and must be hydrated explicitly with the appropriate `client:*` directive.
- Framework components such as React islands must not import `.astro` components directly. Compose them from an Astro parent instead.
- Only serializable props should cross from Astro into hydrated framework components.
- Content collection schemas belong in `src/content.config.ts` or `src/live.config.ts`, not scattered across page files.
- Centralize remote CMS, API, or storage access in `features/*/data`, `features/*/services`, or `lib/` instead of duplicating fetch logic across pages.

## SOLID in Astro

- **S:** Route files define URL entry points. Layouts define shells. Astro components render static sections. Islands own interactive behavior. Services and adapters own content or transport access.
- **O:** Extend the site by adding pages, features, collections, and islands instead of modifying unrelated global files.
- **L:** Any data adapter or loader should be swappable without changing the page or island that consumes its normalized output.
- **I:** Keep helpers, loaders, and integrations focused. Split oversized CMS or API modules when consumers do not need everything.
- **D:** High-level route and page composition should depend on content helpers, service functions, or normalized data shapes rather than raw SDK or transport responses.

## Design Patterns in Astro

- **Islands Architecture:** Keep most of the page static and hydrate only the smallest interactive surfaces.
- **Layout Pattern:** Centralize document shells and repeated structure in `layouts/`.
- **Content Collections:** Use typed collections for repeatable structured content.
- **Service Modules / Loaders:** Move data fetching, content querying, sorting, and normalization out of page files.
- **Adapter / Integration:** Wrap CMS or backend clients in focused modules that pages and islands can consume safely.
- **Progressive Enhancement:** Prefer native HTML, links, forms, and document navigation first; add client behavior only where it materially improves the experience.

## Components, Islands, and Hydration

- Astro components render to static HTML with no client runtime by default.
- Do not hydrate whole pages by default.
- Use `client:load`, `client:idle`, `client:visible`, `client:media`, or `client:only` intentionally based on the real interaction need.
- Prefer `client:idle` or `client:visible` over eager hydration when user experience allows it.
- Keep interactive logic isolated inside the smallest practical island.
- If React is used inside Astro, keep React components framework-local and pass only serializable props from Astro.
- Use plain `<script>` only when a full framework island is not warranted.

## Routing and Rendering

- Astro routing is file-based. Prefer standard `<a>` links over introducing framework-specific link abstractions by default.
- Static generation is the default. Use `getStaticPaths()` for dynamic SSG routes.
- Use on-demand rendering only when the project has runtime data, personalization, or request-time behavior that justifies an adapter.
- Use redirects and rewrites through Astro’s supported configuration and APIs, not through ad hoc client-side workarounds.
- If the project opts into view transitions, validate accessibility and script lifecycle behavior carefully.
- Do not assume `<ClientRouter />` is globally necessary. Native navigation remains the default.

## Content and Data

- Use content collections whenever content or data shares a repeatable schema.
- Provide schemas whenever practical for validation and type safety.
- Prefer build-time collections whenever the content can be fetched or generated ahead of time.
- Use live collections only when freshness matters enough to justify runtime fetching.
- Sort `getCollection()` results explicitly when order matters.
- Keep CMS, API, and transformation logic outside templates and component markup.

## Styling and Modern Design

- Do not impose a fixed visual baseline from the Astro pattern itself.
- Define the design system, visual direction, and component baseline during the analysis and design phases of each real project.
- Keep tokens, typography, and shared primitives explicit and centralized.
- Use Astro’s static-first strengths to ship lean styling and minimal client-side code.
- If the project uses React or another UI framework inside Astro, keep the styling contract consistent across Astro components and islands.

## Performance and Accessibility

- Default to zero-JavaScript pages whenever interaction is not needed.
- Hydrate only the components that genuinely require client-side behavior.
- Prefer native forms, links, and browser navigation unless a richer interaction materially improves the user experience.
- If using view transitions, respect `prefers-reduced-motion`, ensure each page has a meaningful `<title>`, and verify scripts are re-initialized correctly after navigation when needed.
- Keep images, fonts, and content delivery optimized through Astro’s built-in capabilities and integrations when the project chooses them.

## Naming Conventions

- Route files and content folders: `kebab-case`
- Astro components and layouts: `PascalCase.astro`
- Framework islands: `PascalCase.tsx`, `PascalCase.jsx`, or the chosen framework extension
- Utilities, services, and loaders: `camelCase.ts`
- Content collections: lowercase plural names when practical
- Test files: same base name with `.test.ts`, `.test.tsx`, or browser/e2e naming according to the tool in use

## Testing

- Co-locate unit tests with the code they validate.
- Use Vitest for pure utilities, loaders, data normalization, and service logic.
- Use Playwright for route-level validation, navigation flows, and hydrated-island behavior when browser execution matters.
- Keep browser tests focused on user-visible behavior.
- Test Astro route behavior through rendered output and navigation, not internal implementation details.

## Common Packages

- Core: `astro`, `typescript`
- React islands: `@astrojs/react` when React integration is chosen
- MDX content: `@astrojs/mdx` when needed
- SSR adapters: official Astro adapters only when runtime rendering is required
- Testing: `vitest`, `playwright`
- Validation: `zod` through Astro content schemas and project-level validation needs
- Linting and formatting: project-specific choice during design
