# 🏛️ antigravity-repo-architect-plugin

<p align="center">
  <a href="https://github.com/karansinghverma979/antigravity-repo-architect-plugin/actions/workflows/ci.yml">
    <img src="https://github.com/karansinghverma979/antigravity-repo-architect-plugin/actions/workflows/ci.yml/badge.svg" alt="CI Status" />
  </a>
  <a href="https://securityscorecards.dev">
    <img src="https://img.shields.io/badge/OpenSSF-Hardened%20Grade%20A-blue.svg" alt="OpenSSF Hardened" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" />
  </a>
  <a href="https://github.com/PowerShell/PowerShell">
    <img src="https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg" alt="PowerShell 7+" />
  </a>
  <a href="https://github.com/karansinghverma979/antigravity-repo-architect-plugin">
    <img src="https://img.shields.io/badge/Google%20Antigravity-Plugin%20v1.1.0-orange.svg" alt="Google Antigravity Plugin" />
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Workstation%20Quarantine-Zero%20Leaks-success.svg" alt="Zero-Leak Guarantee" />
  </a>
</p>

> **Autonomous GitHub Repository Architect, Sovereign Project Porter, OpenSSF Security Hardener & Dual-Audience Documentation Engine for Google Antigravity.**

An enterprise-grade Antigravity plugin and standalone CLI toolkit engineered to bridge the chasm between messy local workstation development and world-class, production-ready GitHub repositories. It integrates an autonomous AI agent (`repo_architect`), specialized skills, a universal repository **Porter Engine** (`porter.ps1`), an ultra-fast 50ms Win32/PowerShell 7 audit sentry (`audit_repo.ps1`), and OpenSSF supply-chain hardening blueprints.

---

## 🏛️ The Universal Porter Workflow

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                    THE REPO-ARCHITECT PORTER LIFECYCLE                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [ UNHARDENED LOCAL PROJECT / LEGACY CODEBASE ]                         │
│   ✖ Absolute user paths (C:\Users\<username>\...)                      │
│   ✖ Leaked secrets, unshielded active .env                              │
│   ✖ Polluting runtime databases (*.sqlite, *.db in git tree)            │
│   ✖ Windows CRLF bash crashes on Linux CI runners                       │
│   ✖ Mutable @v4 GitHub Action tags (Supply-chain hijacking risk)        │
│   ✖ Missing LICENSE, SECURITY.md, or issue intake templates             │
│                                                                         │
│                                   │                                     │
│                  pwsh ./porter.ps1 port <Path>                          │
│                                   ▼                                     │
│                                                                         │
│  [ SOVEREIGN TRANSFORMATION ENGINE ]                                    │
│   1. Stack Discovery    ──► Auto-detects CLI, MCP, Web, or Python stack │
│   2. 4-Wall Quarantine  ──► .gitignore + .gitattributes + .env.example  │
│   3. Supply Chain Lock  ──► Pinned 40-char Action SHAs + read-only perms│
│   4. Edge Guardrails    ──► Injects declarative GitHub Push Rulesets    │
│   5. Dual-Audience Docs ──► Inverted pyramid README + ASCII flowcards   │
│   6. Sentry Audit       ──► 50ms AST validation & OpenSSF certification │
│                                                                         │
│                                   │                                     │
│                                   ▼                                     │
│                                                                         │
│  [ OPENSSF GRADE-A PRODUCTION REPOSITORY ]                              │
│   ✔ 100% path portability (Dynamic runtime expansion)                   │
│   ✔ Sovereign state quarantine & secret shielding                       │
│   ✔ Immutable CI/CD pipelines & automated Dependabot monitoring         │
│   ✔ Tamper-resistant branch protection & push blocking at GitHub edge   │
│   ✔ Ready for public release and multi-pathway user consumption         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## ⚡ The 3 Sovereign Repo Lenses

Every repository created or ported by Repo Architect satisfies three demanding audiences simultaneously:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                       THE 3 SOVEREIGN REPO LENSES                       │
├─────────────────────┬─────────────────────┬─────────────────────────────┤
│ 🛡️ THE HACKER       │ 🛠️ THE DEVELOPER     │ ⚡ THE END-USER             │
│   (Cyber-Security)  │   (Peer / Contrib)  │   (Non-Technical / Fresh)   │
├─────────────────────┼─────────────────────┼─────────────────────────────┤
│ • OpenSSF Grade A   │ • Canonical Layout  │ • 5-Second Visual Hook      │
│ • Pinned Commit SHAs│ • Clean Separation  │ • 30-Second Quickstart      │
│   (Immutable CI)    │   (src/, tests/)    │ • Standalone 1-Line Install │
│ • Zero Path Leaks   │ • Full Local Loop   │ • Zero-Jargon Plain English │
│ • Push Rulesets     │ • API Contracts in  │ • Pre-Compiled Binary or    │
│   Block .sqlite/.env│   docs/architecture │   Portable Script Engine    │
└─────────────────────┴─────────────────────┴─────────────────────────────┘
```

---

## 🚀 Quickstart & Multi-Pathway Matrix

### Pathway 1: The Universal Porter CLI (`porter.ps1`)

The repository includes a sovereign **Porter Engine** (`porter.ps1`) that executes both self-management and repository modernization:

```powershell
# 1. Inspect Environment & Available Commands
pwsh ./porter.ps1

# 2. Port ANY Local Project or Directory into an OpenSSF Hardened Repo
pwsh ./porter.ps1 port "C:\Projects\my-legacy-tool" -Archetype cli

# 3. Register 'repo-architect' as a Global Terminal Command
pwsh ./porter.ps1 global
# (After reload, run 'repo-architect port <path>' or 'repo-architect audit' anywhere!)

# 4. Verify Self-Integrity, Script AST & Ruleset Schemas
pwsh ./porter.ps1 verify

# 5. Link / Install Plugin into Google Antigravity
pwsh ./porter.ps1 install -Symlink
```

---

### Pathway 2: Inside Google Antigravity (AI Agent & Chat)

The plugin is auto-discovered by Antigravity in `~/.gemini/config/plugins/repo-architect-plugin/`.

Interact with natural language or invoke the slash commands:

```text
/repo-architect audit              # 50ms security, path & OpenSSF scan of current repo
/repo-architect port [path]        # Full end-to-end porting of local directory into hardened repo
/repo-architect scaffold [type]    # Inject canonical archetype skeleton (cli, mcp, python, web)
/repo-architect vibe-security      # 5-Pass pre-launch defense (Client leaks, PII, IDOR, Attacker)
/repo-architect readme             # Author or upgrade high-density Dual-Audience README
/repo-architect secure             # Pin GitHub Actions to commit SHAs & inject least-privilege
/repo-architect ship               # Pre-flight audit, semantic commit & remote synchronization
```

---

### Pathway 3: Standalone Script Audit & Scaffolder

Run standalone scripts without touching your Antigravity environment:

```powershell
# Audit current directory (Strict mode fails on warnings)
pwsh -NoProfile -File ./skills/repo-architect/scripts/audit_repo.ps1 -Strict

# Scaffold canonical blueprints (cli | mcp | python | web | standard)
pwsh -NoProfile -File ./skills/repo-architect/scripts/scaffold_repo.ps1 -Archetype python
```

---

## 📊 Before vs. After Porting

| Aspect | ❌ Legacy / Local Workstation Codebase | 🏛️ After Repo Architect Porting |
| :--- | :--- | :--- |
| **Path Portability** | Leaked `C:\Users\<username>\...` in configs/code | Dynamic expansion via `Path.home()` or `[Environment]` |
| **Runtime State** | SQLite DBs & logs committed into Git history | Quarantined to `%LOCALAPPDATA%` or strictly ignored `.local/` |
| **Secrets & Keys** | Plaintext tokens or raw `.env` pushed to remote | Shielded via `.gitignore` + pristine `.env.example` template |
| **Line Endings** | Windows CRLF causing syntax errors on Linux CI | Enforced Unix LF for `*.sh` via `.gitattributes` |
| **CI/CD Security** | Mutable `@v4` action tags + full token permissions | Immutable 40-character commit SHAs + `permissions: contents: read` |
| **Edge Defense** | Accidental big files or DBs uploaded to GitHub | Declarative GitHub Rulesets block `.sqlite`, `.env`, >50MB |
| **Documentation** | Dense wall of text or missing quickstart | Inverted pyramid: 5-second hook + 30-second multi-pathway guide |
| **Compliance** | Missing governance policies | OpenSSF Grade A: `SECURITY.md`, `LICENSE`, `dependabot.yml` |

---

## 🏛️ Repository Architecture

```text
antigravity-repo-architect-plugin/
├── porter.ps1                             # Universal Porter Engine, Installer & CLI Gateway
├── plugin.json                            # Antigravity Plugin manifest & metadata
├── agents/
│   └── repo_architect.md                 # Autonomous Agent definition & execution modes
├── skills/
│   └── repo-architect/
│       ├── SKILL.md                      # Antigravity Skill instructions & command router
│       ├── scripts/
│       │   ├── audit_repo.ps1            # 50ms high-speed security, path & OpenSSF auditor
│       │   └── scaffold_repo.ps1         # Canonical repository scaffolder
│       ├── templates/
│       │   ├── ruleset_branch_baseline.json # GitHub default branch protection ruleset
│       │   └── ruleset_push_baseline.json   # GitHub push quarantine ruleset (*.sqlite, *.env, >50MB)
│       └── references/
│           ├── archetype_blueprints.md   # CLI, MCP, Python, Web canonical layouts
│           ├── dual_audience_readme_spec.md # Non-tech + peer dev progressive disclosure
│           ├── github_official_best_practices.md # Official GitHub & MS Learn repository patterns
│           ├── github_rulesets_governance.md # Server-side push quarantine & ruleset API
│           ├── motobook_github_coexistence.md # 4-Wall Quarantine & path invariants
│           ├── openssf_scorecard_hardening.md # Token least-privilege & SHA pinning
│           └── vibe_security_defense.md  # 5-Pass Pre-Launch Security (Gitleaks, Bearer, ECC)
├── .github/
│   ├── dependabot.yml                    # Automated dependency monitoring
│   ├── ISSUE_TEMPLATE/                   # Bug report and feature request templates
│   ├── PULL_REQUEST_TEMPLATE.md          # Standardized PR review checklist
│   └── workflows/
│       └── ci.yml                        # OpenSSF-hardened syntax & schema validation CI
├── .gitattributes                        # CRLF/LF line-ending firewall
├── .gitignore                            # Motobook runtime quarantine
├── LICENSE                               # MIT License
├── README.md                             # Dual-Audience documentation
└── SECURITY.md                           # OpenSSF vulnerability disclosure protocol
```

---

## ⚡ Core Operational Capabilities

### 1. 🚀 Universal Project Porter (`port`)
- Auto-detects programming stack and project layout.
- Initializes and repairs Git repository configuration.
- Injects `.gitattributes`, `.gitignore`, `.env.example`, and GitHub Rulesets.
- Runs post-porting audit certification to guarantee 100% compliance out of the box.

### 2. 📊 50ms High-Speed Repository Audit (`audit`)
- **Path Portability**: Recursively scans all source files for hardcoded local user paths (`C:\Users\<username>\...`, `%USERPROFILE%`).
- **Secret Shield**: Detects high-entropy API tokens (GitHub, OpenAI, GCP, AWS, Slack) and flags unshielded `.env` files.
- **State Quarantine**: Detects persistent databases (`*.sqlite`, `*.db`) inside the git working tree.
- **Line-Ending Firewall**: Verifies `.gitattributes` presence and enforces Unix LF for shell scripts to prevent bash syntax crashes on Linux/CI.
- **OpenSSF Workflow Check**: Audits GitHub Action workflows for mutable version tags (`@v4`) and verifies top-level `permissions: contents: read`.
- **Community Standards**: Validates `README.md`, `LICENSE`, and `SECURITY.md`.

### 3. 🧱 The 4-Wall Motobook ⇄ GitHub Quarantine
Solves the everyday challenge of developing and running code locally while syncing live to GitHub:
- **Wall 1: Runtime State Decoupling** (stores state in `%LOCALAPPDATA%` or ignored directories).
- **Wall 2: Zero-Config Dynamic Path Resolution** (dynamic expansion via standard libraries).
- **Wall 3: Dual-Stage Environment Shield** (`.env` ignored, `.env.example` committed).
- **Wall 4: CRLF/LF Line-Ending Firewall** (`.gitattributes` rules).
- **Wall 5: Server-Side Push Ruleset Quarantine** (GitHub push ruleset hard-rejects `*.sqlite`, `.env`, >50MB files at the edge).

### 4. 🏗️ Canonical Archetype Scaffolding (`scaffold`)
Generates production-ready configurations tailored to the project type:
- **Standalone CLI** (.NET / Rust / Go) + cross-platform release pipeline.
- **Antigravity Customization Plugin / MCP Server** with stdio manifests.
- **Modern Python Package** (PEP 518/621 `src/` layout with pyproject.toml).
- **Modern Fullstack Web Application** with frontend/backend isolation.

### 5. 🔒 OpenSSF Supply Chain Hardening & GitHub Rulesets (`secure`)
- Automatically injects pinned 40-character commit SHAs, least-privilege token permissions, and automated Dependabot configuration.
- Provides declarative GitHub Ruleset templates (`ruleset_branch_baseline.json`, `ruleset_push_baseline.json`) to enforce branch tamper resistance and server-side push filtering via GitHub API or web UI.

### 6. 🛡️ 5-Pass Vibe-Coding Pre-Launch Defense (`vibe-security`)
Evaluates applications against real-world breach patterns:
- **Pass 1 (Gitleaks)**: Scans for frontend prefix leaks (`NEXT_PUBLIC_`, `REACT_APP_`, `VITE_`), Supabase RLS gaps, and client-side Stripe secrets.
- **Pass 2 (Bearer)**: Audits personal data flows, PII in `console.log`, and enforces `httpOnly` cookies over `localStorage`.
- **Pass 3 (ECC Production Audit)**: Enforces startup environment validation, debug endpoint cleanup, generic error masking, and HTTP security headers.
- **Pass 4 (Trail of Bits)**: Validates IDOR protection, sovereign server-side payment logic, and SQL/XSS input sanitization.
- **Pass 5 (ECC Security Review)**: Probes privilege escalation, admin backdoor endpoints, and business logic exploits.

---

## 🛠️ Development, Verification & Reference Playbooks

### Local Self-Verification
Verify the entire plugin and audit engine locally:
```powershell
pwsh ./porter.ps1 verify
```

### Authoritative Reference Guides
- [GitHub Rulesets & Sovereign Governance](skills/repo-architect/references/github_rulesets_governance.md)
- [GitHub & Microsoft Official Best Practices](skills/repo-architect/references/github_official_best_practices.md)
- [5-Pass Vibe-Coding Security Defense](skills/repo-architect/references/vibe_security_defense.md)
- [OpenSSF Scorecard Hardening Guide](skills/repo-architect/references/openssf_scorecard_hardening.md)
- [The Motobook ⇄ GitHub Co-existence Guide](skills/repo-architect/references/motobook_github_coexistence.md)
- [Dual-Audience README Specification](skills/repo-architect/references/dual_audience_readme_spec.md)
- [Canonical Archetype Blueprints](skills/repo-architect/references/archetype_blueprints.md)

---

## 🛡️ Security & License

- **Security Disclosures**: Please see our [Security Policy](SECURITY.md) to report vulnerabilities privately.
- **License**: Distributed under the [MIT License](LICENSE).
