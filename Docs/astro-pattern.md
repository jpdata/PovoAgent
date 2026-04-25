# Astro Pattern

## Date

- 2026-04-25

## Why This Change Was Made

- The framework needed a first-class Astro pattern so Astro projects can be deployed with the same lifecycle skills, conventions, and specialized agents already available for Flutter, .NET, Angular, and React.
- Astro needed to be added as an option alongside React, not as a replacement for it. The pattern therefore needed to support Astro's static-first model while allowing optional React islands when a project truly needs them.
- The deploy experience also needed visible Astro support in repository documentation and script help text.

## Research Summary

- Astro is static-first and built around file-based routing, layouts, and islands architecture.
- Astro supports official React integration, allowing React components to be used as selective interactive islands instead of turning the whole site into a client-side React app.
- Content collections with schemas are a strong default for structured content, while live collections and on-demand rendering are better reserved for runtime freshness needs.
- Standard browser navigation remains the default, while view transitions and `<ClientRouter />` are optional enhancements that require intentional use.
- The pattern should stay at the level of general Astro development guidance and defer fixed design-system or visual-baseline decisions to each real project's analysis and design phases.

## What Changed

- Added a new `astro/` pattern with conventions, specialized agents, and pattern-specific skills.
- Defined Astro guidance around static-first rendering, file-based routing, layouts, content collections, selective hydration, and optional React islands.
- Clarified that the Astro pattern does not prescribe a fixed visual baseline and does not force React integration unless a real project needs it.
- Added Astro to the visible deploy options in `README.md`, `deploy.ps1`, and `deploy.sh`.

## Affected Files

- `astro/conventions.md`
- `astro/agents/astro-architect.agent.md`
- `astro/agents/astro-reviewer.agent.md`
- `astro/skills/astro-scaffold/SKILL.md`
- `astro/skills/astro-feature/SKILL.md`
- `astro/skills/astro-testing/SKILL.md`
- `README.md`
- `deploy.ps1`
- `deploy.sh`
- `.github/copilot-memory.md`
- `Docs/astro-pattern.md`
