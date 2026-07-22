---
mode: agent
description: 'Start change intake for an existing project. Produces CHANGE_REQUEST.md or BUG_REPORT.md.'
---

# Change Intake

Start the PovoAgent change-intake workflow for an existing project.

1. Read `PROJECT_CACHE.md` first (if fresh, ≤ 30 days) to avoid redundant scanning.
2. Invoke the `change-intake` skill to determine the change type: Feature, Modification, Bug Fix, Refactor, or Assessment.
3. Produce `CHANGE_REQUEST.md` or `BUG_REPORT.md` depending on the change type.
4. Route to the appropriate lightweight workflow after user approval.

If the cache is stale, offer a re-assessment before relying on it.
