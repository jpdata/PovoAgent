---
mode: agent
description: 'Start a new project with PovoAgent kickoff onboarding. Produces PROJECT_INTAKE.md.'
---

# Project Kickoff

Start the PovoAgent kickoff workflow for a new project.

1. Invoke the `kickoff` skill to gather project information interactively.
2. Ask about: project name, purpose, target users, technology pattern, architecture style (Clean Architecture vs Vertical Slice), and key constraints.
3. Produce `PROJECT_INTAKE.md` at the project root.
4. Wait for user confirmation before proceeding to planning.

Do not skip questions or assume defaults — the intake document drives all subsequent phases.
