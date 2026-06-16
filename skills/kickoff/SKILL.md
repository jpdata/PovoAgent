---
name: kickoff
description: 'Guides the interactive project onboarding conversation, gathering all information needed to initialize a new project. Use at the very start of any new project before Analysis begins. Produces a filled Project Intake Document that serves as input for all subsequent phases.'
---

# Kickoff Skill

## Objective

Collect all information needed to initialize a new project through an interactive conversation with the user. At the end, produce a filled **Project Intake Document** that is the single source of truth for all subsequent phases.

## When to Use

- A user says "I have a new project", "I want to start a project", or describes something new that has no prior analysis or design artifacts.
- Before any Analysis, Design, Scaffold, or Implementation work begins.

## Conversation Flow

Conduct the kickoff as a guided interview. Ask questions in the following order. Wait for and confirm each answer before continuing. Keep questions short and friendly. Do not ask multiple questions at once.

### Block 1 — Project Identity

1. **Project name** — What is the name of this project?
2. **Short description** — In one or two sentences, what does this project do?
3. **Main goal** — What is the single most important outcome this project must achieve?

### Block 2 — Users and Context

4. **Target users** — Who are the primary users? (e.g., end consumers, internal staff, developers)
5. **Key user problems** — What pain points or needs does this project solve for those users?
6. **Business context** — Is this a new product, an enhancement to an existing system, or a replacement?

### Block 3 — Scope and Constraints

7. **Core features** — List the 3–5 features that are absolutely required for the first version.
8. **Out of scope** — Is there anything explicitly excluded from this project?
9. **Non-functional requirements** — Any known requirements for performance, security, accessibility, or regulatory compliance?
10. **Timeline or deadline** — Is there a known deadline or target release window?

### Block 4 — Technology and Platform

11. **Technology pattern** — Which technology pattern applies? (flutter | react | angular | dotnet | astro | other)
    - If "other", ask the user to describe the stack so it can be noted in the intake document.
12. **AI platform** — Which AI platform will be used in this project? (copilot | opencode | claude | gemini | other)
13. **Integrations** — Are there any external systems, APIs, or services this project must integrate with?
14. **Architecture style** — Which architecture style do you prefer for structuring the project?
    - **Clean Architecture** — horizontal layers (Domain, Application, Infrastructure, Presentation). Best for complex domains, long-lived products, or when strict decoupling between layers is required. Default if the user does not specify.
    - **Vertical Slice Architecture** — feature-vertical organization where each slice owns its full stack (UI, logic, data access). Best for feature-oriented teams, rapid iteration, or when independent feature delivery is prioritized.
    - If the user does not know which to choose, ask a few diagnostic questions:
      - "Will different developers or sub-teams own different features independently?"
      - "Do you expect features to evolve at different speeds or be deployed independently?"
      - "Is the domain complex with cross-cutting rules that many features share?"
      - If most answers lean toward independent features → recommend VSA.
      - If most answers lean toward shared complex rules → recommend Clean Architecture.

### Block 5 — Team and Constraints

15. **Team size** — How many developers will work on this project?
16. **Any known risks or blockers** — Are there known dependencies, risks, or open decisions that could affect the project?

### Confirmation Step

After all questions are answered, present a summary of the collected information and ask:
> "Does this look correct? Should I adjust anything before generating the Project Intake Document?"

Apply corrections if needed, then generate the document.

## Inputs

- User responses during the conversation.

## Outputs

- **Project Intake Document** (`PROJECT_INTAKE.md`) containing all collected information, structured and ready to feed into the Planning and Analysis phases.

## Project Intake Document Structure

```markdown
# Project Intake Document

## Project Identity
- **Name:** <project name>
- **Description:** <short description>
- **Main Goal:** <main goal>

## Users and Context
- **Target Users:** <target users>
- **User Problems:** <key user problems>
- **Business Context:** <new product | enhancement | replacement>

## Scope
- **Core Features:**
  1. <feature 1>
  2. <feature 2>
  3. <feature 3>
- **Out of Scope:** <exclusions>
- **Non-Functional Requirements:** <performance, security, accessibility, compliance>
- **Timeline:** <deadline or target window>

## Technology Stack
- **Pattern:** <flutter | react | angular | dotnet | astro | other>
- **AI Platform:** <copilot | opencode | claude | gemini | other>
- **Architecture:** <Clean Architecture | Vertical Slice Architecture>
- **External Integrations:** <list of integrations>

## Team and Risks
- **Team Size:** <number>
- **Known Risks / Blockers:** <list>

## Approval
- [ ] Kickoff confirmed by user
```

## Acceptance Criteria

- All 16 questions have been answered (or explicitly marked as N/A by the user).
- The user has confirmed the summary before the document is generated.
- The Project Intake Document is created at the root of the project as `PROJECT_INTAKE.md`.
- The document is passed as input to the Planning skill.

## Cross-Platform Note

This skill operates through conversation only. It has no platform-specific behavior. It works identically on Copilot, OpenCode, Claude, Gemini, and any other AI platform.

## Cross-Pattern Note

The technology pattern and AI platform are collected as data during this skill. The skill itself does not apply any pattern; pattern-specific behavior begins in the Scaffold phase.
