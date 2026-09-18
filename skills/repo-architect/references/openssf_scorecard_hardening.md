# 🛡️ OpenSSF Scorecard & GitHub Supply Chain Hardening Guide

The **Open Source Security Foundation (OpenSSF) Scorecard** assesses software repositories on 18 critical security heuristics. This guide defines the exact invariants enforced by `/repo-architect` to achieve maximum security scores and protect repositories against supply chain attacks.

---

## 🔒 1. Principle of Least Privilege: Workflow Permissions

By default, GitHub Actions may run with overly broad `GITHUB_TOKEN` permissions (`write-all`). This creates a critical attack surface: if an attacker compromises a dependency or injects code via a malicious PR, they can push commits, create releases, or overwrite repository assets.

### 🛑 Anti-Pattern
```yaml
# Vulnerable: Implicit broad write permissions
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps: ...
```

### ✅ OpenSSF Hardened Standard
Every workflow must declare top-level read-only permissions, and elevate only the specific job that requires writes:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# Top-level: Restrict all default permissions to read-only
permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      # Tests run with pure read access

  release:
    needs: test
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write # Elevated strictly for uploading release assets
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Create Release
        uses: softprops/action-gh-release@c062e08bd532815e2082a85e87e3ef29c3e6d191 # v2.0.8
        with:
          files: artifacts/*
```

---

## 📌 2. Action Pinning to Full Commit SHAs

GitHub tags (such as `@v4` or `@v4.2.2`) are mutable pointers. If an upstream maintainer's account is compromised, the tag can be moved to point to malicious code that executes in your runner and exfiltrates repository secrets.

### 🛑 Anti-Pattern
```yaml
uses: actions/checkout@v4 # Risky: Mutable tag pointer
uses: actions/setup-node@v4
```

### ✅ OpenSSF Hardened Standard
Pin third-party actions to their 40-character immutable commit SHA, appending the version tag as an inline comment for human readability:

| Action | Pinned Commit SHA (Canonical) | Human Tag |
| :--- | :--- | :--- |
| `actions/checkout` | `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` | `# v4.2.2` |
| `actions/setup-node` | `actions/setup-node@39370e3970a6d050c480ffad4ff0ed4d3fdee5af` | `# v4.1.0` |
| `actions/setup-python` | `actions/setup-python@0b93645e9fb717ef6b1d47a844d41e7f3170abb8` | `# v5.3.0` |
| `actions/setup-dotnet` | `actions/setup-dotnet@3951f0dfe7b07e2d477b5226e60ec66e04d0f325` | `# v4.1.0` |
| `actions/upload-artifact` | `actions/upload-artifact@b4b15b8c7c6ac21ea08fcf65804d6323fe52e4e5` | `# v4.4.3` |
| `actions/download-artifact` | `actions/download-artifact@fa0a91b85d4f404e444e00e005971372dc801d16` | `# v4.1.8` |
| `softprops/action-gh-release` | `softprops/action-gh-release@c062e08bd532815e2082a85e87e3ef29c3e6d191` | `# v2.0.8` |

---

## ⚠️ 3. Dangerous Workflow Triggers Elimination

### The `pull_request_target` Trap
`pull_request_target` runs in the context of the base repository (granting access to repository secrets and write tokens). If you check out the code from the pull request fork inside `pull_request_target`, an attacker can open a PR that runs arbitrary malicious code to steal your production secrets.

**Mandatory Rule**: Never checkout untrusted pull request code within a workflow triggered by `pull_request_target`. Use `pull_request` instead, which runs with read-only permissions and no access to secrets.

---

## 🤖 4. Automated Dependency Governance (`dependabot.yml`)

Every production repository must include `.github/dependabot.yml` to automatically detect out-of-date and vulnerable dependencies:

```yaml
version: 2
updates:
  # Maintain GitHub Actions dependencies
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "security"

  # Maintain language package ecosystem (e.g. npm, pip, cargo, nuget)
  - package-ecosystem: "npm" # or "pip", "cargo", "nuget"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
```

---

## 🛡️ 5. Coordinated Security Disclosure (`SECURITY.md`)

OpenSSF requires an explicit security policy so security researchers know how to report vulnerabilities without exposing them publicly.

Place `SECURITY.md` in repository root:
```markdown
# Security Policy

## Supported Versions
Only the latest released major version receives active security patches.

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| <latest | :x:                |

## Reporting a Vulnerability
**Do not open a public GitHub issue for security vulnerabilities.**

Please report security issues privately via:
1. GitHub Private Vulnerability Reporting (preferred).
2. Email: `security@<domain>` (or designated contact).

Please provide:
- A description of the vulnerability and potential impact.
- Steps to reproduce or proof-of-concept code.
- Mitigation suggestions if available.

We will acknowledge reports within 48 hours and coordinate a coordinated disclosure.
```
