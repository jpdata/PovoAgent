# Angular Pattern

## Date

- 2026-04-25

## Why This Change Was Made

- The framework needed a first-class Angular pattern so Angular projects can be deployed with the same lifecycle skills, conventions, and specialized agents already available for Flutter and .NET.
- The new pattern is based on current Angular guidance rather than legacy Angular module-era defaults.
- The deploy experience also needed visible Angular support in the repository documentation and script help text.

## Research Summary

- Angular style guidance favors feature-oriented structure, consistent file naming, `inject()`, focused components, and modern template control flow.
- Current Angular applications use standalone components by default.
- Signals are the default fit for local and feature state, while RxJS remains important for asynchronous streams and backend interaction.
- Angular recommends functional HTTP interceptors for more predictable behavior in complex setups.
- Angular CLI uses Vitest and `jsdom` by default for unit testing in new projects.
- Angular SSR and hybrid rendering are optional and should be introduced only when SEO, first paint, or route-level rendering needs justify them.
- Angular Material provides modern token-based theming, light/dark support via `color-scheme`, and supported customization APIs when a project chooses Material.
- The framework should keep the Angular pattern at the level of general development guidance and defer concrete UI baselines and design-system choices to each real project's analysis and design phases.

## What Changed

- Added a new `angular/` pattern with conventions, specialized agents, and pattern-specific skills.
- Defined modern Angular defaults around standalone APIs, signals, reactive forms, lazy routing, functional interceptors, and optional SSR/hybrid rendering.
- Clarified that the Angular pattern does not prescribe a fixed visual baseline and that project-specific UI decisions belong to the analysis and design of the real project.
- Added Angular to the visible deploy options in `README.md`, `deploy.ps1`, and `deploy.sh`.

## Affected Files

- `angular/conventions.md`
- `angular/agents/angular-architect.agent.md`
- `angular/agents/angular-reviewer.agent.md`
- `angular/skills/angular-scaffold/SKILL.md`
- `angular/skills/angular-feature/SKILL.md`
- `angular/skills/angular-testing/SKILL.md`
- `README.md`
- `deploy.ps1`
- `deploy.sh`
- `.github/copilot-memory.md`
- `Docs/angular-pattern.md`
