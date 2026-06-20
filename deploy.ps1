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
    Technology pattern(s) to deploy: flutter | dotnet | angular | react | astro.
    Accepts a single value or multiple comma-separated values (e.g. "flutter,dotnet").

.PARAMETER Target
    Absolute path to the target project folder.

.PARAMETER Force
    Overwrite existing files without prompting.

.PARAMETER GitHooks
    Deploy git hooks (pre-commit auto-version-bump) to target project's .git/hooks/.

.EXAMPLE
    .\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp
    .\deploy.ps1 -p copilot -t flutter -d C:\Projects\MyApp
    .\deploy.ps1 -Platform copilot -Pattern "flutter,dotnet" -Target C:\Projects\MyApp
    .\deploy.ps1 -p copilot -t "flutter,dotnet" -d C:\Projects\MyApp
    .\deploy.ps1 -Platform copilot -Pattern flutter -Target C:\Projects\MyApp -GitHooks
    .\deploy.ps1   # interactive mode
#>

[CmdletBinding()]
param(
    [Alias("p")]  [string]$Platform,
    [Alias("t")]  [string[]]$Pattern,
    [Alias("d")]  [string]$Target,
    [Alias("f")]  [switch]$Force,
    [Alias("gh")] [switch]$GitHooks
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

function Select-MultiOption {
    param([string]$Prompt, [string[]]$Options)
    Write-Host ""
    Write-Host $Prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])"
    }
    Write-Host "  Enter one or more numbers separated by commas (e.g. 1,3)" -ForegroundColor DarkGray
    do {
        $raw    = Read-Host "Select"
        $parts  = $raw -split '[,\s]+' | Where-Object { $_ -match '^\d+$' }
        $valid  = $parts.Count -gt 0 -and (-not ($parts | Where-Object { [int]$_ -lt 1 -or [int]$_ -gt $Options.Count }))
        if (-not $valid) { Write-Host "  Invalid selection, try again." -ForegroundColor Yellow }
    } while (-not $valid)
    return $parts | ForEach-Object { $Options[[int]$_ - 1] }
}

$AvailablePlatforms = Get-AvailablePlatforms
$AvailablePatterns  = Get-AvailablePatterns

if (-not $Platform) {
    $Platform = Select-Option -Prompt "Select AI platform:" -Options $AvailablePlatforms
}
if (-not $Pattern -or $Pattern.Count -eq 0) {
    $selectedPatterns = Select-MultiOption -Prompt "Select technology pattern(s):" -Options $AvailablePatterns
    $Pattern = $selectedPatterns
}
if (-not $Target) {
    $Target = Read-Host "`nTarget project path"
}

if (-not $GitHooks) {
    $hooksChoice = Read-Host "`nDeploy git hooks (pre-commit auto-version-bump)? (y/N)"
    $GitHooks = $hooksChoice -match '^[Yy]$'
}

# ── Validation ───────────────────────────────────────────────────────────────
$Platform = $Platform.ToLower()
$Patterns = @(
    @($Pattern) |
        ForEach-Object { $_ -split '[,;]+' } |
        ForEach-Object { $_.Trim().ToLower() } |
        Where-Object { $_ -ne '' }
)

if ($Patterns.Count -eq 0) {
    Write-Error "No valid pattern was provided. Use -Pattern with one or more values such as 'flutter' or 'flutter,dotnet'."
}

if ($Platform -notin $AvailablePlatforms) {
    Write-Error "Unknown platform '$Platform'. Available: $($AvailablePlatforms -join ', ')"
}
foreach ($p in $Patterns) {
    if ($p -notin $AvailablePatterns) {
        Write-Error "Unknown pattern '$p'. Available: $($AvailablePatterns -join ', ')"
    }
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

# ── OpenCode agent conversion ─────────────────────────────────────────────────
# Copies pattern agents to target, converting Copilot-format frontmatter
# (tools: [...] array) into opencode-compatible (mode/permission) format.
function Copy-AgentsForOpencode {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path $Source)) {
        Write-Host "  [SKIP] Pattern agents - source not found: $Source" -ForegroundColor DarkGray
        return 0
    }
    $count = 0
    # Copilot tool name -> opencode permission key(s)
    $toolMap = @{
        read    = @('read')
        edit    = @('edit')
        search  = @('grep','glob','list')
        web     = @('webfetch','websearch')
        execute = @('bash')
        todo    = @('todowrite')
    }
    $permOrder = @('read','edit','glob','grep','list','bash','task','webfetch','websearch','skill','todowrite')

    $items = Get-ChildItem -Path $Source -Recurse -File
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($Source.Length).TrimStart('\', '/')
        $destFile     = Join-Path $Destination $relativePath
        $destDir      = Split-Path -Parent $destFile

        if ((Test-Path $destFile) -and (-not $Force)) {
            Write-Host "  [EXISTS] $relativePath - use -Force to overwrite" -ForegroundColor Yellow
            continue
        }
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $content = Get-Content $item.FullName -Raw

        # Transform Copilot-format frontmatter when tools: [...] array is present
        $fmRx = [regex]::Match($content, '(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)')
        if ($fmRx.Success) {
            $fm   = $fmRx.Groups[1].Value
            $body = $fmRx.Groups[2].Value
            $toolsRx = [regex]::Match($fm, 'tools\s*:\s*\[([^\]]*)\]')
            if ($toolsRx.Success) {
                $copilotTools = ($toolsRx.Groups[1].Value -split ',') |
                    ForEach-Object { $_.Trim() } | Where-Object { $_ }

                # Build allow set
                $allowed = @{}
                foreach ($p in $permOrder) { $allowed[$p] = 'deny' }
                foreach ($t in $copilotTools) {
                    if ($toolMap.ContainsKey($t)) {
                        foreach ($p in $toolMap[$t]) { $allowed[$p] = 'allow' }
                    }
                }

                # Remove tools line; add mode and permission block
                $fm = [regex]::Replace($fm, '\r?\ntools\s*:\s*\[[^\]]*\]', '').TrimEnd()
                if ($fm -notmatch 'mode\s*:') { $fm += "`nmode: subagent" }
                $permLines = @('permission:')
                foreach ($p in $permOrder) { $permLines += "  ${p}: $($allowed[$p])" }
                $fm += "`n" + ($permLines -join "`n")
                $content = "---`n${fm}`n---`n${body}"
                Write-Host "  [CONVERTED] $relativePath" -ForegroundColor DarkGray
            }
        }

        Set-Content -Path $destFile -Value $content -NoNewline
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
Write-Host "  Patterns : $($Patterns -join ', ')" -ForegroundColor White
Write-Host "  Target   : $Target" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

$totalFiles = 0

# 1. Platform instructions template
Write-Host "[1/7] Platform instructions ($Platform)..." -ForegroundColor Cyan
$platformSource = Join-Path $PlatformsDir $Platform
$totalFiles += Copy-TreeSafe -Source $platformSource -Destination $Target -Label "Platform template"

# 2. Agent template
Write-Host "[2/7] Agent template..." -ForegroundColor Cyan
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
Write-Host "[3/7] Lifecycle skills..." -ForegroundColor Cyan
$targetSkills = Join-Path $Target $Config.SkillsDir
$totalFiles += Copy-TreeSafe -Source $SkillsDir -Destination $targetSkills -Label "Lifecycle skills"

# 4. Pattern conventions
Write-Host "[4/7] Pattern conventions ($($Patterns -join ', '))..." -ForegroundColor Cyan
$multiPattern = $Patterns.Count -gt 1
foreach ($pat in $Patterns) {
    $patternDir       = Join-Path $ScriptRoot $pat
    $conventionsSource = Join-Path $patternDir "conventions.md"
    $conventionsName  = if ($multiPattern) { "conventions-$pat.md" } else { "conventions.md" }
    if (Test-Path $conventionsSource) {
        $conventionsDest = Join-Path $Target $conventionsName
        if ((Test-Path $conventionsDest) -and (-not $Force)) {
            Write-Host "  [EXISTS] $conventionsName - use -Force to overwrite" -ForegroundColor Yellow
        } else {
            Copy-Item -Path $conventionsSource -Destination $conventionsDest -Force
            $totalFiles++
        }
    } else {
        Write-Host "  [SKIP] $conventionsName not found" -ForegroundColor DarkGray
    }
}

# 5. Pattern agents and skills
Write-Host "[5/7] Pattern agents and skills ($($Patterns -join ', '))..." -ForegroundColor Cyan
$targetAgents = Join-Path $Target $Config.AgentsDir
foreach ($pat in $Patterns) {
    $patternDir    = Join-Path $ScriptRoot $pat
    $patternAgents = Join-Path $patternDir "agents"
    $patternSkills = Join-Path $patternDir "skills"
    if ($Platform -eq "opencode") {
        $totalFiles += Copy-AgentsForOpencode -Source $patternAgents -Destination $targetAgents
    } else {
        $totalFiles += Copy-TreeSafe -Source $patternAgents -Destination $targetAgents -Label "Pattern agents ($pat)"
    }
    $totalFiles += Copy-TreeSafe -Source $patternSkills -Destination $targetSkills -Label "Pattern skills ($pat)"
}

# 6. Update .gitignore
Write-Host "[6/7] Updating .gitignore..." -ForegroundColor Cyan

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
foreach ($pat in $Patterns) {
    $conventionsName = if ($Patterns.Count -gt 1) { "conventions-$pat.md" } else { "conventions.md" }
    $ignoreEntries += "/$conventionsName"
}

# Pattern agents and skills
foreach ($pat in $Patterns) {
    $patternDir       = Join-Path $ScriptRoot $pat
    $patternAgentsDir = Join-Path $patternDir "agents"
    if (Test-Path $patternAgentsDir) {
        Get-ChildItem -Path $patternAgentsDir -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($patternAgentsDir.Length).TrimStart('\', '/') -replace '\\', '/'
            $ignoreEntries += "/$($Config.AgentsDir -replace '\\', '/')/$rel"
        }
    }
    $patternSkillsDir = Join-Path $patternDir "skills"
    if (Test-Path $patternSkillsDir) {
        Get-ChildItem -Path $patternSkillsDir -Directory | ForEach-Object {
            $ignoreEntries += "/$($Config.SkillsDir -replace '\\', '/')/$($_.Name)/"
        }
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

# 7. Git hooks (optional)
Write-Host "[7/7] Git hooks..." -ForegroundColor Cyan
$hooksSource = Join-Path $ScriptRoot "hooks"
$preCommitSource = Join-Path $hooksSource "pre-commit"
if ($GitHooks) {
    if (Test-Path $preCommitSource) {
        $gitDir = Join-Path $Target ".git"
        $hooksDestDir = Join-Path $gitDir "hooks"
        $preCommitDest = Join-Path $hooksDestDir "pre-commit"

        if (-not (Test-Path $hooksDestDir)) {
            New-Item -ItemType Directory -Path $hooksDestDir -Force | Out-Null
        }

        if ((Test-Path $preCommitDest) -and (-not $Force)) {
            Write-Host "  [EXISTS] pre-commit - use -Force to overwrite" -ForegroundColor Yellow
        } else {
            Copy-Item -Path $preCommitSource -Destination $preCommitDest -Force
            $totalFiles++
            Write-Host "  [DEPLOYED] pre-commit hook (auto-version-bump on commit)" -ForegroundColor White

            # Make executable on Unix; on Windows, Git Bash handles .sh naturally
            if ($IsLinux -or $IsMacOS) {
                try { chmod +x $preCommitDest } catch { }
            }
        }
    } else {
        Write-Host "  [SKIP] hooks/pre-commit not found in framework" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [SKIP] Git hooks not selected (use -GitHooks to enable)" -ForegroundColor DarkGray
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Deploy complete - $totalFiles file(s) copied." -ForegroundColor Green
if ($GitHooks -and (Test-Path $preCommitDest)) {
    Write-Host "  Git hooks  : deployed (.git/hooks/pre-commit)" -ForegroundColor White
}
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
