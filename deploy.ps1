<#
.SYNOPSIS
    Deploys the PovoAgent AI framework (platform instructions, lifecycle skills,
    and technology pattern) into a target project.

.DESCRIPTION
    Combines an AI-platform template (Copilot, Gemini, Claude) with a technology
    pattern (Flutter, .NET, …) and copies the result into the target project folder.

.PARAMETER Platform
    AI platform to deploy: copilot | gemini | claude.

.PARAMETER Pattern
    Technology pattern to deploy: flutter | dotnet | angular | react | astro.

.PARAMETER Target
    Absolute path to the target project folder.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp
    .\deploy.ps1   # interactive mode
#>

[CmdletBinding()]
param(
    [string]$Platform,
    [string]$Pattern,
    [string]$Target,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Resolve PovoAgent root (where this script lives) ────────────────────────
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }

# ── Discovery: available platforms and patterns ──────────────────────────────
$PlatformsDir  = Join-Path $ScriptRoot "platforms"
$TemplatesDir  = Join-Path $ScriptRoot "templates"
$SkillsDir     = Join-Path $ScriptRoot "skills"

function Get-AvailablePlatforms {
    Get-ChildItem -Path $PlatformsDir -Directory | Select-Object -ExpandProperty Name
}

function Get-AvailablePatterns {
    Get-ChildItem -Path $ScriptRoot -Directory |
        Where-Object {
            $_.Name -notin @("platforms", "skills", ".git", ".github", ".gemini", "node_modules") -and
            (Test-Path (Join-Path $_.FullName "conventions.md"))
        } |
        Select-Object -ExpandProperty Name
}

# ── Interactive prompts (when parameters are missing) ────────────────────────
function Select-Option {
    param([string]$Prompt, [string[]]$Options)
    Write-Host ""
    Write-Host $Prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])"
    }
    do {
        $choice = Read-Host "Select (1-$($Options.Count))"
        $index = 0
        $valid = [int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $Options.Count
        if (-not $valid) { Write-Host "  Invalid selection, try again." -ForegroundColor Yellow }
    } while (-not $valid)
    return $Options[$index - 1]
}

$AvailablePlatforms = Get-AvailablePlatforms
$AvailablePatterns  = Get-AvailablePatterns

if (-not $Platform) {
    $Platform = Select-Option -Prompt "Select AI platform:" -Options $AvailablePlatforms
}
if (-not $Pattern) {
    $Pattern = Select-Option -Prompt "Select technology pattern:" -Options $AvailablePatterns
}
if (-not $Target) {
    $Target = Read-Host "`nTarget project path"
}

# ── Validation ───────────────────────────────────────────────────────────────
$Platform = $Platform.ToLower()
$Pattern  = $Pattern.ToLower()

if ($Platform -notin $AvailablePlatforms) {
    Write-Error "Unknown platform '$Platform'. Available: $($AvailablePlatforms -join ', ')"
}
if ($Pattern -notin $AvailablePatterns) {
    Write-Error "Unknown pattern '$Pattern'. Available: $($AvailablePatterns -join ', ')"
}
if (-not (Test-Path $Target)) {
    Write-Error "Target path does not exist: $Target"
}

# ── Deploy helpers ───────────────────────────────────────────────────────────
function Copy-TreeSafe {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )
    if (-not (Test-Path $Source)) {
        Write-Host "  [SKIP] $Label - source not found: $Source" -ForegroundColor DarkGray
        return 0
    }
    $count = 0
    $items = Get-ChildItem -Path $Source -Recurse -File
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($Source.Length).TrimStart('\', '/')
        $destFile = Join-Path $Destination $relativePath
        $destDir  = Split-Path -Parent $destFile

        if ((Test-Path $destFile) -and (-not $Force)) {
            Write-Host "  [EXISTS] $relativePath - use -Force to overwrite" -ForegroundColor Yellow
            continue
        }

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $item.FullName -Destination $destFile -Force
        $count++
    }
    return $count
}

# ── Platform-specific deploy target mapping ──────────────────────────────────
# Each platform defines where agents and skills land in the target project.
$PlatformConfig = @{
    copilot = @{
        AgentsDir = ".github\agents"
        SkillsDir = ".github\skills"
    }
    gemini = @{
        AgentsDir = ".gemini\agents"
        SkillsDir = ".gemini\skills"
    }
    claude = @{
        AgentsDir = ".claude\agents"
        SkillsDir = ".claude\skills"
    }
    opencode = @{
        AgentsDir = ".opencode\agents"
        SkillsDir = ".opencode\skills"
    }
}

$Config = $PlatformConfig[$Platform]
if (-not $Config) {
    Write-Error "No deploy configuration for platform '$Platform'."
}

# ── Execute deploy ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  PovoAgent Deploy" -ForegroundColor Green
Write-Host "  Platform : $Platform" -ForegroundColor White
Write-Host "  Pattern  : $Pattern" -ForegroundColor White
Write-Host "  Target   : $Target" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

$totalFiles = 0

# 1. Platform instructions template
Write-Host "[1/6] Platform instructions ($Platform)..." -ForegroundColor Cyan
$platformSource = Join-Path $PlatformsDir $Platform
$totalFiles += Copy-TreeSafe -Source $platformSource -Destination $Target -Label "Platform template"

# 2. Agent template
Write-Host "[2/6] Agent template..." -ForegroundColor Cyan
$platformAgentSource = Join-Path $TemplatesDir "$Platform\povo.agent.md"
$agentSource = if (Test-Path $platformAgentSource) { $platformAgentSource } else { Join-Path $TemplatesDir "povo.agent.md" }
if (Test-Path $agentSource) {
    $agentDestDir = Join-Path $Target $Config.AgentsDir
    if (-not (Test-Path $agentDestDir)) {
        New-Item -ItemType Directory -Path $agentDestDir -Force | Out-Null
    }
    $agentDest = Join-Path $agentDestDir "povo.agent.md"
    if ((Test-Path $agentDest) -and (-not $Force)) {
        Write-Host "  [EXISTS] povo.agent.md - use -Force to overwrite" -ForegroundColor Yellow
    } else {
        Copy-Item -Path $agentSource -Destination $agentDest -Force
        $totalFiles++
    }
}

# 3. Lifecycle skills (generic)
Write-Host "[3/6] Lifecycle skills..." -ForegroundColor Cyan
$targetSkills = Join-Path $Target $Config.SkillsDir
$totalFiles += Copy-TreeSafe -Source $SkillsDir -Destination $targetSkills -Label "Lifecycle skills"

# 4. Pattern conventions
Write-Host "[4/6] Pattern conventions ($Pattern)..." -ForegroundColor Cyan
$patternDir = Join-Path $ScriptRoot $Pattern
$conventionsSource = Join-Path $patternDir "conventions.md"
if (Test-Path $conventionsSource) {
    $conventionsDest = Join-Path $Target "conventions.md"
    if ((Test-Path $conventionsDest) -and (-not $Force)) {
        Write-Host "  [EXISTS] conventions.md - use -Force to overwrite" -ForegroundColor Yellow
    } else {
        Copy-Item -Path $conventionsSource -Destination $conventionsDest -Force
        $totalFiles++
    }
} else {
    Write-Host "  [SKIP] conventions.md not found" -ForegroundColor DarkGray
}

# 5. Pattern agents and skills
Write-Host "[5/6] Pattern agents and skills ($Pattern)..." -ForegroundColor Cyan
$patternAgents = Join-Path $patternDir "agents"
$patternSkills = Join-Path $patternDir "skills"
$targetAgents  = Join-Path $Target $Config.AgentsDir

$totalFiles += Copy-TreeSafe -Source $patternAgents -Destination $targetAgents -Label "Pattern agents"
$totalFiles += Copy-TreeSafe -Source $patternSkills -Destination $targetSkills -Label "Pattern skills"

# 6. Update .gitignore
Write-Host "[6/6] Updating .gitignore..." -ForegroundColor Cyan

$gitDir = Join-Path $Target ".git"
if (-not (Test-Path $gitDir)) {
    Write-Host "  [WARN] No git repository detected at '$Target'." -ForegroundColor Yellow
    Write-Host "         Run 'git init' first so .gitignore takes effect." -ForegroundColor Yellow
}

# Collect deployed paths relative to target
$ignoreEntries = @()

# Platform template files (e.g., .github/copilot-instructions.md)
if (Test-Path $platformSource) {
    Get-ChildItem -Path $platformSource -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($platformSource.Length).TrimStart('\', '/') -replace '\\', '/'
        $ignoreEntries += "/$rel"
    }
}

# Main agent
$ignoreEntries += "/$($Config.AgentsDir -replace '\\', '/')/povo.agent.md"

# Lifecycle skills (as directories)
if (Test-Path $SkillsDir) {
    Get-ChildItem -Path $SkillsDir -Directory | ForEach-Object {
        $ignoreEntries += "/$($Config.SkillsDir -replace '\\', '/')/$($_.Name)/"
    }
}

# Conventions
$ignoreEntries += "/conventions.md"

# Pattern agents
$patternAgentsDir = Join-Path $patternDir "agents"
if (Test-Path $patternAgentsDir) {
    Get-ChildItem -Path $patternAgentsDir -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($patternAgentsDir.Length).TrimStart('\', '/') -replace '\\', '/'
        $ignoreEntries += "/$($Config.AgentsDir -replace '\\', '/')/$rel"
    }
}

# Pattern skills (as directories)
$patternSkillsDir = Join-Path $patternDir "skills"
if (Test-Path $patternSkillsDir) {
    Get-ChildItem -Path $patternSkillsDir -Directory | ForEach-Object {
        $ignoreEntries += "/$($Config.SkillsDir -replace '\\', '/')/$($_.Name)/"
    }
}

# Write to .gitignore with markers
$gitignorePath = Join-Path $Target ".gitignore"
$markerBegin = "# -- PovoAgent BEGIN --"
$markerEnd   = "# -- PovoAgent END --"
$newBlock     = @($markerBegin) + ($ignoreEntries | Sort-Object -Unique) + @($markerEnd)

if (Test-Path $gitignorePath) {
    $content = Get-Content $gitignorePath -Raw
    if ($content -match [regex]::Escape($markerBegin)) {
        # Replace existing block
        $replacePattern = "(?s)" + [regex]::Escape($markerBegin) + ".*?" + [regex]::Escape($markerEnd)
        $content = [regex]::Replace($content, $replacePattern, ($newBlock -join "`n"))
        Set-Content -Path $gitignorePath -Value $content -NoNewline
        Write-Host "  [UPDATED] .gitignore (PovoAgent section replaced)" -ForegroundColor White
    } else {
        # Append new block
        Add-Content -Path $gitignorePath -Value ("`n" + ($newBlock -join "`n") + "`n")
        Write-Host "  [UPDATED] .gitignore (PovoAgent section added)" -ForegroundColor White
    }
} else {
    Set-Content -Path $gitignorePath -Value (($newBlock -join "`n") + "`n")
    Write-Host "  [CREATED] .gitignore" -ForegroundColor White
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Deploy complete - $totalFiles file(s) copied." -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
