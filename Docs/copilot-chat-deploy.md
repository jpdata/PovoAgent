# Copilot Chat Integration

## What Changed

Added `-CopilotChat` (PowerShell) / `-c` (Bash) flag to deploy scripts, enabling **GitHub Copilot Chat for VS Code** integration alongside any AI platform.

## Why It Changed

Developers often use multiple AI tools in their workflow. The framework previously tied platform deployment to a single AI assistant. This update allows projects to:
- Use **Codex, Claude, or another platform** as the primary development AI.
- **Also enable Copilot Chat** in the same VS Code workspace for interactive chat workflows.
- Leverage both without conflicts — each occupies its own directory structure.

## How It Works

### What Gets Deployed

When `-CopilotChat` / `-c` is enabled (and primary platform ≠ copilot):

```
target-project/
├── <Platform>/                       <-- e.g., .codex/, .claude/, etc.
│   ├── agents/
│   ├── skills/
│   └── <platform-specific files>
├── .github/                          <-- NEW (Copilot Chat)
│   ├── copilot-instructions.md      <-- Copilot instructions
│   ├── agents/
│   │   ├── povo.agent.md
│   │   ├── <pattern>-architect.agent.md
│   │   ├── <pattern>-developer.agent.md
│   │   └── <pattern>-reviewer.agent.md
│   ├── skills/
│   │   ├── analysis/
│   │   ├── design/
│   │   ├── implementation/
│   │   ├── testing/
│   │   └── <pattern-specific skills>/
│   └── prompts/                      <-- NEW (Prompt files)
│       ├── kickoff.prompt.md
│       ├── change-intake.prompt.md
│       ├── assessment.prompt.md
│       ├── review.prompt.md
│       └── testing.prompt.md
├── .vscode/                          <-- NEW (VS Code settings)
│   └── settings.json                 <-- Points to instruction/prompt locations
├── <Primary-Platform>.md             <-- e.g., CODEX.md
├── conventions.md                    <-- Pattern conventions
└── .gitignore                        <-- Updated to track all deployments
```

### Behavior by Primary Platform

| Primary Platform | `-CopilotChat` Flag | Result                                       |
|------------------|-------------------- |----------------------------------------------|
| copilot          | Not set             | Copilot already included; no change          |
| copilot          | Set                 | Already copilot; message shown, no duplicates|
| codex            | Not set             | Only Codex deployed; no Copilot Chat         |
| codex            | Set                 | **Both** Codex (`.codex/`) and Copilot (`.github/`) |
| claude           | Not set             | Only Claude deployed                         |
| claude           | Set                 | **Both** Claude (`.claude/`) and Copilot (`.github/`) |

## Deploy Examples

### Scenario 1: Codex + Copilot Chat + Flutter + Git Hooks

```powershell
.\deploy.ps1 -Platform codex -Pattern flutter -Target C:\Projects\MyApp -CopilotChat -GitHooks
```

**Deploys:**
- Codex platform (`.codex/CODEX.md`, `.codex/agents/`, `.codex/skills/`)
- Flutter pattern (conventions, agents, skills)
- Copilot Chat infrastructure (`.github/`, `.vscode/settings.json`, prompts)
- Git hooks (`.git/hooks/pre-commit` for auto-versioning)

### Scenario 2: Claude + Copilot Chat Only (No Extra Patterns)

```bash
./deploy.sh -p claude -t angular -d /path/to/portal -c
```

**Deploys:**
- Claude platform (`.claude/CLAUDE.md`, `.claude/agents/`, `.claude/skills/`)
- Angular pattern
- Copilot Chat infrastructure

### Scenario 3: Multi-Pattern + Copilot Chat

```powershell
.\deploy.ps1 -Platform codex -Pattern "flutter,dotnet" -Target C:\Projects\Suite -CopilotChat
```

**Deploys:**
- Codex platform
- Flutter pattern (conventions, agents, skills)
- .NET pattern (conventions-dotnet.md, agents, skills)
- Copilot Chat infrastructure (shared across both patterns)

## Copilot Chat Files Explained

### `.vscode/settings.json`

Minimal settings to enable Copilot Chat prompt and instruction file support:

```json
{
    "chat.promptFiles": true,
    "chat.instructionsFilesLocations": {
        ".github/instructions": true
    },
    "chat.promptFilesLocations": {
        ".github/prompts": true
    }
}
```

**What this does:**
- Enables custom prompt files (`.github/prompts/*.prompt.md`).
- Points VS Code to look for instruction files in `.github/instructions/` (if custom instructions are added later).
- Points to `.github/prompts/` for custom prompt files.

### `.github/copilot-instructions.md`

Same as the copilot platform instructions. Contains:
- Architecture and SOLID principles
- Design patterns guidance
- Project lifecycle phases
- Sub-agent descriptions
- Skill references
- Language rules
- Project cache guidance

**Copilot Chat reads this automatically** when opened in the project.

### `.github/agents/povo.agent.md`

Main agent definition for Copilot Chat. Describes:
- Project lifecycle (kickoff, planning, analysis, design, scaffold, implementation, testing, review)
- Sub-agents (architect, developer, reviewer)
- Available skills
- Workflows for new projects vs. evolutionary changes
- Language rules

Invoke in Copilot Chat via **`@povo` or `@PovoAgent`**.

### `.github/prompts/*.prompt.md`

Ready-made conversation starters for common tasks:

- **kickoff.prompt.md** — Start a new project intake conversation.
- **change-intake.prompt.md** — Describe a feature, bug, or refactor on an existing project.
- **assessment.prompt.md** — Run a codebase assessment.
- **review.prompt.md** — Run a structured code review.
- **testing.prompt.md** — Generate tests or validate test coverage.

**Usage in Copilot Chat:**
1. Open a prompt file (`.github/prompts/kickoff.prompt.md`).
2. VS Code highlights **"Use as Prompt"** button.
3. Click to start a new chat with the prompt content.

Or type manually: `@kickoff` if VS Code recognizes it (depends on version and settings).

## Interactive Deployment

If neither `-CopilotChat`/`-c` nor `-GitHooks`/`-g` flags are provided, both scripts ask interactively:

```
Select AI platform:
  [1] copilot
  [2] gemini
  [3] claude
  [4] opencode
  [5] codex
Select: 3

Select technology pattern(s):
  [1] flutter
  [2] dotnet
  [3] angular
  [4] react
  [5] astro
Select (comma-separated): 1,4

Target project path: C:\Projects\MyApp

Deploy git hooks (pre-commit auto-version-bump)? (y/N): y

Enable Copilot Chat for VS Code? (y/N): y
```

## Coexistence with Primary Platform

### Example: Codex + Copilot Chat + React

After deployment:

```
target-project/
├── CODEX.md                          <-- Codex primary instructions
├── .codex/agents/
│   ├── povo.agent.md                 <-- Codex agent (Codex-specific format)
│   ├── react-architect.agent.md
│   ├── react-developer.agent.md
│   └── react-reviewer.agent.md
├── .codex/skills/                    <-- Pattern skills
│   ├── analysis/
│   ├── design/
│   ├── implementation/
│   ├── testing/
│   ├── react-scaffold/
│   ├── react-feature/
│   └── react-testing/
├── .github/copilot-instructions.md   <-- Copilot Chat instructions (separate)
├── .github/agents/
│   ├── povo.agent.md                 <-- Copilot agent (with mode: subagent)
│   ├── react-architect.agent.md
│   ├── react-developer.agent.md
│   └── react-reviewer.agent.md
├── .github/skills/                   <-- Same lifecycle/pattern skills
│   ├── analysis/
│   ├── design/
│   ├── implementation/
│   ├── testing/
│   ├── react-scaffold/
│   ├── react-feature/
│   └── react-testing/
├── .github/prompts/                  <-- Copilot Chat prompts (Codex doesn't use)
│   ├── kickoff.prompt.md
│   ├── change-intake.prompt.md
│   ├── assessment.prompt.md
│   ├── review.prompt.md
│   └── testing.prompt.md
├── .vscode/settings.json             <-- VS Code config (Copilot Chat settings)
├── conventions.md                    <-- Pattern (shared)
└── .gitignore                        <-- Tracks both platforms
```

**In Use:**
- Open Codex IDE/editor → uses `CODEX.md` + `.codex/agents/` + `.codex/skills/`.
- Open **Copilot Chat in VS Code** → uses `.github/copilot-instructions.md` + `.github/agents/` + `.github/prompts/`.
- Both have access to `conventions.md` and pattern skills.
- No conflicts; each platform operates independently.

## .gitignore Updates

Both platform and Copilot Chat files are tracked in `.gitignore` under the `# -- PovoAgent BEGIN -- / -- PovoAgent END --` block:

```gitignore
# -- PovoAgent BEGIN --
/CODEX.md
/.codex/agents/
/.codex/skills/
/.github/agents/povo.agent.md
/.github/agents/<pattern>-*.agent.md
/.github/skills/
/.github/prompts/
/.github/copilot-instructions.md
/.vscode/settings.json
/conventions.md
/conventions-<pattern>.md
# -- PovoAgent END --
```

Re-deploying updates this block automatically.

## Next Steps

After deployment with Copilot Chat enabled:

1. **Initialize the project** per pattern requirements (Flutter: `flutter create`, React: `create-react-app`, etc.).
2. **Use your primary AI platform** (Codex, Claude) for main development via their native interfaces.
3. **Open Copilot Chat in VS Code** (Ctrl+Shift+I / Cmd+Shift+I) and:
   - Use `@povo` to invoke the main agent.
   - Open a `.github/prompts/kickoff.prompt.md` to start a lifecycle workflow.
   - Chat naturally; the agent reads instructions and guides you through phases.
4. **Leverage both:** Primary platform for focused coding, Copilot Chat for exploratory conversations and workflow guidance.
