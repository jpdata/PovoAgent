---
name: astro-scaffold
description: 'Scaffold a new Astro project with a modern static-first architecture. Use when creating a new Astro site or app, setting up routing, layouts, content collections, optional React islands, and testing foundations while leaving project-specific UI baseline decisions to analysis and design.'
argument-hint: 'Project name, site type, and main features'
---

# Astro Project Scaffolding

## When to Use
- Creating a new Astro application from scratch.
- Setting up a content-first, static-first project structure with explicit route, content, and island boundaries.
- Configuring layouts, content collections, optional React islands, and testing foundations while leaving project-specific UI baseline decisions to analysis and design.

## Procedure

1. **Define key decisions before scaffolding**
   - Ask the user if these are unclear: site type, content update frequency, static vs on-demand rendering, adapter needs, CMS source, React islands or Astro-only approach, i18n, auth, view transitions, and UI system.
   - Do not impose a fixed visual baseline from the Astro pattern. The real project's analysis and design phases must decide the design system, visual direction, and shared UI primitives.

2. **Scaffold the base project**
   ```bash
   npm create astro@latest
   ```
   - Use TypeScript.
   - Keep the project static-first unless the project requirements clearly demand on-demand rendering.

3. **Add the selected integrations**
   - If the project needs React islands, install the official React integration.
   - Add MDX, sitemap, or deployment adapters only when the project requirements justify them.
   - Do not preload unnecessary framework integrations just because Astro supports them.

4. **Set up the project structure**
   ```text
   src/
   ├── pages/
   ├── layouts/
   ├── components/
   │   ├── astro/
   │   └── islands/
   ├── features/
   ├── content/
   ├── lib/
   ├── styles/
   ├── content.config.ts
   └── env.d.ts
   ```

5. **Create base application files**
   - `src/layouts/BaseLayout.astro` — document shell and shared structure
   - `src/pages/index.astro` — first route entry
   - `src/components/astro/` — shared static UI pieces
   - `src/components/islands/` — shared interactive islands, only if needed
   - `src/lib/env.ts` or project-equivalent — environment and configuration helpers
   - `src/styles/` — global tokens, theme setup, and app-level styles
   - `src/content.config.ts` — structured content collections when needed

6. **Set up content and data foundations**
   - Use content collections when the project has repeatable structured content.
   - Add schemas for collections whenever practical.
   - Keep content loading and transformation logic out of route templates.

7. **Set up the chosen interaction model**
   - Keep Astro components static by default.
   - Add hydrated islands only for components that truly require interactivity.
   - If React is used, keep it inside explicit islands instead of turning the entire site into a React app by default.
   - Use view transitions only if the project explicitly benefits from them.

8. **Set up testing foundations**
   - Add Vitest for services, helpers, and data transformation logic.
   - Add Playwright only if the project needs route-level or browser-level validation.
   - Keep tests co-located with the code they validate where practical.

9. **Verify**
   - Run `npm install`.
   - Run `npm run build` — no errors.
   - Run `npx vitest run` if unit tests are configured.
   - Run browser tests only if the project has configured them.

## Decoupling Validation
- Route files remain thin and focused on route composition.
- Static Astro components stay static unless there is a clear need for hydration.
- Framework islands are explicit and minimal.
- Content schemas live in collection config files instead of being duplicated.
- CMS or API logic lives in services or adapters, not scattered through templates.

## Reference
- Refer to `conventions.md` in the project root for Astro conventions.