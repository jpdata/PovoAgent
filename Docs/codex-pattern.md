# OpenAI Codex Platform Pattern

## What Changed

Added a new AI platform pattern for **OpenAI Codex** as a first-class platform in the PovoAgent framework, alongside existing platforms (Copilot, Gemini, Claude, OpenCode).

## Why It Changed

OpenAI Codex is a popular AI coding assistant used by developers worldwide. Adding native support allows PovoAgent to deploy its framework instructions, agents, and skills into projects that use Codex as their primary AI tool.

## Platform Details

| Property       | Value                               |
|----------------|-------------------------------------|
| Platform Name  | `codex`                             |
| Instruction    | `CODEX.md` (project root)          |
| Agents Dir     | `.codex/agents/`                   |
| Skills Dir     | `.codex/skills/`                   |
| Config Format  | Markdown project instructions      |

## Files Affected

### Created
- `platforms/codex/CODEX.md` — Main instruction file for OpenAI Codex, containing project context, architecture rules, SOLID principles, design patterns, lifecycle phases, coding standards, skills reference, and project cache guidance.
- `templates/codex/povo.agent.md` — Agent template for Codex with YAML frontmatter (description) and full workflow documentation including lifecycle phases, sub-agents, skills, and language rules.
- `Docs/codex-pattern.md` — This documentation file.

### Modified
- `deploy.ps1` — Added `codex` entry to `$PlatformConfig` hash mapping to `.codex/agents` and `.codex/skills` directories.
- `deploy.sh` — Added `codex` cases in `get_agents_dir()` and `get_skills_dir()` functions, and updated `-h` help text to list `codex` as a valid platform.
- `README.md` — Added Codex to the Available Platforms table, repository structure diagram, and deploy examples.

## How It Works

### Deploy with Codex

```powershell
# PowerShell
.\deploy.ps1 -Platform codex -Pattern flutter -Target C:\Projects\MyApp
.\deploy.ps1 -Platform codex -Pattern "flutter,dotnet" -Target C:\Projects\Suite
```

```bash
# Bash
./deploy.sh -p codex -t flutter -d /path/to/project
./deploy.sh -p codex -t flutter,dotnet -d /path/to/suite
```

### What Gets Deployed

When deploying with `-Platform codex`, the following structure is created in the target project:

```
target-project/
├── CODEX.md                        <-- Project instructions for Codex
├── .codex/
│   ├── agents/
│   │   └── povo.agent.md           <-- Main PovoAgent definition
│   │   ├── <pattern>-architect.agent.md
│   │   ├── <pattern>-developer.agent.md
│   │   └── <pattern>-reviewer.agent.md
│   └── skills/
│       ├── analysis/
│       ├── design/
│       ├── implementation/
│       ├── testing/
│       └── <pattern>-specific skills/
├── conventions.md                  <-- Pattern conventions
└── .gitignore                      <-- Updated with PovoAgent entries
```

### Platform Behavior

Codex reads `CODEX.md` from the project root as its primary instruction file. The `.codex/` directory contains the agent definition and skills that Codex can invoke for structured development lifecycle management.
