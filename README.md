# PovoAgent

**Version:** see [VERSION](VERSION)

## Versioning

- Current version is defined in the `VERSION` file at the repository root.
- Each commit increments the patch version by `0.0.1`.
- Format follows [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- **Automated:** A pre-commit hook in `hooks/pre-commit` bumps the patch version automatically. Requires: `git config core.hooksPath hooks` (already configured for this repo).

## What Is This

PovoAgent is an **AI-assisted development framework**. It provides reusable agents, skills, conventions, and platform instructions that are deployed into application projects to guide AI assistants (GitHub Copilot, Gemini, Claude, OpenCode) through a structured development lifecycle.

This repository is **not** an application. It is a template factory.

## How It Works

The framework has two deployment axes:

- **Technology patterns** (`flutter/`, `dotnet/`, ...): self-contained folders with conventions, agents, and skills for a specific tech stack.
- **AI platforms** (`platforms/`): instruction templates adapted to each AI assistant's native format.

When starting a new project, run the deploy script to combine a **platform** + **pattern** and copy the result into the target project. Optionally, deploy **git hooks** for automatic version bumping on each commit.

## Repository Structure

```text
PovoAgent/
├── README.md                         <-- This file (framework documentation)
├── deploy.ps1                        <-- Deploy script (PowerShell)
├── deploy.sh                         <-- Deploy script (Bash)
├── hooks/
│   └── pre-commit                    <-- Git hook: auto-version-bump on commit
├── templates/
│   ├── povo.agent.md                 <-- Agent template (copilot/gemini/claude)
│   └── opencode/
│       └── povo.agent.md             <-- Agent template (opencode, opencode frontmatter)
├── platforms/                        <-- AI platform instruction templates
│   ├── copilot/                      <-- GitHub Copilot
│   │   └── .github/
│   │       └── copilot-instructions.md
│   ├── gemini/                       <-- Google Gemini
│   │   └── .gemini/
│   │       └── styleguide.md
│   ├── claude/                       <-- Anthropic Claude
│   │   └── CLAUDE.md
│   ├── opencode/                     <-- OpenCode
│   │   ├── AGENTS.md
│   │   └── opencode.json
│   └── codex/                        <-- OpenAI Codex
│       └── CODEX.md
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

- Flutter: `flutter/`.
    Description: Cross-platform mobile with Dart and Clean Architecture.
- .NET + C#: `dotnet/`.
    Description: Web API, MAUI, Blazor, and WPF with Clean Architecture.
- Angular: `angular/`.
    Description: Modern Angular frontend with standalone APIs, signals, and optional SSR or hybrid rendering.
- React: `react/`.
    Description: Modern React frontend with feature-first boundaries, predictable state flow, and framework-or-Vite project setup depending on project needs.
- Astro: `astro/`.
    Description: Modern Astro frontend with islands architecture, file-based routing, content collections, and optional React islands for selective interactivity.

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
| OpenCode         | `platforms/opencode/`| `AGENTS.md` + `opencode.json`     | Markdown + JSON config        |
| OpenAI Codex     | `platforms/codex/`   | `CODEX.md` (project root)         | Markdown project instructions |

## Deploy

```powershell
# PowerShell (Windows)
.\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp
.\deploy.ps1 -Platform copilot -Pattern "flutter,dotnet" -Target C:\Projects\Suite
.\deploy.ps1                           # interactive mode
.\deploy.ps1 -Platform copilot -Pattern angular -Target C:\Projects\Portal
.\deploy.ps1 -Platform copilot -Pattern react -Target C:\Projects\Console
.\deploy.ps1 -Platform copilot -Pattern astro -Target C:\Projects\MarketingSite
.\deploy.ps1 -Platform claude -Pattern dotnet -Target C:\Projects\Api -Force
.\deploy.ps1 -Platform opencode -Pattern react -Target C:\Projects\MyReactApp
.\deploy.ps1 -Platform codex -Pattern flutter -Target C:\Projects\CodexApp
.\deploy.ps1 -Platform codex -Pattern flutter -Target C:\Projects\CodexApp -CopilotChat
.\deploy.ps1 -Platform copilot -Pattern dotnet -Target C:\Projects\Api -GitHooks
```

```bash
# Bash (Linux/macOS)
./deploy.sh -p copilot -t flutter -d /path/to/project
./deploy.sh -p copilot -t flutter,dotnet -d /path/to/suite
./deploy.sh                            # interactive mode
./deploy.sh -p copilot -t angular -d /path/to/portal
./deploy.sh -p copilot -t react -d /path/to/console
./deploy.sh -p copilot -t astro -d /path/to/site
./deploy.sh -p gemini -t dotnet -d /path/to/project -f
./deploy.sh -p opencode -t react -d /path/to/project
./deploy.sh -p codex -t flutter -d /path/to/project
./deploy.sh -p codex -t flutter -d /path/to/project -c
./deploy.sh -p copilot -t dotnet -d /path/to/project -g
```

Pattern input validation:

- Use one or more valid pattern names.
- Empty parsed values are rejected in both scripts (for example, `-Pattern ","` or `-t ","`).
- Single pattern deploy creates `conventions.md`; multi-pattern deploy creates `conventions-{pattern}.md` per pattern.

## Git Hooks (Optional)

The framework includes a `hooks/pre-commit` script that **auto-increments the patch version** in the target project's `VERSION` file on every commit.

**Deploy hooks:**

```powershell
# PowerShell
.\deploy.ps1 -Platform copilot -Pattern dotnet -Target C:\Projects\MyApp -GitHooks
```

```bash
# Bash
./deploy.sh -p copilot -t dotnet -d /path/to/project -g
```

**What happens:**

- Copies `hooks/pre-commit` to `.git/hooks/pre-commit` in the target project (if `.git` exists).
- Makes it executable (`chmod +x`) on Linux/macOS; Git Bash on Windows handles `.sh` hooks natively.
- On each `git commit`, the hook reads `VERSION`, bumps the patch number (e.g. `0.1.0` → `0.1.1`), and stages the change.
- If `VERSION` doesn't exist, it creates one starting at `0.1.0`.

**Interactive mode:** The deploy scripts will ask if you want to deploy hooks when no `-GitHooks` / `-g` flag is provided.

## Copilot Chat Integration (Optional)

Enable **GitHub Copilot Chat** for VS Code integration alongside any AI platform. When enabled, the deploy scripts add:
- VS Code settings (`.vscode/settings.json`) — enables prompt files and points to instruction locations.
- Copilot instructions (`.github/copilot-instructions.md`) — framework guidance for Copilot Chat.
- Copilot agents (`.github/agents/`) — main agent + pattern-specific sub-agents for use in chat.
- Copilot skills (`.github/skills/`) — lifecycle and pattern-specific skills available to agents.
- Prompt files (`.github/prompts/`) — ready-made prompts for kickoff, change intake, assessment, review, and testing.

This allows your AI platform (codex, claude, etc.) to coexist with Copilot Chat in the same project.

**Deploy with Copilot Chat:**

```powershell
# PowerShell
.\deploy.ps1 -Platform codex -Pattern flutter -Target C:\Projects\MyApp -CopilotChat
.\deploy.ps1 -Platform claude -Pattern dotnet -Target C:\Projects\Api -CopilotChat -GitHooks
```

```bash
# Bash
./deploy.sh -p codex -t flutter -d /path/to/project -c
./deploy.sh -p claude -t dotnet -d /path/to/project -c -g
```

**What happens:**

- If the primary platform is **not** copilot, adds Copilot Chat infrastructure alongside it.
- If the primary platform **is** copilot, the `-CopilotChat` flag is a no-op (already included).
- Copilot Chat files land in `.github/` and `.vscode/` — separate from platform-specific files (e.g., `.codex/`, `.claude/`).
- On each `git commit`, both platform and Copilot Chat versions are tracked in `.gitignore`.

**Interactive mode:** The deploy scripts can ask interactively if you want to enable Copilot Chat when the flag is not provided.

The deploy process:

1. Copies the **platform template** (instructions file) into the target project.
2. Copies the **agent template** (`templates/povo.agent.md`) into the platform's agents directory.
3. Copies **lifecycle skills** into the platform's skills directory.
4. Copies the **pattern's conventions** (`conventions.md`) into the target root.
5. Copies the **pattern's agents and skills** into their platform-specific locations.
6. Optionally deploys **Copilot Chat** integration (`.github/`, `.vscode/settings.json`, prompts) if `-CopilotChat` / `-c` flag is set. Skipped if primary platform is already copilot.
7. Updates **`.gitignore`** in the target to exclude all deployed framework files (uses `# -- PovoAgent BEGIN/END --` markers so re-deploys update the section). If no `.git` repo is detected, a warning is shown.
8. Optionally deploys **git hooks** (pre-commit auto-version-bump) to `.git/hooks/pre-commit` if the `-GitHooks` / `-g` flag is set or chosen interactively.

## What Gets Deployed

After deploying `opencode + react` into a project, the target looks like:

```text
MyReactApp/
├── .opencode/
│   ├── agents/                       <-- Main agent + pattern sub-agents
│   │   ├── povo.agent.md
│   │   ├── react-architect.agent.md
│   │   ├── react-developer.agent.md
│   │   └── react-reviewer.agent.md
│   └── skills/                       <-- Lifecycle + pattern skills
│       ├── analysis/SKILL.md
│       ├── design/SKILL.md
│       ├── implementation/SKILL.md
│       ├── testing/SKILL.md
│       ├── react-scaffold/SKILL.md
│       ├── react-feature/SKILL.md
│       └── react-testing/SKILL.md
├── AGENTS.md                         <-- Platform instructions
├── opencode.json                     <-- OpenCode project config
├── .gitignore                        <-- Updated with PovoAgent entries
└── conventions.md                    <-- Pattern conventions
```

After deploying `copilot + flutter` into a project, the target looks like:

```text
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
