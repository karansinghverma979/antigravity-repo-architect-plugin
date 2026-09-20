<#
.SYNOPSIS
    Repo Architect Universal Porter, Installer & Project Porting Engine.
.DESCRIPTION
    Universal gateway and porting utility for Google Antigravity & GitHub repositories:
    1. Ports any local project or directory into an OpenSSF Grade-A, production-hardened GitHub repo.
    2. Installs/links the Repo Architect plugin into Google Antigravity (~/.gemini/config/plugins/).
    3. Registers 'repo-architect' as a global PowerShell command in your $PROFILE.
    4. Dispatches audits, scaffolding, and verification across any repository.
.EXAMPLE
    pwsh ./porter.ps1
    pwsh ./porter.ps1 -PortRepo "C:\Projects\my-app" -Archetype web
    pwsh ./porter.ps1 -InstallPlugin -Symlink
    pwsh ./porter.ps1 -InstallGlobal
    pwsh ./porter.ps1 -Verify
    pwsh ./porter.ps1 audit "C:\Projects\my-app"
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param(
    # Positional command for git-style dispatch (audit, port, scaffold, install, global, verify)
    [Parameter(Position = 0, ParameterSetName = "CommandDispatch")]
    [ValidateSet("audit", "port", "scaffold", "install", "global", "verify", "help")]
    [string]$Command,

    # Target path for command dispatch
    [Parameter(Position = 1, ParameterSetName = "CommandDispatch")]
    [string]$Target,

    # Optional second argument for command dispatch (e.g. archetype)
    [Parameter(Position = 2, ParameterSetName = "CommandDispatch")]
    [string]$Option,

    # Port target project into an OpenSSF-hardened GitHub repository
    [Parameter(ParameterSetName = "PortRepo")]
    [Alias("Project")]
    [string]$PortRepo,

    # Project Archetype for scaffolding ('cli', 'mcp', 'python', 'web', 'standard')
    [Parameter(ParameterSetName = "PortRepo")]
    [ValidateSet("cli", "mcp", "python", "web", "standard")]
    [string]$Archetype = "standard",

    # Install/link this plugin into ~/.gemini/config/plugins/repo-architect-plugin
    [Parameter(ParameterSetName = "InstallPlugin")]
    [switch]$InstallPlugin,

    # Register 'repo-architect' command globally in PowerShell $PROFILE
    [Parameter(ParameterSetName = "InstallGlobal")]
    [switch]$InstallGlobal,

    # Run self-audit, AST syntax verification and JSON validation
    [Parameter(ParameterSetName = "Verify")]
    [switch]$Verify,

    # Use directory symlink/junction instead of file copy when installing plugin
    [switch]$Symlink,

    # Strict mode for audits (fails on warnings)
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$UserHome = [Environment]::GetFolderPath("UserProfile")
$PluginDestination = Join-Path $UserHome ".gemini\config\plugins\repo-architect-plugin"
$AuditScript = Join-Path $ScriptDir "skills\repo-architect\scripts\audit_repo.ps1"
$ScaffoldScript = Join-Path $ScriptDir "skills\repo-architect\scripts\scaffold_repo.ps1"
$TemplatesDir = Join-Path $ScriptDir "skills\repo-architect\templates"

function Show-Header {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " 🏛️ REPO-ARCHITECT PORTER & SOVEREIGN GATEWAY v1.1.0" -ForegroundColor Cyan
    Write-Host " Dynamic Root: $ScriptDir" -ForegroundColor DarkGray
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Invoke-SelfVerification {
    Write-Host "`n[1/3] Validating PowerShell Script AST Syntax..." -ForegroundColor Cyan
    $scripts = Get-ChildItem -Path $ScriptDir -Filter *.ps1 -Recurse
    $syntaxErrorCount = 0
    foreach ($s in $scripts) {
        $errs = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($s.FullName, [ref]$null, [ref]$errs)
        if ($errs) {
            Write-Host " [✗ FAIL] $($s.Name): $errs" -ForegroundColor Red
            $syntaxErrorCount++
        } else {
            Write-Host " [✓ PASS] $($s.Name) syntax clean." -ForegroundColor Green
        }
    }

    Write-Host "`n[2/3] Validating JSON Manifests & Ruleset Schemas..." -ForegroundColor Cyan
    $jsonFiles = Get-ChildItem -Path $ScriptDir -Filter *.json -Recurse
    $jsonErrorCount = 0
    foreach ($j in $jsonFiles) {
        try {
            $null = Get-Content $j.FullName -Raw | ConvertFrom-Json
            Write-Host " [✓ PASS] $($j.Name) parsed successfully." -ForegroundColor Green
        } catch {
            Write-Host " [✗ FAIL] $($j.Name): $($_.Exception.Message)" -ForegroundColor Red
            $jsonErrorCount++
        }
    }

    Write-Host "`n[3/3] Running Strict Self-Repository Audit..." -ForegroundColor Cyan
    & pwsh -NoProfile -File $AuditScript -Path $ScriptDir -Strict

    if ($syntaxErrorCount -eq 0 -and $jsonErrorCount -eq 0 -and $LASTEXITCODE -eq 0) {
        Write-Host "`n[✓ SUCCESS] All Porter verification gates passed cleanly!" -ForegroundColor Green
    } else {
        Write-Host "`n[✗ FAILURE] Verification detected issues." -ForegroundColor Red
        exit 1
    }
}

function Invoke-PortRepository {
    param([string]$TargetDirectory, [string]$SelectedArchetype)

    if (-not $TargetDirectory) {
        Write-Error "Target directory must be specified for porting."
        return
    }

    $ResolvedTarget = (Resolve-Path $TargetDirectory -ErrorAction Stop).Path
    $TargetName = Split-Path $ResolvedTarget -Leaf

    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│               PORTING PROJECT TO OPENSSF REPO               │" -ForegroundColor Cyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host " Target:    $ResolvedTarget" -ForegroundColor White
    Write-Host " Archetype: $SelectedArchetype" -ForegroundColor Yellow

    # Step 1: Initialize Git if not present
    $gitDir = Join-Path $ResolvedTarget ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Host "`n[+] Initializing new Git repository..." -ForegroundColor Yellow
        & git -C $ResolvedTarget init -b main
    } else {
        Write-Host "`n[·] Existing Git repository detected." -ForegroundColor DarkGray
    }

    # Step 2: Auto-detect Archetype if default 'standard' was passed
    if ($SelectedArchetype -eq "standard") {
        if (Test-Path (Join-Path $ResolvedTarget "package.json")) {
            $SelectedArchetype = "web"
            Write-Host " [i] Auto-detected Archetype: web (based on package.json)" -ForegroundColor DarkCyan
        } elseif ((Test-Path (Join-Path $ResolvedTarget "pyproject.toml")) -or (Test-Path (Join-Path $ResolvedTarget "requirements.txt"))) {
            $SelectedArchetype = "python"
            Write-Host " [i] Auto-detected Archetype: python (based on pyproject.toml / requirements.txt)" -ForegroundColor DarkCyan
        } elseif ((Get-ChildItem -Path $ResolvedTarget -Filter "*.csproj").Count -gt 0 -or (Test-Path (Join-Path $ResolvedTarget "Cargo.toml"))) {
            $SelectedArchetype = "cli"
            Write-Host " [i] Auto-detected Archetype: cli (based on .csproj / Cargo.toml)" -ForegroundColor DarkCyan
        } elseif (Test-Path (Join-Path $ResolvedTarget "plugin.json")) {
            $SelectedArchetype = "mcp"
            Write-Host " [i] Auto-detected Archetype: mcp (based on plugin.json)" -ForegroundColor DarkCyan
        }
    }

    # Step 3: Run Canonical Scaffolder
    Write-Host "`n[+] Injecting OpenSSF scaffolds and security assets..." -ForegroundColor Yellow
    & pwsh -NoProfile -File $ScaffoldScript -Path $ResolvedTarget -Archetype $SelectedArchetype

    # Step 4: Motobook .env Quarantine & .env.example Generation
    $targetEnv = Join-Path $ResolvedTarget ".env"
    $targetEnvExample = Join-Path $ResolvedTarget ".env.example"
    if ((Test-Path $targetEnv) -and (-not (Test-Path $targetEnvExample))) {
        Write-Host " [+] Generating sanitized .env.example template..." -ForegroundColor Green
        $envLines = Get-Content $targetEnv
        $sanitizedLines = foreach ($line in $envLines) {
            if ($line -match '^\s*([A-Za-z0-9_]+)\s*=') {
                "$($Matches[1])=your_$($Matches[1].ToLower())_here"
            } else {
                $line
            }
        }
        [System.IO.File]::WriteAllLines($targetEnvExample, $sanitizedLines, [System.Text.Encoding]::UTF8)
    }

    # Step 5: Inject GitHub Rulesets
    $rulesetTargetDir = Join-Path $ResolvedTarget ".github\rulesets"
    if (Test-Path $TemplatesDir) {
        if (-not (Test-Path $rulesetTargetDir)) {
            New-Item -ItemType Directory -Path $rulesetTargetDir -Force | Out-Null
        }
        $branchRuleset = Join-Path $TemplatesDir "ruleset_branch_baseline.json"
        $pushRuleset = Join-Path $TemplatesDir "ruleset_push_baseline.json"
        if (Test-Path $branchRuleset) {
            Copy-Item $branchRuleset (Join-Path $rulesetTargetDir "ruleset_branch_baseline.json") -Force
            Write-Host " [+] Injected: .github/rulesets/ruleset_branch_baseline.json" -ForegroundColor Green
        }
        if (Test-Path $pushRuleset) {
            Copy-Item $pushRuleset (Join-Path $rulesetTargetDir "ruleset_push_baseline.json") -Force
            Write-Host " [+] Injected: .github/rulesets/ruleset_push_baseline.json" -ForegroundColor Green
        }
    }

    # Step 5b: Inject Starter Dual-Audience README if Missing
    $targetReadme = Join-Path $ResolvedTarget "README.md"
    if (-not (Test-Path $targetReadme)) {
        Write-Host " [+] Generating Starter Dual-Audience README.md..." -ForegroundColor Green
        $starterReadme = @"
# $TargetName

> Production-grade repository ported and hardened via Repo Architect.

---

## 🏛️ Architecture

````text
┌─────────────────────────────────────────────────────────────┐
│                      $TargetName
├─────────────────────────────────────────────────────────────┤
│  [Source] ──► [Build & Verification] ──► [Production]       │
└─────────────────────────────────────────────────────────────┘
````

---

## 🚀 Quickstart & Installation

### Option A: Local Development
```powershell
# Clone and setup
git clone <repo-url>
```

### Option B: Security & Posture Verification
```powershell
# Verify syntax and security posture
pwsh -NoProfile -File ~/.gemini/config/plugins/repo-architect-plugin/porter.ps1 verify
```

---

## 🛡️ Security & License
- **Security Policy**: See [SECURITY.md](SECURITY.md) for vulnerability disclosure.
- **License**: Distributed under the [MIT License](LICENSE).
"@
        [System.IO.File]::WriteAllText($targetReadme, $starterReadme, [System.Text.Encoding]::UTF8)
    }

    # Step 6: Execute Audit Verification on Ported Repository
    Write-Host "`n[+] Running Post-Port Security & OpenSSF Audit..." -ForegroundColor Yellow
    & pwsh -NoProfile -File $AuditScript -Path $ResolvedTarget

    Write-Host "`n════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " [✓ COMPLETE] Project '$TargetName' successfully ported!" -ForegroundColor Green
    Write-Host " Next recommended git actions in $ResolvedTarget :" -ForegroundColor White
    Write-Host "   git add ." -ForegroundColor DarkGray
    Write-Host "   git commit -m `"chore: port repository to OpenSSF standards via repo-architect`"" -ForegroundColor DarkGray
    Write-Host "   git branch -M main" -ForegroundColor DarkGray
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
}

function Install-AntigravityPlugin {
    param([switch]$UseSymlink)

    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│         INSTALLING REPO-ARCHITECT TO ANTIGRAVITY            │" -ForegroundColor Cyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host " Destination: $PluginDestination" -ForegroundColor White

    $currentResolved = (Resolve-Path $ScriptDir).Path
    if (Test-Path $PluginDestination) {
        $destResolved = (Resolve-Path $PluginDestination).Path
        if ($currentResolved -eq $destResolved) {
            Write-Host " [✓] The repository is already operating inside the active Antigravity plugins directory!" -ForegroundColor Green
            return
        }
    }

    $parentDir = Split-Path $PluginDestination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if ($UseSymlink) {
        if (Test-Path $PluginDestination) {
            Remove-Item $PluginDestination -Recurse -Force
        }
        Write-Host " [+] Creating Directory Junction to $ScriptDir..." -ForegroundColor Yellow
        New-Item -ItemType Junction -Path $PluginDestination -Target $ScriptDir | Out-Null
        Write-Host " [✓ SUCCESS] Symlinked plugin into Antigravity configuration!" -ForegroundColor Green
    } else {
        Write-Host " [+] Synchronizing plugin files to $PluginDestination..." -ForegroundColor Yellow
        if (-not (Test-Path $PluginDestination)) {
            New-Item -ItemType Directory -Path $PluginDestination -Force | Out-Null
        }
        Copy-Item -Path (Join-Path $ScriptDir "*") -Destination $PluginDestination -Recurse -Force -Exclude @(".git")
        Write-Host " [✓ SUCCESS] Plugin copied into Antigravity configuration!" -ForegroundColor Green
    }
}

function Register-GlobalCli {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│       REGISTERING GLOBAL 'repo-architect' COMMAND           │" -ForegroundColor Cyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan

    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $porterScriptPath = Join-Path $ScriptDir "porter.ps1"
    $escapedPath = $porterScriptPath.Replace("'", "''")

    $markerStart = "# >>> REPO-ARCHITECT CLI HELPER >>>"
    $markerEnd = "# <<< REPO-ARCHITECT CLI HELPER <<<"
    $functionCode = @"
$markerStart
function repo-architect {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = `$true)]`$Arguments)
    & pwsh -NoProfile -File '$escapedPath' @Arguments
}
$markerEnd
"@

    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if (-not $profileContent) { $profileContent = "" }

    if ($profileContent -match [regex]::Escape($markerStart)) {
        $regex = "(?s)" + [regex]::Escape($markerStart) + ".*?" + [regex]::Escape($markerEnd) + "\r?\n?"
        $profileContent = [regex]::Replace($profileContent, $regex, "")
    }

    $updatedProfile = ($profileContent.TrimEnd() + "`n`n" + $functionCode).Trim() + "`n"
    [System.IO.File]::WriteAllText($profilePath, $updatedProfile, [System.Text.Encoding]::UTF8)

    Write-Host " [✓ SUCCESS] Injected 'repo-architect' function into: $profilePath" -ForegroundColor Green
    Write-Host " You can now run 'repo-architect' from any PowerShell session:" -ForegroundColor White
    Write-Host "   repo-architect audit" -ForegroundColor DarkCyan
    Write-Host "   repo-architect port <path>" -ForegroundColor DarkCyan
    Write-Host "   repo-architect scaffold <archetype>" -ForegroundColor DarkCyan
    Write-Host " (Reload your shell with: . `$PROFILE)" -ForegroundColor Gray
}

# -------------------------------------------------------------
# DISPATCHER / EXECUTION LOGIC
# -------------------------------------------------------------
Show-Header

if ($PSCmdlet.ParameterSetName -eq "Verify" -or ($PSCmdlet.ParameterSetName -eq "CommandDispatch" -and $Command -eq "verify")) {
    Invoke-SelfVerification
    exit 0
}

if ($PSCmdlet.ParameterSetName -eq "InstallPlugin" -or ($PSCmdlet.ParameterSetName -eq "CommandDispatch" -and $Command -eq "install")) {
    Install-AntigravityPlugin -UseSymlink:$Symlink
    exit 0
}

if ($PSCmdlet.ParameterSetName -eq "InstallGlobal" -or ($PSCmdlet.ParameterSetName -eq "CommandDispatch" -and $Command -eq "global")) {
    Register-GlobalCli
    exit 0
}

if ($PSCmdlet.ParameterSetName -eq "PortRepo") {
    Invoke-PortRepository -TargetDirectory $PortRepo -SelectedArchetype $Archetype
    exit 0
}

if ($PSCmdlet.ParameterSetName -eq "CommandDispatch") {
    switch ($Command) {
        "audit" {
            $auditPath = if ($Target) { (Resolve-Path $Target).Path } else { (Get-Location).Path }
            & pwsh -NoProfile -File $AuditScript -Path $auditPath -Strict:$Strict
            exit $LASTEXITCODE
        }
        "port" {
            $portPath = if ($Target) { $Target } else { (Get-Location).Path }
            $arch = if ($Option) { $Option } else { "standard" }
            Invoke-PortRepository -TargetDirectory $portPath -SelectedArchetype $arch
            exit 0
        }
        "scaffold" {
            $scaffoldArch = if ($Target) { $Target } else { "standard" }
            $scaffoldPath = if ($Option) { (Resolve-Path $Option).Path } else { (Get-Location).Path }
            & pwsh -NoProfile -File $ScaffoldScript -Path $scaffoldPath -Archetype $scaffoldArch
            exit 0
        }
        "help" {
            # fall through to default banner
        }
    }
}

# Default Interactive Menu & Overview
$isInstalledInGemini = (Test-Path $PluginDestination)
Write-Host " STATUS & ENVIRONMENT:" -ForegroundColor White
Write-Host "  • Antigravity Plugin Installed: " -NoNewline
if ($isInstalledInGemini) { Write-Host "YES ($PluginDestination)" -ForegroundColor Green } else { Write-Host "NO (Run with -InstallPlugin)" -ForegroundColor Yellow }

Write-Host "  • Global Shell Helper:         " -NoNewline
$hasGlobal = (Test-Path $PROFILE) -and ((Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue) -match "repo-architect")
if ($hasGlobal) { Write-Host "REGISTERED in `$PROFILE" -ForegroundColor Green } else { Write-Host "NOT REGISTERED (Run with -InstallGlobal)" -ForegroundColor Yellow }

Write-Host "`n COMMON PORTER COMMANDS:" -ForegroundColor White
Write-Host "  pwsh ./porter.ps1 port <Path> [-Archetype <type>]  " -ForegroundColor Cyan -NoNewline
Write-Host "Port any project to OpenSSF Grade-A repo" -ForegroundColor Gray
Write-Host "  pwsh ./porter.ps1 audit [Path] [-Strict]           " -ForegroundColor Cyan -NoNewline
Write-Host "Audit any repo for paths, secrets & CI posture" -ForegroundColor Gray
Write-Host "  pwsh ./porter.ps1 scaffold <cli|mcp|python|web>    " -ForegroundColor Cyan -NoNewline
Write-Host "Scaffold canonical architecture assets" -ForegroundColor Gray
Write-Host "  pwsh ./porter.ps1 install [-Symlink]               " -ForegroundColor Cyan -NoNewline
Write-Host "Link/Install plugin into Antigravity" -ForegroundColor Gray
Write-Host "  pwsh ./porter.ps1 global                           " -ForegroundColor Cyan -NoNewline
Write-Host "Register 'repo-architect' globally in PowerShell" -ForegroundColor Gray
Write-Host "  pwsh ./porter.ps1 verify                           " -ForegroundColor Cyan -NoNewline
Write-Host "Execute full self-integrity and audit suite" -ForegroundColor Gray
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
