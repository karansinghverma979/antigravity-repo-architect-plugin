<#
.SYNOPSIS
    Repository Security, Path Portability & OpenSSF Hardening Auditor.
.DESCRIPTION
    High-speed, 50ms audit engine that scans a target repository for:
    1. Absolute User Paths (C:\Users\karan\ leaks)
    2. Exposed Secrets, Tokens & Private Keys
    3. Runtime State Pollution (*.sqlite, *.db, *.log in git tree)
    4. Git & Line-Ending Firewall (.gitignore, .gitattributes)
    5. OpenSSF Supply Chain Hardening (pinned action commit SHAs, least privilege)
    6. GitHub Community Profile Standards (README, LICENSE, SECURITY.md)
.PARAMETER Path
    Target repository path to audit (defaults to current directory).
.PARAMETER Strict
    Fail on warnings as well as critical errors.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = (Get-Location).Path,

    [switch]$Strict
)

$ErrorActionPreference = 'Stop'
$TargetDir = (Resolve-Path $Path).Path

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " 🏛️ REPO-ARCHITECT AUDIT: $(Split-Path $TargetDir -Leaf)" -ForegroundColor Cyan
Write-Host " Target: $TargetDir" -ForegroundColor DarkGray
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$Passed = 0
$Warnings = 0
$Failed = 0

function Report-Result {
    param(
        [string]$Category,
        [string]$Status, # PASS, WARN, FAIL
        [string]$Message,
        [string[]]$Details = @()
    )
    
    switch ($Status) {
        "PASS" {
            $script:Passed++
            Write-Host " [✓ PASS] " -ForegroundColor Green -NoNewline
            Write-Host "$($Category): " -ForegroundColor White -NoNewline
            Write-Host "$Message" -ForegroundColor Gray
        }
        "WARN" {
            $script:Warnings++
            Write-Host " [! WARN] " -ForegroundColor Yellow -NoNewline
            Write-Host "$($Category): " -ForegroundColor White -NoNewline
            Write-Host "$Message" -ForegroundColor Yellow
            foreach ($d in $Details) {
                Write-Host "          ↳ $d" -ForegroundColor DarkYellow
            }
        }
        "FAIL" {
            $script:Failed++
            Write-Host " [✗ FAIL] " -ForegroundColor Red -NoNewline
            Write-Host "$($Category): " -ForegroundColor White -NoNewline
            Write-Host "$Message" -ForegroundColor Red
            foreach ($d in $Details) {
                Write-Host "          ↳ $d" -ForegroundColor DarkRed
            }
        }
    }
}

# -------------------------------------------------------------
# 1. ABSOLUTE PATH INVARIANT SCAN (Zero Machine Leaks)
# -------------------------------------------------------------
$PathExcludes = @('.git', 'node_modules', 'bin', 'obj', 'target', '.vs', '.venv')
$TextExtensions = @('.md', '.txt', '.json', '.yml', '.yaml', '.ps1', '.sh', '.py', '.ts', '.js', '.cs', '.rs', '.go', '.toml', '.xml')

$CurrentUser = [Environment]::UserName
$LeakedPaths = @()
$AllFiles = Get-ChildItem -Path $TargetDir -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($TargetDir.Length)
    $skip = $false
    foreach ($ex in $PathExcludes) {
        if ($rel -match "[\\/]$([regex]::Escape($ex))[\\/]") { $skip = $true; break }
    }
    (-not $skip) -and ($TextExtensions -contains $_.Extension -or $_.Name -in @('Dockerfile', 'Makefile'))
}

foreach ($file in $AllFiles) {
    if ($PSCommandPath -and $file.FullName -eq (Resolve-Path $PSCommandPath).Path) { continue }
    $lines = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        # Flag actual user profile leaks (e.g. C:\Users\karan\ or current username)
        if ($line -match "(?i)[a-z]:\\users\\$([regex]::Escape($CurrentUser))" -or ($line -match '(?i)[a-z]:\\users\\[a-z0-9_\.-]+' -and $line -notmatch '<[a-z0-9_\.-]+>' -and $line -notmatch 'placeholder')) {
            $relPath = $file.FullName.Substring($TargetDir.Length).TrimStart('\', '/')
            $LeakedPaths += "$relPath (Line $lineNum): $($line.Trim())"
        }
    }
}

if ($LeakedPaths.Count -eq 0) {
    Report-Result -Category "Path Portability" -Status "PASS" -Message "Zero hardcoded local user paths detected."
} else {
    Report-Result -Category "Path Portability" -Status "FAIL" -Message "$($LeakedPaths.Count) absolute path leak(s) found!" -Details $LeakedPaths
}

# -------------------------------------------------------------
# 2. SECRET & PII SHIELD SCAN
# -------------------------------------------------------------
$SecretPatterns = @(
    'ghp_[a-zA-Z0-9]{36}',
    'github_pat_[a-zA-Z0-9_]{82}',
    'sk-[a-zA-Z0-9]{48}',
    'AIza[0-9A-Za-z-_]{35}',
    '-----BEGIN (?:RSA |EC |OPENSSH |)PRIVATE KEY-----',
    'xox[baprs]-[0-9a-zA-Z]{10,48}'
)

$LeakedSecrets = @()
foreach ($file in $AllFiles) {
    # Skip test dummy files or .env.example
    if ($file.Name -match '\.example$' -or $file.Name -match '\.sample$') { continue }
    
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    foreach ($pattern in $SecretPatterns) {
        if ($content -match $pattern) {
            $relPath = $file.FullName.Substring($TargetDir.Length).TrimStart('\', '/')
            $LeakedSecrets += "$relPath matches pattern: $pattern"
        }
    }
}

# Check if .env is accidentally present and not gitignored
$EnvFile = Join-Path $TargetDir ".env"
$GitIgnore = Join-Path $TargetDir ".gitignore"
if (Test-Path $EnvFile) {
    $isIgnored = $false
    if (Test-Path $GitIgnore) {
        $ignoreContent = Get-Content -Path $GitIgnore -Raw
        if ($ignoreContent -match '(^|\r?\n)\.env(\r?\n|$)') { $isIgnored = $true }
    }
    if (-not $isIgnored) {
        $LeakedSecrets += "Active '.env' file exists in root but is NOT ignored in .gitignore!"
    }
}

if ($LeakedSecrets.Count -eq 0) {
    Report-Result -Category "Secret Shield" -Status "PASS" -Message "Zero plaintext tokens, private keys or unshielded .env detected."
} else {
    Report-Result -Category "Secret Shield" -Status "FAIL" -Message "Sensitive credentials detected!" -Details $LeakedSecrets
}

# -------------------------------------------------------------
# 2B. VIBE-CODING CODE-LEVEL APP DEFENSE (Gitleaks, Bearer, ECC)
# -------------------------------------------------------------
$CodeFiles = $AllFiles | Where-Object { $_.Extension -in @('.js', '.ts', '.jsx', '.tsx', '.py', '.cs', '.go', '.rs', '.php', '.rb', '.html') }
$VibeSecurityIssues = @()

foreach ($file in $CodeFiles) {
    $lines = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue
    $lineIdx = 0
    foreach ($line in $lines) {
        $lineIdx++
        $rel = $file.FullName.Substring($TargetDir.Length).TrimStart('\', '/')
        
        # 1. Frontend prefix leakage (NEXT_PUBLIC_, REACT_APP_, VITE_ exposing private secrets)
        if ($line -match '(?i)(?:NEXT_PUBLIC_|REACT_APP_|VITE_)[a-z0-9_]*(?:SECRET|PRIVATE|SERVICE_ROLE|DATABASE_URL|ADMIN_KEY)') {
            $VibeSecurityIssues += "$rel (Line $lineIdx): Dangerous frontend-prefixed secret: $($line.Trim())"
        }
        
        # 2. Insecure client storage of auth credentials
        if ($line -match '(?i)localStorage\.setItem\s*\(\s*[''"][a-z0-9_\-]*(?:token|jwt|auth|password|secret)') {
            $VibeSecurityIssues += "$rel (Line $lineIdx): Insecure localStorage usage for auth credential: $($line.Trim())"
        }
        
        # 3. Debug logging of credentials or raw environment dumps
        if ($line -match '(?i)console\.log\s*\(\s*(?:process\.env|.*(?:password|api_key|secret_key|private_key))') {
            $VibeSecurityIssues += "$rel (Line $lineIdx): Debug logging of sensitive environment/credential: $($line.Trim())"
        }

        # 4. Backdoor endpoints or security FIXME comments
        if ($line -match '(?i)(?:/admin-backdoor|/seed-data|FIXME:\s*.*auth|TODO:\s*.*security)') {
            $VibeSecurityIssues += "$rel (Line $lineIdx): Unhardened debug backdoor or incomplete security marker: $($line.Trim())"
        }
    }
}

if ($VibeSecurityIssues.Count -eq 0) {
    Report-Result -Category "Vibe Security" -Status "PASS" -Message "Zero frontend secret leaks, insecure storage, or debug backdoors."
} else {
    Report-Result -Category "Vibe Security" -Status "WARN" -Message "$($VibeSecurityIssues.Count) potential application security risk(s) detected:" -Details $VibeSecurityIssues
}

# -------------------------------------------------------------
# 3. RUNTIME STATE QUARANTINE (Motobook Invariant)
# -------------------------------------------------------------
$StateFiles = Get-ChildItem -Path $TargetDir -Recurse -File -Include @('*.sqlite', '*.db', '*.sqlite3') | Where-Object {
    $rel = $_.FullName.Substring($TargetDir.Length)
    $skip = $false
    foreach ($ex in $PathExcludes) {
        if ($rel -match "[\\/]$([regex]::Escape($ex))[\\/]") { $skip = $true; break }
    }
    -not $skip
}

if ($StateFiles.Count -eq 0) {
    Report-Result -Category "State Quarantine" -Status "PASS" -Message "Zero persistent runtime databases inside working tree."
} else {
    $details = $StateFiles | ForEach-Object { $_.FullName.Substring($TargetDir.Length).TrimStart('\', '/') }
    Report-Result -Category "State Quarantine" -Status "WARN" -Message "$($StateFiles.Count) database file(s) found in repository tree. Quarantine to OS data directory or ignore." -Details $details
}

# -------------------------------------------------------------
# 4. GIT & LINE-ENDING FIREWALL (.gitattributes, .gitignore)
# -------------------------------------------------------------
$GitAttrPath = Join-Path $TargetDir ".gitattributes"
if (-not (Test-Path $GitAttrPath)) {
    Report-Result -Category "Line Endings" -Status "WARN" -Message "Missing '.gitattributes'. Risk of CRLF/LF syntax crashes on Linux & CI runners."
} else {
    $attrContent = Get-Content -Path $GitAttrPath -Raw
    if ($attrContent -match '\*\.sh\s+text\s+eol=lf') {
        Report-Result -Category "Line Endings" -Status "PASS" -Message "'.gitattributes' enforces Unix LF for shell scripts."
    } else {
        Report-Result -Category "Line Endings" -Status "WARN" -Message "'.gitattributes' exists but lacks explicit LF enforcement for '*.sh'."
    }
}

if (-not (Test-Path $GitIgnore)) {
    Report-Result -Category "Git Hygiene" -Status "FAIL" -Message "Missing '.gitignore' file!"
} else {
    Report-Result -Category "Git Hygiene" -Status "PASS" -Message "'.gitignore' present."
}

# -------------------------------------------------------------
# 4B. REPOSITORY SIZE & GIT LFS GOVERNANCE (GitHub Limits)
# -------------------------------------------------------------
$LargeFiles = Get-ChildItem -Path $TargetDir -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($TargetDir.Length)
    $skip = $false
    foreach ($ex in $PathExcludes) {
        if ($rel -match "[\\/]$([regex]::Escape($ex))[\\/]") { $skip = $true; break }
    }
    (-not $skip) -and ($_.Length -gt 50MB)
}

if ($LargeFiles.Count -eq 0) {
    Report-Result -Category "Large Files" -Status "PASS" -Message "Zero files exceed GitHub's 50MB warning / 100MB limit."
} else {
    $details = $LargeFiles | ForEach-Object { "$($_.FullName.Substring($TargetDir.Length).TrimStart('\', '/')) ($([math]::Round($_.Length / 1MB, 2)) MB)" }
    Report-Result -Category "Large Files" -Status "WARN" -Message "$($LargeFiles.Count) file(s) exceed 50 MB. Track via Git LFS in .gitattributes to avoid push failure." -Details $details
}

# -------------------------------------------------------------
# 5. GITHUB COMMUNITY STANDARDS & DOCUMENTATION
# -------------------------------------------------------------
$ReadmePath = Join-Path $TargetDir "README.md"
if (-not (Test-Path $ReadmePath)) {
    Report-Result -Category "Documentation" -Status "FAIL" -Message "Missing 'README.md'."
} else {
    $readmeContent = Get-Content -Path $ReadmePath -Raw
    $hasAscii = ($readmeContent -match '┌' -or $readmeContent -match '```text' -or $readmeContent -match '```mermaid')
    $hasQuickstart = ($readmeContent -match '(?i)##?\s*(?:🚀\s*)?quickstart' -or $readmeContent -match '(?i)##?\s*installation')
    
    if ($hasAscii -and $hasQuickstart) {
        Report-Result -Category "Documentation" -Status "PASS" -Message "'README.md' satisfies Dual-Audience standard (Visual flow + Quickstart)."
    } elseif (-not $hasAscii) {
        Report-Result -Category "Documentation" -Status "WARN" -Message "'README.md' is missing an ASCII visual architecture card (5-second hook)."
    } else {
        Report-Result -Category "Documentation" -Status "WARN" -Message "'README.md' is missing an explicit Quickstart / Installation section."
    }
}

$LicensePath = Join-Path $TargetDir "LICENSE"
if (Test-Path $LicensePath) {
    Report-Result -Category "Governance" -Status "PASS" -Message "'LICENSE' file present."
} else {
    Report-Result -Category "Governance" -Status "WARN" -Message "Missing 'LICENSE' file (MIT / Apache 2.0 recommended)."
}

$SecurityPath = Join-Path $TargetDir "SECURITY.md"
if (Test-Path $SecurityPath) {
    Report-Result -Category "Governance" -Status "PASS" -Message "'SECURITY.md' present."
} else {
    Report-Result -Category "Governance" -Status "WARN" -Message "Missing 'SECURITY.md' (OpenSSF vulnerability disclosure policy)."
}

# -------------------------------------------------------------
# 6. OPENSSF CI/CD HARDENING (Workflows)
# -------------------------------------------------------------
$WorkflowsDir = Join-Path $TargetDir ".github\workflows"
if (Test-Path $WorkflowsDir) {
    $Workflows = Get-ChildItem -Path $WorkflowsDir -Filter "*.yml"
    $unpinnedActions = @()
    $missingPermissions = @()

    foreach ($wf in $Workflows) {
        $wfLines = Get-Content -Path $wf.FullName
        $hasTopPerms = $false
        $lineIdx = 0

        foreach ($l in $wfLines) {
            $lineIdx++
            if ($l -match '^permissions:') { $hasTopPerms = $true }
            
            # Check for unpinned third-party actions e.g. actions/checkout@v4 instead of @40charSHA
            if ($l -match 'uses:\s*([a-zA-Z0-9_\-\.\/]+)@(v[0-9]+(?:\.[0-9]+)*|main|master)') {
                $unpinnedActions += "$($wf.Name) (Line $lineIdx): $($Matches[1])@$($Matches[2])"
            }
        }

        if (-not $hasTopPerms) {
            $missingPermissions += $wf.Name
        }
    }

    if ($missingPermissions.Count -gt 0) {
        Report-Result -Category "OpenSSF CI" -Status "WARN" -Message "Workflows missing top-level 'permissions: contents: read' (least privilege):" -Details $missingPermissions
    } else {
        Report-Result -Category "OpenSSF CI" -Status "PASS" -Message "All workflows declare top-level least-privilege permissions."
    }

    if ($unpinnedActions.Count -gt 0) {
        Report-Result -Category "OpenSSF CI" -Status "WARN" -Message "Unpinned mutable action tags found (vulnerable to tag hijacking):" -Details $unpinnedActions
    } else {
        Report-Result -Category "OpenSSF CI" -Status "PASS" -Message "All GitHub Actions pinned to immutable commit SHAs."
    }
} else {
    Report-Result -Category "OpenSSF CI" -Status "WARN" -Message "No GitHub workflows found in '.github/workflows/'."
}

Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host " SUMMARY: $Passed Passed  |  $Warnings Warnings  |  $Failed Failed" -ForegroundColor $(if ($Failed -gt 0) { "Red" } elseif ($Warnings -gt 0) { "Yellow" } else { "Green" })
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($Failed -gt 0 -or ($Strict -and $Warnings -gt 0)) {
    exit 1
} else {
    exit 0
}
