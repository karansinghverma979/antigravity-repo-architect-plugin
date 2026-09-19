<#
.SYNOPSIS
    Canonical GitHub Repository Scaffolder & Security Injector.
.DESCRIPTION
    Scaffolds missing OpenSSF assets, .github workflows, issue templates,
    .gitattributes, .gitignore, and community health files for a target repository.
.PARAMETER Path
    Target directory to scaffold (defaults to current directory).
.PARAMETER Archetype
    Project archetype: 'cli', 'mcp', 'python', 'web', 'standard'.
.PARAMETER ProjectName
    Name of the project/repository.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = (Get-Location).Path,

    [Parameter(Position = 1)]
    [ValidateSet('cli', 'mcp', 'python', 'web', 'standard')]
    [string]$Archetype = 'standard',

    [Parameter(Position = 2)]
    [string]$ProjectName = (Split-Path (Resolve-Path $Path) -Leaf)
)

$ErrorActionPreference = 'Stop'
$TargetDir = Resolve-Path $Path

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " 🏛️ REPO-ARCHITECT SCAFFOLDER: $ProjectName" -ForegroundColor Cyan
Write-Host " Archetype: $Archetype  |  Target: $TargetDir" -ForegroundColor DarkGray
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

function Ensure-File {
    param([string]$FilePath, [string]$Content, [string]$Label)
    if (-not (Test-Path $FilePath)) {
        $parent = Split-Path $FilePath -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        [System.IO.File]::WriteAllText($FilePath, $Content, [System.Text.Encoding]::UTF8)
        Write-Host " [+] Created: $Label" -ForegroundColor Green
    } else {
        Write-Host " [·] Exists:  $Label" -ForegroundColor DarkGray
    }
}

# 1. .gitattributes
$GitAttrContent = @"
# Auto detect text files and perform LF normalization
* text=auto

# Text files normalized with LF
*.md text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.ts text eol=lf
*.js text eol=lf
*.py text eol=lf
*.rs text eol=lf
*.cs text eol=lf

# Force Unix LF for all shell scripts (prevents Windows CRLF syntax crash)
*.sh text eol=lf

# Windows scripts require CRLF
*.ps1 text eol=crlf
*.bat text eol=crlf
*.cmd text eol=crlf
"@
Ensure-File (Join-Path $TargetDir ".gitattributes") $GitAttrContent ".gitattributes"

# 2. .gitignore
$BaseGitIgnore = @"
# OS Metadata
Thumbs.db
Desktop.ini
.DS_Store

# IDE and Editor artifacts
.vscode/
.idea/
*.swp
*.swo
*~

# Environment & Secrets (Never commit live credentials)
.env
.env.local
*.local
secrets/
keys/
*.pem
*.key
*.pfx

# Motobook Runtime State Quarantine (Never track local databases)
.local/
data/*.sqlite
data/*.db
data/*.sqlite3
storage/
logs/
*.log
"@

$LangIgnore = switch ($Archetype) {
    'cli' {
        @"
# Build Artifacts & Binaries
bin/
obj/
target/
*.exe
*.dll
*.pdb
*.nupkg
"@
    }
    'mcp' {
        @"
# Node / TypeScript
node_modules/
dist/
coverage/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
"@
    }
    'python' {
        @"
# Python Virtual Environments & Bytecode
__pycache__/
*.py[cod]
*$py.class
.venv/
env/
venv/
*.egg-info/
dist/
build/
.pytest_cache/
.mypy_cache/
.ruff_cache/
"@
    }
    'web' {
        @"
# Web Build Artifacts
node_modules/
dist/
build/
.next/
out/
.cache/
"@
    }
    default { "" }
}

Ensure-File (Join-Path $TargetDir ".gitignore") ($BaseGitIgnore + "`n" + $LangIgnore) ".gitignore"

# 3. SECURITY.md (OpenSSF Standard)
$SecurityContent = @"
# Security Policy

## Supported Versions
Only the latest release receives active security patches.

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| <latest | :x:                |

## Reporting a Vulnerability
**Please do not report security vulnerabilities through public GitHub issues.**

To report a vulnerability:
1. Use GitHub's private vulnerability reporting feature on the repository:
   `https://github.com/<owner>/<repo>/security/advisories/new`
2. Or contact the maintainer directly via private channels.

Please provide:
- A clear description of the vulnerability and its attack vector.
- Step-by-step reproduction instructions or a minimal proof-of-concept.
- Any suggested remediations or mitigations.

We will acknowledge reports within 48 hours and coordinate a public release upon resolution.
"@
Ensure-File (Join-Path $TargetDir "SECURITY.md") $SecurityContent "SECURITY.md"

# 4. LICENSE (MIT)
$Year = (Get-Date).Year
$LicenseContent = @"
MIT License

Copyright (c) $Year Karan Singh Verma

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
Ensure-File (Join-Path $TargetDir "LICENSE") $LicenseContent "LICENSE"

# 5. .github/dependabot.yml
$DependabotContent = @"
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "security"
"@
Ensure-File (Join-Path $TargetDir ".github\dependabot.yml") $DependabotContent ".github/dependabot.yml"

# 6. .github/ISSUE_TEMPLATE/ (bug_report.yml & feature_request.yml)
$BugReportContent = @"
name: 🐛 Bug Report
description: File a bug report to help us improve
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: Thanks for taking the time to report an issue!
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear and concise description of what the bug is.
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      description: Exact steps to reproduce the behavior.
    validations:
      required: true
  - type: input
    id: environment
    attributes:
      label: Environment
      description: OS version, runtime version, etc.
      placeholder: Windows 11 / PowerShell 7.4 / .NET 9
    validations:
      required: false
"@
Ensure-File (Join-Path $TargetDir ".github\ISSUE_TEMPLATE\bug_report.yml") $BugReportContent ".github/ISSUE_TEMPLATE/bug_report.yml"

$FeatureContent = @"
name: 💡 Feature Request
description: Propose an idea or feature enhancement
labels: ["enhancement"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: Is your feature request related to a problem? Please describe.
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      description: Describe the solution you'd like to see.
    validations:
      required: true
"@
Ensure-File (Join-Path $TargetDir ".github\ISSUE_TEMPLATE\feature_request.yml") $FeatureContent ".github/ISSUE_TEMPLATE/feature_request.yml"

# 7. .github/PULL_REQUEST_TEMPLATE.md
$PRContent = @"
## 🎯 Description
Briefly describe the change and the problem it solves.

## 🛠️ Changes Made
- Point 1
- Point 2

## 🧪 Testing Performed
- [ ] Local build verified
- [ ] Tests passed
- [ ] Zero hardcoded user paths or leaked credentials
"@
Ensure-File (Join-Path $TargetDir ".github\PULL_REQUEST_TEMPLATE.md") $PRContent ".github/PULL_REQUEST_TEMPLATE.md"

# 8. OpenSSF-Hardened CI Workflow
$CiWorkflowContent = @"
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# OpenSSF Least Privilege Invariant
permissions:
  contents: read

jobs:
  build-and-test:
    runs-on: windows-latest
    steps:
      # Pinned to immutable commit SHA (actions/checkout@v4.2.2)
      - name: Checkout Code
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
"@
Ensure-File (Join-Path $TargetDir ".github\workflows\ci.yml") $CiWorkflowContent ".github/workflows/ci.yml"

# 9. GitHub Official CodeQL SAST Analysis Workflow (Only for archetypes with supported languages)
$CodeQLLang = switch ($Archetype) {
    'python' { 'python' }
    'web'    { 'javascript-typescript' }
    default  { $null }
}

if ($CodeQLLang) {
    $CodeQLContent = @"
name: "CodeQL Analysis"

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '30 1 * * 0'

permissions:
  contents: read
  security-events: write

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Initialize CodeQL
        uses: github/codeql-action/init@b56ba49b26e50535fa1e7f7db0f4f7b4bf65d80d # v3.28.10
        with:
          languages: $CodeQLLang

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@b56ba49b26e50535fa1e7f7db0f4f7b4bf65d80d # v3.28.10
"@
    Ensure-File (Join-Path $TargetDir ".github\workflows\codeql.yml") $CodeQLContent ".github/workflows/codeql.yml"
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host " ✅ SCAFFOLDING COMPLETE FOR $ProjectName!" -ForegroundColor Green
Write-Host " Run 'audit_repo.ps1' to verify repository posture." -ForegroundColor Gray
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
