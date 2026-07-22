# Framework AI Enhancement Phase

## Status

- Active since 2026-04-25.

## Purpose

- Track changes to the Framework core AI files in a consistent place.
- Make repository-wide AI behavior updates auditable across sessions.
- Keep implementation changes and their rationale discoverable for future maintenance.

## Scope

- Workspace instructions under `.github/`.
- Workspace agents under `.github/agents/`.
- Platform instructions under `platforms/`.
- Shared templates under `templates/`.
- Shared lifecycle skills under `skills/`.
- Pattern agents and skills under `dotnet/` and `flutter/`.
- Deploy scripts or related repository files that define or distribute Framework AI behavior.

## Rules

- Any upgrade or update to Framework core AI files must include documentation in `Docs/`.
- Documentation must be written in English.
- Each documentation entry should state what changed, why it changed, and which files were affected.
- Documentation should be created or updated in the same task as the code or instruction change.

## Documented Updates

### 2026-06-05 - OpenCode MCP config schema migration

- Updated `platforms/opencode/opencode.json` MCP server entries from legacy format to current OpenCode schema.
- Replaced `command` string + `args` array with a single `command` array for local MCP servers.
- Replaced `env` with `environment` for the GitHub MCP server.
- Added `enabled: true` to each MCP server entry.
- Why: prevent `ConfigInvalidError` startup failures (`Expected array, got "npx"`) in projects generated from this template.
- Affected files: `platforms/opencode/opencode.json`, `Docs/framework-ai-enhancement-phase.md`.

### 2026-06-16 - Evolutionary lifecycle support added

- Added `skills/change-intake/SKILL.md`: guided intake conversation for work on existing projects (features, modifications, bug fixes, refactors). Routes to appropriate lightweight workflow.
- Added `templates/change-request.md`: template for feature, modification, and refactor change requests.
- Added `templates/bug-report.md`: template for bug reports with diagnosis, fix strategy, and verification.
- Added `Docs/evolutionary-lifecycle.md`: documents the four lightweight workflows (Feature 4-phase, Modification 3-phase, Bug Fix 4-phase, Refactor 4-phase) with Mermaid diagrams, phase tables, and comparison to the new-project lifecycle.
- Updated `templates/povo.agent.md` and `templates/opencode/povo.agent.md`: `change-intake` added to lifecycle skills; "Existing Project" workflow updated to start with `change-intake` and route by change type.
- Updated `.github/copilot-memory.md` with new evolutionary lifecycle conventions.
- Why: the framework was strong for greenfield (new projects) but lacked a structured entry point and lightweight workflows for brownfield work (evolutionary features, corrections, refactors on existing projects).
- Affected files: `skills/change-intake/SKILL.md`, `templates/change-request.md`, `templates/bug-report.md`, `Docs/evolutionary-lifecycle.md`, `Docs/framework-ai-enhancement-phase.md`, `templates/povo.agent.md`, `templates/opencode/povo.agent.md`, `.github/copilot-memory.md`.

### 2026-06-20 - Assessment Workflow added to Evolutionary Lifecycle

- Added **"Assessment"** as a new change type in `skills/change-intake/SKILL.md`, alongside Feature, Modification, Bug Fix, and Refactor. Produces `ASSESSMENT_REPORT.md`.
- Extended `skills/analysis/SKILL.md` into **two modes**: Mode 1 (New Project Analysis, original behavior) and **Mode 2 (Existing Project Assessment)**. Mode 2 performs a systematic audit across 7 steps: Confirm Scope → Gather Context → Architecture Assessment → Technical Assessment → Flow Assessment → Prioritize & Produce Report → Generate Change Requests.
- Created `templates/assessment-report.md` — template with Executive Summary, Health Summary (1-5 rating per dimension), Architecture/Technical/Flow Findings tables (severity, category, location, finding, recommendation), Prioritized Recommendations (Critical/High/Medium/Low), and Generated Change Requests table.
- Added **Workflow E — Assessment** to `Docs/evolutionary-lifecycle.md` with updated Mermaid diagram (WF5 subgraph), phase table (3 phases + optional CRs), assessment dimensions table, severity levels table, and updated Comparison and Documents Produced tables.
- Created `Docs/assessment-workflow.md` — comprehensive documentation including workflow diagram, phase breakdown, assessment dimensions in detail (what to check per dimension), severity classification with examples, from-findings-to-execution flow, example conversation, cross-platform/pattern notes, and relationship to other skills.
- Assessment routes: Change Intake (Assessment) → Analysis (Mode 2) → Review Validation → Generate CRs (optional) → Execution per CR.
- Severity levels: **Critical** (security/data loss/architecture blocks → fix now + generate CR), **High** (significant debt/bottleneck/SOLID → current cycle + generate CR), **Medium** (localized code quality → next cycle, optional CR), **Low** (minor improvement → document, no CR).
- Why: the framework had structured entry points for specific changes (features, modifications, bug fixes, refactors) but lacked a holistic audit capability for discovering what should change. The Assessment workflow fills this gap with a divergent-then-convergent methodology.
- Affected files: `skills/change-intake/SKILL.md`, `skills/analysis/SKILL.md`, `templates/assessment-report.md`, `Docs/evolutionary-lifecycle.md`, `Docs/assessment-workflow.md`.

### 2026-06-20 - Project Cache (PROJECT_CACHE.md) mechanism added

- Created `templates/project-cache.md` — structured, machine-readable snapshot template with 7 sections: Metadata, Architecture Map (CA layers or VSA slices + contracts + dependency graph + shared kernel), Domain Map (aggregate roots, domain services, business rules summary), File Index (config, entry points, key directories with file counts, test files), Key Decisions & Constraints, and Cache Refresh Log.
- Updated `skills/analysis/SKILL.md` Mode 2 with **Step 2 (Gather Context)**: reads `PROJECT_CACHE.md` first if it exists and is fresh, using it as the primary source for architecture map, domain map, and file index.
- Updated `skills/analysis/SKILL.md` Mode 2 with **Step 8 (Generate/Update Project Cache)**: new step that produces or updates `PROJECT_CACHE.md` after the Assessment Report is approved. Populates all sections per architecture style. Sets stale date (Last Updated + 30 days). Records assessment ID for traceability. Cache freshness: Fresh ≤30 days (all skills skip redundant scans); Stale >30 days (warn user, suggest re-assessment); Invalidated (fall back to full scan).
- Updated `skills/analysis/SKILL.md` Mode 2 Outputs and Acceptance Criteria to include `PROJECT_CACHE.md`.
- Updated `skills/change-intake/SKILL.md` **Pre-Intake Check**: reads `PROJECT_CACHE.md` in priority order. If fresh, uses as primary context source. If stale, asks user about re-assessment. Updated When to Use and Relationship to Other Skills sections.
- Updated `Docs/assessment-workflow.md` with **Phase 4 (Generate/Update Project Cache)**, a new **Project Cache Lifecycle** section (Mermaid decision flow diagram, cache generation triggers table, cache freshness rules table, impact comparison table: ~8-12 tool calls without cache → ~1-2 with cache), and updated Artifacts Produced and Relationship to Other Skills tables.
- Updated `Docs/evolutionary-lifecycle.md` Documents Produced table with `PROJECT_CACHE.md` entry.
- Why: every skill interacting with an existing project was re-reading documents and re-exploring directory structures on each invocation, consuming ~8-12 tool calls just for context gathering. The cache provides a structured, authoritative snapshot that all skills can read in ~1-2 tool calls, significantly reducing context consumption and improving response speed.
- Affected files: `templates/project-cache.md`, `skills/analysis/SKILL.md`, `skills/change-intake/SKILL.md`, `Docs/assessment-workflow.md`, `Docs/evolutionary-lifecycle.md`, `VERSION`.

### 2026-06-20 - Git hooks deploy option added to deploy scripts

- Added `-GitHooks` (`-gh`) switch to `deploy.ps1` and `-g` flag to `deploy.sh` to optionally deploy the pre-commit auto-version-bump hook to the target project.
- Both scripts prompt the user in interactive mode ("Deploy git hooks (pre-commit auto-version-bump)? (y/N)") when the flag is not provided.
- New step [7/7] copies `hooks/pre-commit` to `$Target/.git/hooks/pre-commit`. On Linux/macOS, makes it executable with `chmod +x`. Displays [DEPLOYED] confirmation.
- Updated `README.md` with: repository structure (hooks/ folder), deploy examples with `-GitHooks` / `-g`, Git Hooks section explaining auto-version-bump behavior, updated deploy process list (step 7).
- Why: the framework already included a pre-commit hook for self-versioning, but target projects had no way to get it. This closes the gap by deploying the hook as an optional step during project setup.
- Affected files: `deploy.ps1`, `deploy.sh`, `README.md`, `Docs/framework-ai-enhancement-phase.md`.

### 2026-07-02 - Project Cache System upgrade: Symbol Index, Import/Export Map, and full lifecycle integration

- Enhanced `templates/project-cache.md` with new **Symbol Index** section (Classes/Types, Services/Providers, Contracts/Interfaces, Route/Endpoint Index) to eliminate grep-based symbol location across the codebase — agents can now find any symbol in one cache read instead of 5–15 grep calls.
- Enhanced `templates/project-cache.md` with new **Import/Export Map** section documenting package-level and cross-module dependencies.
- Added staleness summary header to `templates/project-cache.md` for instant freshness detection without scanning the metadata table.
- Updated `templates/povo.agent.md` with dedicated **Project Cache** section defining lifecycle (Creation → Read → Update → Refresh → Stale detection), freshness rules (Fresh/Stale/Missing), and incremental update rules after significant changes.
- Added cache reading as **Step 0** in both New Project and Existing Project workflows in `templates/povo.agent.md`.
- Added **Pre-Step — Read Project Cache** to all lifecycle skills that interact with existing projects: `design`, `implementation`, `testing`, `review`, `specification`. Each skill now reads the cache first before scanning the codebase.
- Updated all four platform instruction files (`copilot`, `claude`, `gemini`, `opencode`) with a **Project Cache** section explaining the cache lifecycle and usage rules.
- Updated `platforms/opencode/opencode.json` to include `PROJECT_CACHE.md` in the instructions list, making it available to OpenCode agents as context.
- Created `Docs/project-cache-system.md` — comprehensive documentation covering the full cache system, architecture diagram, lifecycle, freshness rules, impact analysis, migration guide, and design decisions.
- Updated `.github/copilot-memory.md` with the Project Cache System entry.
- Why: The initial cache (2026-06-20) was limited to architecture assessment. This upgrade turns the cache into a universal context source that every skill reads as a pre-step, reducing codebase scanning from 5–15 tool calls per interaction to 1–2. The Symbol Index alone eliminates grepping for every class, interface, service, and route the agent needs to locate.
- Affected files: `templates/project-cache.md`, `templates/povo.agent.md`, `skills/analysis/SKILL.md`, `skills/change-intake/SKILL.md`, `skills/design/SKILL.md`, `skills/implementation/SKILL.md`, `skills/testing/SKILL.md`, `skills/review/SKILL.md`, `skills/specification/SKILL.md`, `platforms/copilot/.github/copilot-instructions.md`, `platforms/claude/CLAUDE.md`, `platforms/gemini/.gemini/styleguide.md`, `platforms/opencode/AGENTS.md`, `platforms/opencode/opencode.json`, `Docs/project-cache-system.md`, `Docs/framework-ai-enhancement-phase.md`, `.github/copilot-memory.md`.

### 2026-07-18 - Flutter MSIX Installer skill added

- Created `flutter/skills/flutter-msix-installer/SKILL.md` — pattern-specific skill for creating self-contained MSIX installers for Flutter Windows apps. Covers prerequisites, msix_config setup, build & packaging, DLL verification, beta distribution with certificate, storage path guidance, and sign-off checklist.
- Created `Docs/flutter-msix-installer.md` — documentation for the new skill.
- Why: Flutter Windows desktop projects require MSIX packaging for distribution outside the Microsoft Store. The framework was missing a dedicated skill for this process, and without it developers had to research the procedure manually. The skill was ported from the NpGmao project where it was battle-tested for real-world Windows distribution.
- Affected files: `flutter/skills/flutter-msix-installer/SKILL.md`, `Docs/flutter-msix-installer.md`, `VERSION`.

### 2026-04-25 - Enhancement phase introduced

- Added enhancement-phase rules to `.github/copilot-instructions.md`.
- Updated `.github/agents/project-wide.agent.md` to require `Docs/` updates when Framework core AI files change.
- Updated `.github/copilot-memory.md` with the durable repository rule.
- Created this document to establish the phase and its documentation policy.

### 2026-07-22 - OpenAI Codex platform pattern added

- Added `codex` as a new first-class AI platform (OpenAI Codex), alongside Copilot, Gemini, Claude, and OpenCode.
- Created `platforms/codex/CODEX.md` — project instructions for Codex at the project root.
- Created `templates/codex/povo.agent.md` — agent template for Codex with YAML frontmatter.
- Updated `deploy.ps1` with codex entry in `$PlatformConfig` (`.codex\agents`, `.codex\skills`).
- Updated `deploy.sh` with codex support in `get_agents_dir()`, `get_skills_dir()`, and help text.
- Updated `README.md` with Codex in platforms table, repository structure, and deploy examples.
- Created `Docs/codex-pattern.md` — platform documentation.
- Why: OpenAI Codex is a widely used AI coding assistant. Adding native platform support extends the PovoAgent framework to projects that use Codex as their primary AI tool, following the same pattern established by Claude (`CLAUDE.md`) and other platforms.
- Affected files: `platforms/codex/CODEX.md`, `templates/codex/povo.agent.md`, `deploy.ps1`, `deploy.sh`, `README.md`, `Docs/codex-pattern.md`, `Docs/framework-ai-enhancement-phase.md`.

### 2026-07-22 - Copilot Chat integration option added to deploy scripts

- Added `-CopilotChat` (`-ch`) switch to `deploy.ps1` and `-c` flag to `deploy.sh` to optionally deploy Copilot Chat infrastructure alongside any primary platform.
- Created `templates/vscode/settings.json` — minimal VS Code settings enabling prompt files and instruction file locations for Copilot Chat.
- Created `templates/vscode/prompts/` with lifecycle prompt files: `kickoff.prompt.md`, `change-intake.prompt.md`, `assessment.prompt.md`, `review.prompt.md`, `testing.prompt.md`.
- New deploy step [6/8] in both scripts: deploys `.github/copilot-instructions.md`, `.github/agents/`, `.github/skills/`, `.github/prompts/`, and `.vscode/settings.json` when `-CopilotChat` / `-c` is set.
- Behavior: If primary platform is already copilot, the flag is a no-op (Copilot Chat already included); otherwise, Copilot Chat files are deployed alongside the primary platform files (e.g., `.codex/` and `.github/` coexist).
- Updated `.gitignore` generation to include both platform-specific and Copilot Chat entries.
- Renumbered steps: git hooks step moved from [7/7] to [8/8]; gitignore step moved from [6/7] to [7/8].
- Updated `README.md` with new "Copilot Chat Integration (Optional)" section, deploy examples, and updated deploy process step list.
- Updated both deploy scripts' help text and summary to mention Copilot Chat.
- Created `Docs/copilot-chat-deploy.md` — comprehensive documentation covering feature overview, deployment scenarios, file structure, coexistence with primary platforms, Copilot Chat files (settings, instructions, agents, prompts), interactive deployment, and next steps.
- Why: Developers use multiple AI tools in their workflow. This feature enables projects to use Codex, Claude, or another platform as primary development AI, while also leveraging Copilot Chat in VS Code for interactive chat workflows, without platform conflicts.
- Affected files: `deploy.ps1`, `deploy.sh`, `templates/vscode/settings.json`, `templates/vscode/prompts/*.prompt.md`, `README.md`, `Docs/copilot-chat-deploy.md`, `Docs/framework-ai-enhancement-phase.md`.
