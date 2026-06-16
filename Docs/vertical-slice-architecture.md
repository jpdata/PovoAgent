# Vertical Slice Architecture Support

## Date

- 2026-06-16

## Why This Change Was Made

- The PovoAgent framework previously assumed Clean Architecture (CA) with horizontal layers as the default for all patterns. Users needed the ability to choose between Clean Architecture and Vertical Slice Architecture (VSA) during project kickoff.
- VSA organizes code by feature/use-case rather than by technical layer, which is preferred by many teams for simpler projects, faster onboarding, and better cohesion per business capability.
- The kickoff skill now includes diagnostic questions (Question #14) to help users decide between CA and VSA when their preference is unknown.
- The architecture choice propagates through the entire lifecycle: Planning → Analysis → Design → Specification → Scaffold → Implementation → Testing → Review.

## What Changed

### Shared Lifecycle Skills (7 files)

- `skills/kickoff/SKILL.md` — Added Question #14 (architecture style: CA vs VSA) with 4 diagnostic questions. Updated intake doc template to include `**Architecture:** <Clean Architecture | Vertical Slice Architecture>`.
- `skills/analysis/SKILL.md` — Updated workflow step 4 for dual boundary identification. Inputs/outputs now account for architecture style. Dual acceptance criteria, dual decoupling rule.
- `skills/design/SKILL.md` — Added Step 0 "Confirm Architecture Style" with diagnostic questions. Two complete workflow paths: CA (horizontal layers) and VSA (per-slice Mediator/Handler, CQRS). Dual inputs/outputs/acceptance criteria/SOLID/decoupling.
- `skills/specification/SKILL.md` — Metadata table now supports `Layer / Slice` column. Added `Architecture` field. Dual decoupling rule.
- `skills/implementation/SKILL.md` — Step 0 + dual workflow paths. CA: horizontal layer implementation. VSA: each slice gets full vertical stack (endpoint → handler → data access). Dual outputs/acceptance criteria/SOLID.
- `skills/testing/SKILL.md` — Step 0 + dual testing paths. CA: tests per layer. VSA: unit tests per handler, integration tests per endpoint, contract tests for cross-slice boundaries, slice isolation tests. Dual acceptance criteria/decoupling.
- `skills/review/SKILL.md` — Step 0 + dual review paths. CA: inspect by layer. VSA: inspect by slice, validate no cross-slice imports, validate contracts. Dual SOLID/decoupling.

### Pattern Conventions (4 files)

- `dotnet/conventions.md` — Added VSA project structure (`Features/`, `Shared/`, `Contracts/`). Dual Decoupling Rules, dual SOLID. VSA-specific patterns: Handler per operation, FastEndpoints, CQRS, Integration Events, Feature-scoped data access, Slice registration extensions.
- `flutter/conventions.md` — Added VSA project structure (`features/`, `shared/kernel/`, `contracts/events/`). Dual decoupling/SOLID/Design Patterns with VSA-specific patterns.
- `react/conventions.md` — Added VSA project structure with VSA Key Rules. Dual decoupling/SOLID. VSA-specific patterns: Feature-scoped hooks, Feature-scoped API modules, Narrow public API via index.ts, Lazy-loaded routes, Cross-slice events.
- `angular/conventions.md` — Renamed to "Feature-First Clean Frontend" supporting both architectures. Added VSA variant (flat per-action within feature). VSA Key Rules. Dual decoupling.

### Pattern Architect Agents (4 files)

- `dotnet/agents/dotnet-architect.agent.md` — Updated to recommend CA or VSA according to project's architecture style. Added CA and VSA paths.
- `flutter/agents/flutter-architect.agent.md` — Same constraint/approach pattern change.
- `react/agents/react-architect.agent.md` — Updated Non-Negotiable Rules, added full VSA Architecture Layers, updated Lifecycle Phases for both architectures.
- `angular/agents/angular-architect.agent.md` — Updated constraints and approach for both architectures.

### Pattern Scaffold Skills (4 files)

- `dotnet/skills/dotnet-scaffold/SKILL.md` — Pre-scaffold architecture question. CA path labeled. Full VSA path with folder structure, FastEndpoints packages, Program.cs composition, test projects per slice.
- `flutter/skills/flutter-scaffold/SKILL.md` — Pre-scaffold architecture question. CA path labeled. Full VSA path with folder structure, test mirrors per feature.
- `react/skills/react-scaffold/SKILL.md` — Pre-scaffold architecture question. Dual Step 5 (folder structure), dual Step 8 (main.tsx), dual Steps 9-10 (shell + router), dual Decoupling Validation.
- `angular/skills/angular-scaffold/SKILL.md` — Description updated. Pre-scaffold architecture question. Dual Step 3 (folder structure). Dual Decoupling Validation.

### Pattern Feature Skills (4 files)

- `dotnet/skills/dotnet-feature/SKILL.md` — Description VSA-aware. Architecture question. Full VSA path: feature folder with per-operation endpoints, DI extension, VSA test structure. Dual Decoupling Checklist.
- `flutter/skills/flutter-feature/SKILL.md` — Same pattern for Flutter: per-feature slice with models/data/viewmodels/pages/widgets, DI module, VSA tests. Dual Decoupling Checklist.
- `react/skills/react-feature/SKILL.md` — Pre-questions include architecture. Full VSA path: feature folder with entity/api/hooks/page/components, lazy-loaded route. Dual Decoupling Checklist.
- `angular/skills/angular-feature/SKILL.md` — Architecture question added. Full VSA path: flat per-action slice (list/create/detail), lazy-loaded routes. Dual Decoupling Checklist.

### Pattern Testing Skills (4 files)

- `dotnet/skills/dotnet-testing/SKILL.md` — Pre-testing questions. VSA testing: per-endpoint unit tests, per-validator tests, slice integration tests, repository tests, contract tests. Dual Decoupling Validation.
- `flutter/skills/flutter-testing/SKILL.md` — Same pattern: ViewModel/repository/widget/integration/contract tests per slice. Dual Decoupling Validation.
- `react/skills/react-testing/SKILL.md` — Pre-testing questions. VSA testing: hooks/API module/component/page/contract tests per slice. Dual Decoupling Validation.
- `angular/skills/angular-testing/SKILL.md` — Pre-testing questions. VSA testing: service/component/integration/contract tests per action slice. Dual Decoupling Validation.

## Architecture Decision Flow

```
Kickoff Question #14: "¿Qué estilo de arquitectura prefieres?"
  └─ If unknown → 4 diagnostic questions:
       1. Number of entities/aggregates
       2. Team size
       3. Expected project lifetime
       4. Complexity of business rules
  └─ If decided → propagate through lifecycle
       → Planning: architecture noted in PROJECT_PLAN.md
       → Analysis: boundary identification (layers vs slices)
       → Design: CA or VSA path
       → Specification: Layer/Slice column in metadata
       → Scaffold: CA or VSA folder structure
       → Implementation: horizontal layers or vertical e2e
       → Testing: per-layer or per-slice
       → Review: CA or VSA decoupling checklist
```

## Affected Files

- `skills/kickoff/SKILL.md`
- `skills/analysis/SKILL.md`
- `skills/design/SKILL.md`
- `skills/specification/SKILL.md`
- `skills/implementation/SKILL.md`
- `skills/testing/SKILL.md`
- `skills/review/SKILL.md`
- `dotnet/conventions.md`
- `dotnet/agents/dotnet-architect.agent.md`
- `dotnet/skills/dotnet-scaffold/SKILL.md`
- `dotnet/skills/dotnet-feature/SKILL.md`
- `dotnet/skills/dotnet-testing/SKILL.md`
- `flutter/conventions.md`
- `flutter/agents/flutter-architect.agent.md`
- `flutter/skills/flutter-scaffold/SKILL.md`
- `flutter/skills/flutter-feature/SKILL.md`
- `flutter/skills/flutter-testing/SKILL.md`
- `react/conventions.md`
- `react/agents/react-architect.agent.md`
- `react/skills/react-scaffold/SKILL.md`
- `react/skills/react-feature/SKILL.md`
- `react/skills/react-testing/SKILL.md`
- `angular/conventions.md`
- `angular/agents/angular-architect.agent.md`
- `angular/skills/angular-scaffold/SKILL.md`
- `angular/skills/angular-feature/SKILL.md`
- `angular/skills/angular-testing/SKILL.md`
- `.github/copilot-memory.md`
- `Docs/vertical-slice-architecture.md`
