---
name: repo-architect
description: >-
  Autonomous GitHub Repository Architect, OpenSSF Security Hardener & Dual-Audience Documentation Engine.
  Use when structuring a new repository, retrofitting a local project for GitHub, auditing for leaked paths
  or secrets, hardening GitHub Actions CI/CD to OpenSSF standards, or authoring progressive disclosure READMEs.
---

# 🏛️ Repo Architect: Open-Source Scaffolding & Security Engine

Use this skill whenever you are **creating a new project, retrofitting a local Motobook tool for GitHub, or preparing a repository for public release**.

Repo Architect enforces three world-class standards simultaneously:
1. **🛡️ The Cyber-Security & OpenSSF Hardening Standard**: Zero secret leaks, least-privilege token permissions, actions pinned to 40-character commit SHAs, and coordinated vulnerability disclosure.
2. **⚡ The Motobook ⇄ GitHub Co-existence Invariant**: Zero machine-specific paths (`C:\Users\<username>\...`), runtime state quarantined outside git-tracked trees, and CRLF/LF firewall via `.gitattributes`.
3. **📄 The Dual-Audience Documentation Standard**: 5-second visual hook (ASCII flowcards) + 30-second quickstart for non-technical users, coupled with deep architectural documentation (`docs/architecture.md`) for peer developers.

---

## ⚡ Core Operational Commands & Modes

```text
┌─────────────────────────────────────────────────────────────┐
│                 REPO-ARCHITECT COMMAND MATRIX               │
├───────────────────┬─────────────────────────────────────────┤
│ /repo-architect   │ 50ms security, path & OpenSSF scan of   │
│ audit             │ the current working directory           │
├───────────────────┼─────────────────────────────────────────┤
│ /repo-architect   │ Injects .github/, .gitattributes,       │
│ scaffold [type]   │ .gitignore, templates & security policy │
├───────────────────┼─────────────────────────────────────────┤
│ /repo-architect   │ 5-Pass deep vibe-coding security review │
│ vibe-security     │ (Client leaks, PII, IDOR, Attacker view)│
├───────────────────┼─────────────────────────────────────────┤
│ /repo-architect   │ Generates or refactors README using the │
│ readme            │ Dual-Audience Progressive Disclosure    │
├───────────────────┼─────────────────────────────────────────┤
│ /repo-architect   │ Scans & pins GitHub Action tags to SHAs │
│ secure            │ and enforces least-privilege permissions│
├───────────────────┼─────────────────────────────────────────┤
│ /repo-architect   │ Complete pre-flight release audit,      │
│ ship              │ semantic version bump & git sync        │
└───────────────────┴─────────────────────────────────────────┘
```

---

## 🛠️ Detailed Command Workflows

### 1. 🔍 Repository Audit (`audit`)
Executes the native high-speed auditor on the current repository:
```powershell
pwsh -NoProfile -File ~/.gemini/config/plugins/repo-architect-plugin/skills/repo-architect/scripts/audit_repo.ps1
```
Audits for:
- Absolute local path leaks (`C:\Users\`, `%USERPROFILE%`).
- Secret exposures (OpenAI, GitHub, GCP, AWS keys, unignored `.env`).
- Motobook runtime database pollution (`*.sqlite`, `*.db` inside git tree).
- Missing `.gitattributes` or missing LF normalization for shell scripts (`*.sh`).
- OpenSSF CI/CD posture (unpinned GitHub Actions `@v4`, missing `permissions: contents: read`).
- GitHub community health files (`README.md`, `LICENSE`, `SECURITY.md`).

### 2. 🏗️ Canonical Scaffolding (`scaffold <archetype>`)
Scaffolds all missing GitHub assets according to project archetype:
```powershell
pwsh -NoProfile -File ~/.gemini/config/plugins/repo-architect-plugin/skills/repo-architect/scripts/scaffold_repo.ps1 -Archetype [cli|mcp|python|web|standard]
```
- Select archetype from canonical blueprints:
  - `cli`: Standalone native executable (.NET, Rust, Go) + binary release pipeline.
  - `mcp`: Antigravity / Claude MCP server with STDIO specs & manifest.
  - `python`: `src/` layout with `pyproject.toml` and type markers.
  - `web`: Fullstack service with frontend/backend isolation and `.dockerignore`.
  - `standard`: Generic library/tooling layout.

### 3. 📄 Dual-Audience README Engine (`readme`)
Drafts or restructures `README.md` following the [Dual-Audience Specification](./references/dual_audience_readme_spec.md):
- **Hero & 5-Second Hook**: Clean badge set, 1-line plain English purpose, native ASCII box card (`┌───┐ ──► └───┘`).
- **30-Second Quickstart**: Multi-pathway options:
  - Option A: Standalone pre-compiled binary download (Zero dev dependencies).
  - Option B: 1-line copy-paste command (`curl | pwsh` or `winget`).
  - Option C: Package manager or local dev build from source.
- **Progressive Disclosure**: Summarizes build steps in root README and anchors deep internals to `docs/architecture.md`.

### 4. 🛡️ 5-Pass Vibe-Coding Security Review (`vibe-security`)
Performs a deep pre-launch application security review based on [Vibe Security Defense](./references/vibe_security_defense.md):
- **Pass 1 (Gitleaks)**: Secret relocation, frontend prefix quarantine (`NEXT_PUBLIC_`, `REACT_APP_`, `VITE_`), Supabase RLS verification, Stripe key separation.
- **Pass 2 (Bearer)**: Personal data mapping, log redaction, ban on storing auth tokens/PII in `localStorage`, bcrypt/argon2 hashing.
- **Pass 3 (ECC Production Audit)**: Environment startup validation, debug removal, generic error responses without stack traces, security headers (`helmet`), rate limiting, CORS domain isolation.
- **Pass 4 (Trail of Bits)**: IDOR & resource ownership checks, sovereign server-side payment logic, SQL parameterization, XSS input sanitization, file upload magic-byte verification.
- **Pass 5 (ECC Security Review)**: Proactive attacker review: privilege escalation, admin backdoor probes, feature abuse, and business logic flaws.

### 5. 🔒 OpenSSF Hardening & GitHub Rulesets (`secure`)
Hardens all workflow files and repository branch/push protections:
- Injects top-level `permissions: contents: read`.
- Pins all third-party actions to immutable commit SHAs with inline version hints:
  ```yaml
  uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
  ```
- Ensures `.github/dependabot.yml` is present.
- Injects standard `SECURITY.md`.
- **GitHub Rulesets Provisioning**: Deploys declarative ruleset JSON templates (`templates/ruleset_branch_baseline.json` and `templates/ruleset_push_baseline.json`) to enforce server-side push filtering (blocking `.sqlite`, `.env`, >50MB files at the GitHub edge) and block force pushes on default branches.

### 6. 🚢 Pre-Flight Release & Shipping (`ship`)
Before pushing commits to GitHub:
1. Run `audit_repo.ps1 -Strict`.
2. Verify all uncommitted files are accounted for (zero untracked scratch files).
3. Verify `README.md` and `CHANGELOG.md` are synchronized with code changes.
4. Execute git commit with semantic convention (`feat:`, `fix:`, `refactor:`).
5. Push to remote origin `main` and draft release tag if applicable.

---

## 📚 Deep Reference Playbooks

Before executing complex repository overhauls, consult the authoritative references:
- **[GitHub Rulesets & Sovereign Governance](./references/github_rulesets_governance.md)**: Server-side push quarantine, branch protections, and declarative JSON deployment.
- **[GitHub & Microsoft Official Best Practices](./references/github_official_best_practices.md)**: Security quadrant, CodeQL SAST, Inverted Pyramid docs, Git LFS size governance.
- **[The 5-Pass Vibe-Coding Security Defense](./references/vibe_security_defense.md)**: Gitleaks, Bearer, ECC Production Audit, Trail of Bits, and Attacker Review.
- **[OpenSSF Scorecard Hardening Guide](./references/openssf_scorecard_hardening.md)**: Action pinning table, permissions model, supply chain defense.
- **[The Motobook ⇄ GitHub Co-existence Guide](./references/motobook_github_coexistence.md)**: The 4-Wall Quarantine, path portability, and runtime state isolation.
- **[Dual-Audience README Specification](./references/dual_audience_readme_spec.md)**: The 5-second hook, multi-pathway quickstarts, progressive disclosure.
- **[Canonical Archetype Blueprints](./references/archetype_blueprints.md)**: Layout templates for CLI, MCP, Python, and Web apps.
