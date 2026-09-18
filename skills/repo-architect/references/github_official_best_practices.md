# 🏛️ GitHub & Microsoft Official Repository Best Practices

This guide synthesizes official documentation from **GitHub Docs**, **Microsoft Learn** (`maintain-secure-repository-github`), and **GitHub Skills** into actionable engineering standards for `/repo-architect`.

---

## 🛡️ 1. The GitHub Security Quadrant (Free for Public Repositories)

Microsoft Learn and GitHub Docs define the 4 foundational pillars of repository security:

```text
┌─────────────────────────────────────────────────────────────┐
│                 THE GITHUB SECURITY QUADRANT                │
├──────────────────────────────┬──────────────────────────────┤
│ 1. SECRET SCANNING &         │ 2. DEPENDABOT UPDATES        │
│    PUSH PROTECTION           │ • Weekly security alerts     │
│ • Real-time secret blocking  │ • Automated pull requests    │
│ • Detects 200+ token formats │ • Pinned version updates     │
├──────────────────────────────┼──────────────────────────────┤
│ 3. CODEQL CODE SCANNING      │ 4. PRIVATE VULNERABILITY     │
│ • Automated SAST on pull req │    REPORTING (PVR)           │
│ • Catches SQLi, XSS, IDOR    │ • Direct advisory submission │
│ • Semantic AST analysis      │ • Coordinated CVE publishing │
└──────────────────────────────┴──────────────────────────────┘
```

### Push Protection & Secret Scanning
- **Push Protection**: When enabled, GitHub blocks `git push` if a supported secret or high-entropy key is detected in the commit.
- **Remediation**: If a secret is caught, do not bypass push protection. Remove the secret, rewrite git history if necessary, and use environment variables.

### Automated Code Scanning with CodeQL
GitHub provides CodeQL static analysis to automatically inspect pull requests and main branch commits:
```yaml
name: "CodeQL Analysis"

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '30 1 * * 0' # Weekly scan

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
          languages: javascript-typescript # or python, csharp, go, etc.

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@b56ba49b26e50535fa1e7f7db0f4f7b4bf65d80d # v3.28.10
```

---

## 📝 2. GitHub Docs Content Design & Documentation Principles

According to GitHub Docs best practices:

### The Inverted Pyramid Principle
- **Conclusion First**: State the primary takeaway or outcome in the very first sentence.
- **Progressive Detail**: Readers scan and skim. Provide high-level context upfront and place granular implementation details lower on the page or in separate `docs/` articles.
- **Scannability**: Text formatting (bolding, highlights) should call attention to key concepts, but never exceed **10% of total text**.

### The 6 Canonical Content Types
When authoring documentation in `docs/`, map content strictly to one of GitHub's 6 recognized content types:
1. **Quickstart**: Fast-path to a working setup in under 5 minutes.
2. **Concepts**: High-level mental models and architectural definitions.
3. **How-To / Procedural**: Step-by-step goal-oriented recipes.
4. **Reference**: Exhaustive API parameters, CLI flags, and configuration schemas.
5. **Troubleshooting**: Diagnostic tables matching error messages to root causes.
6. **Tutorial**: End-to-end learning journeys building a complete project.

---

## 📦 3. Git Large File Storage (Git LFS) & Repository Size Governance

GitHub enforces strict limits on file and repository sizes:
- **Maximum individual file size**: 100 MB (pushes blocked if a file exceeds 100 MB).
- **Warning threshold**: 50 MB (GitHub warns developers during push).
- **Repository recommendation**: Keep total repository size under 1 GB, with an absolute hard limit of 5 GB.

### Git LFS Standard
Any binary asset, large test dataset, or compiled model exceeding 50 MB must be tracked via **Git Large File Storage (Git LFS)** in `.gitattributes`:
```gitattributes
# Git LFS Large Media & Binary Tracking
*.psd filter=lfs diff=lfs merge=lfs -text
*.aab filter=lfs diff=lfs merge=lfs -text
*.onnx filter=lfs diff=lfs merge=lfs -text
*.bin filter=lfs diff=lfs merge=lfs -text
*.tar.gz filter=lfs diff=lfs merge=lfs -text
```

---

## 📋 4. Projects & Issue Decomposition (GitHub Best Practices)

- **Sub-Issues & Hierarchy**: Large architectural tasks must be broken down into parent issues with nested sub-issues.
- **Branching Over Forking**: For core project development and internal tools, use feature branches (`feature/<name>`, `fix/<name>`) off `main` rather than cross-repo forks.
- **Single Source of Truth**: Metadata (milestones, assignees, target release dates) should live in GitHub Projects rather than duplicated across commit messages or ad-hoc markdown files.
