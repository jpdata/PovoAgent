# Assessment Workflow — Auditing Existing Projects

> **Document type:** Framework documentation  
> **Audience:** Developers and AI agents using PovoAgent  
> **Scope:** Describes the end-to-end Assessment workflow for analyzing existing projects to identify architectural, technical, and flow improvements.

---

## Overview

The Assessment workflow is an evolutionary lifecycle path that performs a **holistic audit** of an existing project. Unlike other evolutionary workflows (Feature, Modification, Bug Fix, Refactor) which target a single change, Assessment systematically reviews the entire project — or a scoped subset — and produces a prioritized report of findings with concrete recommendations.

**Key differentiators from other workflows:**

| Aspect | Feature / Modification / Bug Fix / Refactor | Assessment |
|---|---|---|
| Trigger | User knows the specific change needed | User wants to discover what should change |
| Input Scope | One feature, one file, one bug | Entire project or dimension (Architecture / Technical / Flows) |
| Output | One `CHANGE_REQUEST.md` or `BUG_REPORT.md` | One `ASSESSMENT_REPORT.md` + optional N `CHANGE_REQUEST.md` |
| Methodology | Convergent (narrow, fix-specific) | Divergent (broad, discover findings) then convergent (generate CRs) |

---

## When to Use

- A user says: "Assess my project for improvements", "Analyze the architecture", "Audit my codebase", "Find technical debt", "Review my API flows".
- The team is inheriting a codebase and needs a health report.
- Before a major refactor or migration, to understand the full scope.
- As part of a periodic code health review cycle.
- When a project shows signs of degradation (slow builds, frequent regressions, mounting bugs).

---

## Workflow Diagram

```mermaid
flowchart TB
    CI([Change Intake<br/>Type: Assessment]) --> |ASSESSMENT_REPORT.md stub| AN
    
    subgraph AN ["Phase 1: Analysis (Assessment Mode)"]
        direction LR
        S1([Confirm Scope]) --> S2([Gather Context]) --> S3([Architecture<br/>Assessment]) --> S4([Technical<br/>Assessment]) --> S5([Flow<br/>Assessment]) --> S6([Prioritize &<br/>Produce Report])
    end
    
    AN --> |Full ASSESSMENT_REPORT.md| RV
    
    subgraph RV ["Phase 2: Review Validation"]
        direction LR
        REV([Reviewer validates<br/>findings against<br/>conventions])
    end
    
    RV --> |Validated report| CR
    
    subgraph CR ["Phase 3: Generate Change Requests"]
        direction LR
        GEN([Generate individual<br/>CHANGE_REQUEST.md<br/>per finding])
    end
    
    CR --> |N CHANGE_REQUEST.md| EXEC
    
    subgraph EXEC ["Execution (per CR)"]
        direction LR
        SPEC([Specification]) --> IMPL([Implementation]) --> TEST([Testing]) --> REVW([Review])
    end

    style CI fill:#e87722,color:#fff
    style AN fill:#7b68ee,color:#fff,stroke:#5a4fcf
    style RV fill:#f4a460,color:#fff
    style CR fill:#50c878,color:#fff
    style EXEC fill:#4a90d9,color:#fff
```

---

## Phase Breakdown

### Phase 1 — Analysis (Assessment Mode)

| Field | Value |
|---|---|
| Skill | `analysis` (Assessment Mode — Mode 2) |
| Agent | PovoAgent (main) |
| Input | `ASSESSMENT_REPORT.md` stub (metadata from `change-intake`) + `PROJECT_CACHE.md` (if exists) + project source code |
| Output | `ASSESSMENT_REPORT.md` with all findings filled in + `PROJECT_CACHE.md` generated/updated |
| Gate | User reviews and approves the Assessment Report |

#### Steps

1. **Confirm Scope** — Full (all dimensions), Architecture only, Technical only, or Flows only.
2. **Gather Context** — Read `PROJECT_CACHE.md` first (if fresh). Then read `PROJECT_INTAKE.md`, `SPEC_*.md`, Design Document, `conventions.md`.
3. **Architecture Assessment** — SOLID compliance, layer/slice boundaries, decoupling, design patterns, folder structure.
4. **Technical Assessment** — Performance, security, maintainability, dependencies, technical debt.
5. **Flow Assessment** — User flows, data flows, API contracts, cross-slice communication, processes.
6. **Prioritize & Produce Report** — Classify each finding by severity, write the Executive Summary, fill all sections.
7. **Generate / Update Cache** — After the report is approved, produce or update `PROJECT_CACHE.md` from the template. Populate architecture map, domain map, file index, key decisions, and refresh log. Set stale date to Last Updated + 30 days.

### Phase 2 — Review Validation

| Field | Value |
|---|---|
| Skill | `review` |
| Agent | PovoAgent (main) + Reviewer sub-agent |
| Input | `ASSESSMENT_REPORT.md` + project conventions |
| Output | Validation: findings confirmed or corrected |
| Gate | No false positives; all findings are accurate |

The reviewer reads the Assessment Report and validates each finding against the project's conventions and architecture style. This ensures the report does not contain false positives (e.g., flagging a pattern as a violation when it's actually the convention).

### Phase 3 — Generate Change Requests

| Field | Value |
|---|---|
| Skill | `change-intake` (invoked per finding) |
| Agent | PovoAgent (main) |
| Input | `ASSESSMENT_REPORT.md` findings |
| Output | Individual `CHANGE_REQUEST.md` per selected finding |
| Gate | User approves each CR |

This phase is **optional** but recommended for Critical and High findings. Each finding that the user wants to act on spawns a `change-intake` conversation to produce a `CHANGE_REQUEST.md`. The CR follows the appropriate evolutionary workflow (Feature or Modification).

### Execution (per CR)

Each generated `CHANGE_REQUEST.md` follows its own workflow:

- **Feature CRs** → Specification → Implementation → Testing → Review
- **Modification CRs** → Implementation → Testing → Review

### Phase 4 — Generate / Update Project Cache

| Field | Value |
|---|---|
| Skill | `analysis` (Assessment Mode — Mode 2, Step 8) |
| Agent | PovoAgent (main) |
| Input | `ASSESSMENT_REPORT.md` + project source code + `templates/project-cache.md` template |
| Output | `PROJECT_CACHE.md` at project root |
| Gate | Cache file written with all sections populated; refresh log updated |

This phase runs automatically after the Assessment Report is approved. It produces a structured, machine-readable snapshot of the project that all subsequent skills can read to avoid re-scanning the codebase.

**What gets cached (Clean Architecture):**

| Cache Section | Content |
|---|---|
| Metadata | Project name, pattern, platform, architecture style, dates, assessment ID |
| Architecture Map — Layer Overview | Layers (Presentation, Application, Domain, Infrastructure) + key files per layer |
| Architecture Map — Cross-Layer Contracts | Interfaces defined in one layer, implemented in another, consumed by a third |
| Architecture Map — Dependency Graph | Text diagram of layer dependencies |
| Domain Map | Aggregate roots, domain services, business rules summary |
| File Index | Config files, entry points, key directories (with file counts), test files |
| Key Decisions & Constraints | Architecture decisions with rationale, known constraints with mitigations |
| Cache Refresh Log | Full history: date, trigger (Assessment / Change), assessment ID, changes summary |

**What gets cached (Vertical Slice Architecture):**

| Cache Section | Content |
|---|---|
| Metadata | Project name, pattern, platform, architecture style, dates, assessment ID |
| Architecture Map — Slice Overview | Slices + endpoints + handler + data access per slice |
| Architecture Map — Cross-Slice Contracts | Contracts between slices + type (Event, Mediator, Shared Kernel) |
| Architecture Map — Shared Kernel | Shared types, enums, utilities across slices |
| Domain Map | Aggregate roots, domain services, business rules summary |
| File Index | Config files, entry points, key directories (with file counts), test files |
| Key Decisions & Constraints | Architecture decisions with rationale, known constraints with mitigations |
| Cache Refresh Log | Full history: date, trigger (Assessment / Change), assessment ID, changes summary |

---

## Project Cache Lifecycle

### How Skills Use the Cache

```mermaid
flowchart TB
    Start([Skill invoked on<br/>existing project]) --> Check{PROJECT_CACHE.md<br/>exists?}
    
    Check --> |No| FullScan[Full scan: read all<br/>docs + explore codebase]
    Check --> |Yes| Fresh{Last Updated<br/>< 30 days?}
    
    Fresh --> |Yes| UseCache[Use cache as primary source:<br/>architecture map, domain map,<br/>file index, key decisions]
    Fresh --> |No| Stale[Warn user: cache is stale.<br/>Suggest re-assessment.]
    
    UseCache --> Validate[Validate cache against<br/>actual files if needed]
    Validate --> Proceed[Proceed with task<br/>using cached knowledge]
    
    Stale --> UserChoice{User wants<br/>re-assessment?}
    UserChoice --> |Yes| FullScan
    UserChoice --> |No| UseCache
    
    FullScan --> Proceed

    style Start fill:#4a90d9,color:#fff
    style Check fill:#e87722,color:#fff
    style Fresh fill:#e87722,color:#fff
    style UseCache fill:#50c878,color:#fff
    style Stale fill:#f4a460,color:#fff
    style FullScan fill:#e87722,color:#fff
    style Proceed fill:#4a90d9,color:#fff
```

### Cache Generation Triggers

| Trigger | What happens | Skill responsible |
|---|---|---|
| **First Assessment** | Full `PROJECT_CACHE.md` generated. All sections populated. | `analysis` (Mode 2, Step 8) |
| **Re-Assessment** | Cache updated with new findings. Previous refresh log entry preserved, new entry appended. | `analysis` (Mode 2, Step 8) |
| **Major change completed** (new feature, refactor, new slice/layer) | Incremental update: affected sections refreshed, refresh log appended. | `analysis` (Mode 2, Step 8) — invoked explicitly by user: "Update the project cache after this change." |

### Cache Freshness Rules

| State | Condition | Behavior |
|---|---|---|
| **Fresh** | Last Updated ≤ 30 days ago | All skills read cache first. Skip redundant file scans. |
| **Stale** | Last Updated > 30 days ago | Next skill that reads it warns the user: "The project cache is over 30 days old. Consider re-assessing." User can proceed with stale cache or trigger re-assessment. |
| **Invalidated** | Cache sections contradict actual files | Skills validate key cache claims (file existence, layer structure) before relying on them. If discrepancy found, treat cache as unreliable and fall back to full scan. |

### Impact on Context Usage

| Without Cache | With Cache |
|---|---|
| Every skill re-reads `PROJECT_INTAKE.md`, design docs, conventions | Read once via cache; subsequent skills read cache only |
| Every skill explores directory structure via `list_dir` / `file_search` | File Index section provides directory map with file counts |
| Architecture style, layer boundaries re-discovered each time | Architecture Map section provides authoritative reference |
| Domain model re-extracted from code each time | Domain Map section provides aggregate roots, services, rules |
| ~8–12 tool calls per skill just for context gathering | ~1–2 tool calls (read cache + validate if needed) |

---

## Assessment Dimensions in Detail

### Architecture Dimension

| Check | What to look for |
|---|---|
| **SOLID — Single Responsibility** | Classes/modules with more than one reason to change. God classes. |
| **SOLID — Open/Closed** | New behavior requiring modification of existing classes instead of extension. |
| **SOLID — Liskov Substitution** | Implementations that cannot replace their interface without changing caller behavior. |
| **SOLID — Interface Segregation** | Interfaces with methods that some consumers don't use. Fat interfaces. |
| **SOLID — Dependency Inversion** | High-level modules depending on low-level implementations directly. |
| **Decoupling (CA)** | Presentation → Infrastructure direct references. Domain with framework imports. |
| **Decoupling (VSA)** | Slice A importing Slice B's handler. Missing cross-slice contracts. |
| **Design Patterns** | Missing Repository, DI, Use Case (CA). Missing Mediator/Handler (VSA). |
| **Folder Structure** | Deviations from `conventions.md`. Inconsistent naming. |

### Technical Dimension

| Check | What to look for |
|---|---|
| **Performance** | N+1 queries, missing caching, blocking operations, large payloads, unindexed queries. |
| **Security** | Missing input validation, exposed secrets, missing auth checks, insecure dependencies, SQL injection. |
| **Maintainability** | Duplicated code, magic numbers, methods > 50 lines, files > 500 lines, deep nesting. |
| **Dependencies** | Outdated packages, unused dependencies, version conflicts, vulnerable transitive deps. |
| **Technical Debt** | TODO/FIXME comments, commented-out code, inconsistent patterns, missing error handling. |

### Flow Dimension

| Check | What to look for |
|---|---|
| **User Flows** | Incomplete journeys, missing edge cases, unclear error feedback, confusing navigation. |
| **Data Flows** | Incorrect transformations, data consistency risks, missing validation, silent data loss. |
| **API Contracts** | Unstable contracts, inconsistent error responses, missing versioning, inaccurate docs. |
| **Cross-Slice (VSA)** | Misrouted events, missing handlers, incorrect mediator calls, broken sagas. |
| **Process** | Redundant steps, complex chains that can be simplified, missing idempotency. |

---

## Severity Classification

| Severity | Definition | Examples | Action |
|---|---|---|---|
| **Critical** | Security vulnerability, data loss risk, or architecture violation that blocks releases. | SQL injection, exposed API key in code, Domain layer importing Entity Framework. | Generate CR. Fix immediately. |
| **High** | Significant technical debt, performance bottleneck, or SOLID violation affecting multiple features. | N+1 query on list endpoint, Presentation directly calling Infrastructure, 200+ line method. | Generate CR. Fix in current cycle. |
| **Medium** | Code quality issue, missing pattern, or convention violation with localized impact. | Missing interface on a single-use dependency, inconsistent naming in one module. | Optional CR. Plan for next cycle. |
| **Low** | Minor improvement, naming suggestion, or optional optimization. | Rename variable for clarity, extract helper, add inline comment. | Document. No CR needed. Fix opportunistically. |

---

## From Findings to Execution

```mermaid
flowchart LR
    A[Assessment<br/>Report] --> B{Critical or<br/>High finding?}
    B --> |Yes| C[Generate<br/>CHANGE_REQUEST.md]
    B --> |No| D[Document in report<br/>for later]
    C --> E{Adds new<br/>capability?}
    E --> |Yes| F[Feature Workflow<br/>Spec → Impl → Test → Review]
    E --> |No| G[Modification Workflow<br/>Impl → Test → Review]
```

Each `CHANGE_REQUEST.md` generated from an assessment finding includes a reference back to the Assessment Report (`ASMT-<NNN>`) and the finding number, creating full traceability.

---

## Example Conversation Flow

**User:** "Quiero que analices mi proyecto ProductCatalog en busca de mejoras."

**Agent (change-intake):**
> Is this work on an existing project? If so, does the project have a `PROJECT_INTAKE.md` or design documents I can read?

**User:** "Sí, es el proyecto ProductCatalog con .NET y Clean Architecture."

**Agent:** _[Lee PROJECT_INTAKE.md, design docs, conventions.md]_

> What kind of change is this? Assessment — holistic analysis to identify improvements across architecture, technical, and flows.

**User:** "Assessment completo."

**Agent:** _[Continúa con las preguntas de Scope, confirma, genera ASSESSMENT_REPORT.md stub]_

**Agent (analysis — Assessment Mode):**
> I'll now assess the project across three dimensions. Confirming scope: Full assessment of ProductCatalog.
> _[Ejecuta Steps 3-5, produce findings]_
>
> **Executive Summary:** ProductCatalog has strong layer separation (4/5) but shows N+1 query patterns in ProductController (Technical: High) and the Infrastructure layer directly references ASP.NET types (Architecture: Critical). Overall health: 3.5/5.

**User:** "Genera CRs para los Critical y High."

**Agent:** _[Genera CHANGE_REQUEST.md por cada hallazgo seleccionado]_

---

## Cross-Platform Note

The Assessment workflow operates through conversation and code analysis. It has no platform-specific behavior and works identically on Copilot, OpenCode, Claude, Gemini, and any other AI platform.

## Cross-Pattern Note

The assessment reads the active pattern's `conventions.md` to understand what is and isn't a violation. Technology-specific checks (e.g., React hook rules, .NET DI patterns, Flutter widget structure) are derived from the pattern conventions. The assessment itself is pattern-agnostic.

## Relationship to Other Skills

| Skill | Role in Assessment |
|---|---|
| `change-intake` | Entry point. Produces `ASSESSMENT_REPORT.md` stub with metadata. Also invoked per finding to generate individual CRs. Reads `PROJECT_CACHE.md` in Pre-Intake Check to skip redundant context gathering. |
| `analysis` (Mode 2) | Core assessment execution. Reviews architecture, technical, and flow dimensions. Generates/updates `PROJECT_CACHE.md` in Step 8. |
| `review` | Validates findings against conventions to eliminate false positives. |
| `specification` | Invoked if a generated CR is a Feature type (new capability). |
| `implementation` | Invoked per generated CR to apply the fix or build the feature. |
| `testing` | Invoked per generated CR to validate the fix or feature. |
| `PROJECT_CACHE.md` | **Cross-cutting artifact.** Read by all evolutionary skills (`change-intake`, `implementation`, `testing`, `review`) to avoid re-scanning. Generated by `analysis` Mode 2. Invalidated when stale (>30 days) or when code changes contradict cached data. |

---

## Artifacts Produced

| Artifact | When | Description |
|---|---|---|
| `ASSESSMENT_REPORT.md` | End of Phase 1 | Full report with Executive Summary, findings across all dimensions, prioritized recommendations. |
| `PROJECT_CACHE.md` | End of Phase 4 | Structured snapshot of architecture map, domain map, file index, key decisions, and refresh log. |
| `CHANGE_REQUEST.md` (×N) | Phase 3 (optional) | One per selected finding. Linked back to the Assessment Report. |
| Review validation notes | End of Phase 2 | Confirmation that all findings are accurate and not false positives. |

---

## Milestone Tracking

Assessment progress is tracked through:
1. The Assessment Report's **Approval** checklist.
2. The **Generated Change Requests** table (status of each CR).
3. If the project has a `PROJECT_PLAN.md`, the Assessment phase is added as a milestone entry.
