# PovoAgent

**Version:** see [VERSION](VERSION)

## Versioning

- Current version is defined in the `VERSION` file at the repository root.
- Each commit increments the patch version by `0.0.1`.
- Format follows [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- **Automated:** A pre-commit hook in `hooks/pre-commit` bumps the patch version automatically. Requires: `git config core.hooksPath hooks` (already configured for this repo).

## What Is This

PovoAgent is an **AI-assisted development framework**. It provides reusable agents, skills, conventions, and platform instructions that are deployed into application projects to guide AI assistants (GitHub Copilot, Gemini, Claude) through a structured development lifecycle.

This repository is **not** an application. It is a template factory.

## How It Works

The framework has two deployment axes:

- **Technology patterns** (`flutter/`, `dotnet/`, ...): self-contained folders with conventions, agents, and skills for a specific tech stack.
- **AI platforms** (`platforms/`): instruction templates adapted to each AI assistant's native format.

When starting a new project, run the deploy script to combine a **platform** + **pattern** and copy the result into the target project.

## Repository Structure

```
PovoAgent/
├── README.md                         <-- This file (framework documentation)
├── deploy.ps1                        <-- Deploy script (PowerShell)
├── deploy.sh                         <-- Deploy script (Bash)
├── templates/
│   └── povo.agent.md                 <-- Agent template (deployed to target projects)
├── platforms/                        <-- AI platform instruction templates
│   ├── copilot/                      <-- GitHub Copilot
│   │   └── .github/
│   │       └── copilot-instructions.md
│   ├── gemini/                       <-- Google Gemini
│   │   └── .gemini/
│   │       └── styleguide.md
│   └── claude/                       <-- Anthropic Claude
│       └── CLAUDE.md
├── skills/                           <-- Generic lifecycle skills (technology-agnostic)
│   ├── analysis/SKILL.md
│   ├── design/SKILL.md
│   ├── implementation/SKILL.md
│   └── testing/SKILL.md
└── <pattern>/                        <-- Technology pattern (deployable)
    ├── conventions.md                <-- Coding conventions & architecture rules
    ├── agents/                       <-- Pattern-specific agents (sub-agents)
    └── skills/                       <-- Pattern-specific skills
```

## Available Patterns

| Pattern    | Folder     | Description                                          |
|------------|------------|------------------------------------------------------|
| Flutter    | `flutter/` | Cross-platform mobile with Dart & Clean Architecture |
| .NET + C#  | `dotnet/`  | Web API, MAUI, Blazor, WPF with Clean Architecture  |

Each pattern contains:

- `conventions.md` — coding standards, folder structure, naming rules.
- `agents/` — specialized sub-agents (architect, reviewer, etc.).
- `skills/` — pattern-specific skills (scaffold, feature, testing).

## Available Platforms

| Platform         | Folder               | Deploy Target                     | Format                        |
|------------------|----------------------|-----------------------------------|-------------------------------|
| GitHub Copilot   | `platforms/copilot/` | `.github/copilot-instructions.md` | Markdown with `#` sections    |
| Google Gemini    | `platforms/gemini/`  | `.gemini/styleguide.md`           | Markdown style guide          |
| Anthropic Claude | `platforms/claude/`  | `CLAUDE.md` (project root)        | Markdown project instructions |

## Deploy

```powershell
# PowerShell (Windows)
.\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp
.\deploy.ps1                           # interactive mode
.\deploy.ps1 -Platform claude -Pattern dotnet -Target C:\Projects\Api -Force
```

```bash
# Bash (Linux/macOS)
./deploy.sh -p copilot -t flutter -d /path/to/project
./deploy.sh                            # interactive mode
./deploy.sh -p gemini -t dotnet -d /path/to/project -f
```

The deploy process:

1. Copies the **platform template** (instructions file) into the target project.
2. Copies the **agent template** (`templates/povo.agent.md`) into the platform's agents directory.
3. Copies **lifecycle skills** into the platform's skills directory.
4. Copies the **pattern's conventions** (`conventions.md`) into the target root.
5. Copies the **pattern's agents and skills** into their platform-specific locations.
6. Updates **`.gitignore`** in the target to exclude all deployed framework files (uses `# -- PovoAgent BEGIN/END --` markers so re-deploys update the section). If no `.git` repo is detected, a warning is shown.

## What Gets Deployed

After deploying `copilot + flutter` into a project, the target looks like:

```
MyApp/
├── .github/
│   ├── copilot-instructions.md       <-- Platform instructions
│   ├── agents/                       <-- Main agent + pattern sub-agents
│   │   ├── povo.agent.md
│   │   ├── flutter-architect.agent.md
│   │   └── flutter-reviewer.agent.md
│   └── skills/                       <-- Lifecycle + pattern skills
│       ├── analysis/SKILL.md
│       ├── design/SKILL.md
│       ├── implementation/SKILL.md
│       ├── testing/SKILL.md
│       ├── flutter-scaffold/SKILL.md
│       ├── flutter-feature/SKILL.md
│       └── flutter-testing/SKILL.md
├── .gitignore                        <-- Updated with PovoAgent entries
└── conventions.md                    <-- Pattern conventions
```

## Adding a New Pattern

1. Create a folder at root level (e.g., `react-native/`).
2. Add `conventions.md` with coding standards.
3. Add `agents/` with specialized sub-agents.
4. Add `skills/` with pattern-specific skills.

## Adding a New Platform

1. Create a folder under `platforms/` (e.g., `platforms/cursor/`).
2. Add the instruction file in the platform's expected format and location.
3. Update `deploy.ps1` and `deploy.sh` with the platform's agents/skills directory mapping.

## Language Rules

- All `.md` files must be written in English.
- AI responses to users must match the user's language.

## Memory

- All corrections, lessons learned, and reusable knowledge must be recorded in: [Global Project Memory](../Memory/memory.md)
