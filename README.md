# 🏛️ antigravity-repo-architect-plugin

> **Autonomous GitHub Repository Architect, OpenSSF Security Hardener & Dual-Audience Documentation Engine for Google Antigravity.**

An enterprise-grade Antigravity plugin engineered to bridge the gap between building tools locally on a developer workstation and publishing world-class, production-ready repositories on GitHub. It combines an autonomous AI agent (`repo_architect`), specialized skills, a Win32/PowerShell 7 audit engine (`audit_repo.ps1`), and OpenSSF supply-chain hardening playbooks.

---

## 🏛️ Architecture

```text
antigravity-repo-architect-plugin/
├── agents/
│   └── repo_architect.md                 # Autonomous Agent definition
├── plugin.json                           # Antigravity Plugin manifest
├── skills/
│   └── repo-architect/
│       ├── SKILL.md                      # Antigravity Skill instructions & command router
│       ├── scripts/
│       │   ├── audit_repo.ps1            # 50ms high-speed security, path & OpenSSF auditor
│       │   └── scaffold_repo.ps1         # Canonical repository scaffolder
│       └── references/
│           ├── archetype_blueprints.md   # CLI, MCP, Python, Web layouts
│           ├── dual_audience_readme_spec.md # Non-tech + peer dev progressive disclosure
│           ├── motobook_github_coexistence.md # 4-Wall Quarantine & path invariants
│           └── openssf_scorecard_hardening.md # Token least-privilege & SHA pinning
├── .gitattributes
├── .gitignore
├── LICENSE
└── README.md
```

---

## ⚡ The 3 Sovereign Repo Lenses

```text
┌─────────────────────────────────────────────────────────────┐
│                 THE 3 SOVEREIGN REPO LENSES                 │
├───────────────────┬───────────────────┬─────────────────────┤
│ 🛡️ THE HACKER     │ 🛠️ THE DEVELOPER   │ ⚡ THE END-USER     │
│   (Cyber-Security)│   (Peer / Contrib)│   (Non-Tech / Nerd) │
├───────────────────┼───────────────────┼─────────────────────┤
│ • OpenSSF Grade A │ • Clean Layout    │ • 5-Second Hook     │
│ • Pinned Action   │ • Separated src/  │ • 1-Line Quickstart │
│   Commit SHAs     │   and tests/      │ • Pre-Compiled      │
│ • Zero Path Leaks │ • Full Dev Loop   │   Standalone .exe   │
│ • Zero Secrets    │ • API Contracts   │ • Zero Jargon       │
└───────────────────┴───────────────────┴─────────────────────┘
```

---

## 🚀 Quickstart

### Option A: Using inside Google Antigravity
The plugin is automatically discovered by Antigravity in `~/.gemini/config/plugins/repo-architect-plugin/`.

Trigger it with natural language or slash commands in chat:
```text
/repo-architect audit
/repo-architect scaffold cli
/repo-architect readme
/repo-architect secure
/repo-architect ship
```

### Option B: Standalone PowerShell CLI
Run the high-speed security and path auditor directly in any repository:
```powershell
pwsh -NoProfile -File ~/.gemini/config/plugins/repo-architect-plugin/skills/repo-architect/scripts/audit_repo.ps1
```

Or scaffold a new repository archetype:
```powershell
pwsh -NoProfile -File ~/.gemini/config/plugins/repo-architect-plugin/skills/repo-architect/scripts/scaffold_repo.ps1 -Archetype cli
```

---

## ⚡ Core Capabilities

1. **📊 50ms High-Speed Repository Audit (`audit`)**:
   - **Path Portability**: Recursively scans all source files for hardcoded local user paths (`C:\Users\<username>\...`, `%USERPROFILE%`).
   - **Secret Shield**: Detects high-entropy API tokens (GitHub, OpenAI, GCP, AWS, Slack) and flags unignored `.env` files.
   - **State Quarantine**: Detects persistent databases (`*.sqlite`, `*.db`) inside the git working tree.
   - **Line-Ending Firewall**: Verifies `.gitattributes` presence and enforces Unix LF for shell scripts to prevent bash syntax crashes on Linux/CI.
   - **OpenSSF Workflow Check**: Audits GitHub Action workflows for mutable version tags (`@v4`) and verifies top-level `permissions: contents: read`.
   - **Community Standards**: Checks for `README.md`, `LICENSE`, and `SECURITY.md`.

2. **🧱 The 4-Wall Motobook ⇄ GitHub Quarantine**:
   - Solves the everyday challenge of developing and running code locally while syncing live to GitHub:
     - *Wall 1: Runtime State Decoupling* (stores state in `%LOCALAPPDATA%` or ignored directories).
     - *Wall 2: Zero-Config Dynamic Path Resolution* (dynamic expansion via standard libraries).
     - *Wall 3: Dual-Stage Environment Shield* (`.env` ignored, `.env.example` committed).
     - *Wall 4: CRLF/LF Line-Ending Firewall* (`.gitattributes` rules).

3. **🏗️ Canonical Archetype Scaffolding (`scaffold`)**:
   - Generates production-ready configurations tailored to the project type:
     - **Standalone CLI** (.NET / Rust / Go)
     - **Antigravity Customization Plugin / MCP Server**
     - **Modern Python Package** (PEP 518/621 `src/` layout)
     - **Modern Fullstack Web Application**

4. **📄 Dual-Audience README Engine (`readme`)**:
   - Enforces Progressive Disclosure: 5-second visual hook (ASCII box card) and 30-second quickstart for end-users, with deep architectural links (`docs/architecture.md`) for engineers.

5. **🔒 OpenSSF Supply Chain Hardening (`secure`)**:
   - Automatically injects pinned 40-character commit SHAs, least-privilege token permissions, and automated Dependabot configuration.

---

## 🛠️ Development & Contributing

### Local Verification
Run the auditor against the plugin itself:
```powershell
pwsh -NoProfile -File ./skills/repo-architect/scripts/audit_repo.ps1
```

For detailed architectural specs, see:
- [OpenSSF Scorecard Hardening Guide](skills/repo-architect/references/openssf_scorecard_hardening.md)
- [The Motobook ⇄ GitHub Co-existence Guide](skills/repo-architect/references/motobook_github_coexistence.md)
- [Dual-Audience README Specification](skills/repo-architect/references/dual_audience_readme_spec.md)
- [Canonical Archetype Blueprints](skills/repo-architect/references/archetype_blueprints.md)

---

## 🛡️ Security & License

- **Security Disclosures**: Please see our [Security Policy](SECURITY.md) to report vulnerabilities privately.
- **License**: Distributed under the [MIT License](LICENSE).
