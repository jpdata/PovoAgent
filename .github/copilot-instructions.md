:Mutable: false

# Copilot Instructions

## Project Overview
PovoAgent is a Framework AI wich is a compilation of agents, skills and necessary resourses for development of applications with AI. It is designed to be flexible and adaptable to various project requirements, providing a structured approach to AI development. There are templates for various platforms and technologies, as well as shared templates for common patterns and practices. This is the main repository for the framework itself, not for a specific project built with it.

## Workspace Scope

- These instructions apply to this repository only.
- When the user asks to change Copilot behavior for this workspace, edit this file in the root `.github` folder.
- Must change files under `platforms/` or `templates/` according to requirements, technopology evolution, or user corrections.

## Project Context

- This repository contains the PovoAgent framework itself.
- The repository includes shared templates, platform-specific instructions, lifecycle skills, and pattern-specific skills.
- Prefer minimal, targeted changes. Keep template work separate from workspace behavior.

## Framework AI Enhancement Phase

- This repository is currently in the Framework AI enhancement phase.
- Any upgrade or update to Framework core AI files must also include documentation under `Docs/`.
- Framework core AI files include workspace instructions, workspace agents, platform instructions, templates, lifecycle skills, pattern agents, pattern skills, and deploy scripts that define or distribute AI behavior.
- The documentation entry must be written in English and should describe what changed, why it changed, and which files were affected.

## Working Rules

- Follow the existing repository structure and naming.
- Keep architecture decisions explicit and documented.
- Preserve the separation between platform instructions, shared templates, and technology-specific skills.
- Write all Markdown documentation in English.
- Respond to the user in the user's language.
- Files marked as :Mutable: false, needs to ask user for permission.

## Workspace Agents

- Workspace-level custom agents for this repository live under `.github/agents/`.
- Use `.github/agents/project-wide.agent.md` when a task affects the framework itself, root workspace behavior, deploy scripts, shared skills, templates, platform instructions, or multiple technology patterns at once.
- If the request is local to one concrete file or one narrow folder, prefer editing that file directly instead of widening scope through a repository-wide agent.

## Memory File

- Use `.github/copilot-memory.md` as the persistent memory file for this workspace.
- At the start of a task, read the memory file before making decisions that may depend on prior corrections or prior agreements.
- Record user corrections that change previous assumptions, naming, scope, or workflow.
- Record durable repository knowledge that should survive across sessions.
- Record carry-over items that the next session must know to continue safely.
- Keep entries short, factual, and easy to prune.
- Remove or rewrite entries that are no longer valid.

## When To Update Memory

- After the user corrects a misunderstanding.
- After a decision that should remain stable in future sessions.
- After discovering a repository-specific rule that is not obvious from the code alone.
- Before ending a task that leaves pending work, blockers, or follow-up decisions.

## Memory Content Rules

- Store concise bullets, not long narrative logs.
- Separate durable knowledge from temporary carry-over notes.
- Prefer concrete facts, decisions, and constraints over commentary.
- If a carry-over item is resolved, delete it from the carry-over section.

## Editing Guidance

- If the user request targets the current workspace, prefer editing files in the repository root over changing source templates.
- If the request spans `.github/`, `platforms/`, `templates/`, shared `skills/`, deploy scripts, or multiple patterns, treat it as project-wide scope.
- If a change updates Framework core AI files, add or update a related document in `Docs/` as part of the same task.
- If the request targets deployable templates, then edit `platforms/`, `templates/`, or `skills/` as needed.
- When there is ambiguity, prefer the concrete file mentioned by the user.