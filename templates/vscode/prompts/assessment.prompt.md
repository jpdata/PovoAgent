---
mode: agent
description: 'Run a full project assessment. Produces ASSESSMENT_REPORT.md with severity-classified findings.'
---

# Project Assessment

Run the PovoAgent assessment workflow on the current project.

1. Invoke the `analysis` skill in Mode 2 (Existing Project Assessment).
2. Audit three dimensions: Architecture (SOLID, decoupling, patterns), Technical (performance, security, maintainability, dependencies, debt), and Flows (user flows, data flows, API contracts).
3. Classify findings by severity: Critical, High, Medium, Low.
4. Produce `ASSESSMENT_REPORT.md` and update `PROJECT_CACHE.md`.
5. Offer to generate Change Requests for Critical and High findings.
