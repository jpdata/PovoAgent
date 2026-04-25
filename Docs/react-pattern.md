# React Pattern

## Date

- 2026-04-25

## Why This Change Was Made

- The framework needed a first-class React pattern so React projects can be deployed with the same lifecycle skills, conventions, and specialized agents already available for Flutter, .NET, and Angular.
- The React pattern needed to reflect current React guidance without hard-coding framework-specific or UI-baseline decisions that belong to each real project's analysis and design.
- The deploy experience also needed visible React support in repository documentation and script help text.

## Research Summary

- React's current guidance emphasizes pure components and hooks, predictable data flow, lifting state up, reducers for complex state transitions, and avoiding unnecessary effects.
- React recommends starting new apps with a framework when the project needs full-stack React capabilities, while start-from-scratch React remains valid with tools such as Vite when those features are not required.
- React Router v7 supports multiple modes, making routing strategy a project-level design choice rather than a universal default for every React app.
- TanStack Query is a strong option for non-trivial server-state management in start-from-scratch React projects.
- Vitest and React Testing Library provide a modern testing baseline for React projects.
- The pattern should stay at the level of general React development guidance and defer fixed design-system or visual-baseline decisions to each real project's analysis and design phases.

## What Changed

- Added a new `react/` pattern with conventions, specialized agents, and pattern-specific skills.
- Defined modern React guidance around pure rendering, feature-first boundaries, state ownership, hooks, routing decisions, server-state strategy, and testing.
- Clarified that the React pattern does not prescribe a fixed visual baseline or framework path at the pattern level.
- Added React to the visible deploy options in `README.md`, `deploy.ps1`, and `deploy.sh`.

## Affected Files

- `react/conventions.md`
- `react/agents/react-architect.agent.md`
- `react/agents/react-reviewer.agent.md`
- `react/skills/react-scaffold/SKILL.md`
- `react/skills/react-feature/SKILL.md`
- `react/skills/react-testing/SKILL.md`
- `README.md`
- `deploy.ps1`
- `deploy.sh`
- `.github/copilot-memory.md`
- `Docs/react-pattern.md`
