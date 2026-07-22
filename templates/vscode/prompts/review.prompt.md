---
mode: agent
description: 'Run a structured code review: SOLID, decoupling, conventions, and pattern correctness.'
---

# Code Review

Run the PovoAgent review workflow.

1. Read `PROJECT_CACHE.md` first (if fresh) for architecture context.
2. Invoke the `review` skill (delegates to the reviewer sub-agent).
3. Check: SOLID compliance, layer decoupling, convention adherence, pattern correctness, and test coverage.
4. Report blocking violations vs. non-blocking suggestions.
5. Do not modify code — produce a review report with findings and recommended fixes.
