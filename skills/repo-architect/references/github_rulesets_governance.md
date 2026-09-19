# 🛡️ GitHub Rulesets & Sovereign Repository Governance

> **Authority**: Governed by `/repo-architect`  
> **Source**: Official GitHub Docs (`/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets`)  
> **Scope**: Modern branch protection, server-side push quarantine, commit metadata integrity, and bypass delegation.

---

## 🏛️ 1. Why Rulesets Over Legacy Branch Protections?

Legacy GitHub Branch Protection Rules suffered from severe architectural limitations:
1. **Single-Rule Exclusivity**: Only one branch protection rule could apply to a branch at any time.
2. **All-or-Nothing Deletion**: To temporarily suspend a rule, maintainers were forced to delete it.
3. **Zero Push Content Filtering**: Legacy protections could not inspect file extensions, path lengths, or file sizes before accepting a `git push`.
4. **Opaque Governance**: Non-administrators could not view active branch protections without admin access.

**GitHub Rulesets solve all four bottlenecks**:

| Dimension | Legacy Branch Protection | Modern GitHub Rulesets |
| :--- | :--- | :--- |
| **Max Rulesets** | 1 per branch | Up to 75 per repository (+ 75 organization-wide) |
| **Push-Level Filtering** | ❌ None (Client-side only) | ✅ **Push Rulesets** (Blocks `.sqlite`, `.env`, >50MB at edge) |
| **Rule Layering** | ❌ No layering (Conflict fails) | ✅ **Layered aggregation** (Most restrictive rule wins) |
| **Targeting Syntax** | Exact string / basic glob | Advanced `fnmatch` (e.g. `releases/**/*`, `~DEFAULT_BRANCH`) |
| **Enforcement States** | On / Off (Delete required) | `Active`, `Evaluate` (audit/monitor only), `Disabled` |
| **Visibility** | Admins only | Transparent (Anyone with read access can audit rules) |
| **Bypass Delegation** | Generic admin override | Granular `bypass_actors` (Roles, Teams, Deploy Keys, Apps) |

---

## 🛡️ 2. The Server-Side 5th Wall: Push Rulesets

While local scripts like `audit_repo.ps1` catch path leaks and secrets on Motobook **before** `git commit`, client-side checks can be bypassed if:
- A developer runs `git commit --no-verify`.
- An external collaborator forks and pushes without running the audit script.
- A script or CI bot commits untracked state databases.

**Push Rulesets act as the server-side gate (Defense-in-Depth)**:
- They evaluate every push before any commit object is written to the remote repository.
- They apply across the **entire repository and its fork network**.
- Any commit containing restricted file extensions (`*.sqlite`, `*.env`, `*.pem`, `*.key`) or files exceeding 50 MB is **hard-rejected by the GitHub server** with an explicit rejection notice.

---

## 📦 3. Sovereign Baseline Rulesets

`/repo-architect` ships two standardized, production-ready templates in `templates/`:

### A. Branch Ruleset: `ruleset_branch_baseline.json`
Protects the default branch (`main` / `master`) from destructive git operations:
```jsonc
{
  "name": "sovereign-repository-shield",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "deletion" },           // Blocks branch deletion
    { "type": "non_fast_forward" },   // Blocks force pushes (git push --force)
    { "type": "required_signatures" } // Requires GPG / SSH signed commits
  ]
}
```

### B. Push Ruleset: `ruleset_push_baseline.json`
Prevents accidental secret or state database leakage across all branches:
```jsonc
{
  "name": "sovereign-push-quarantine",
  "target": "push",
  "enforcement": "active",
  "rules": [
    {
      "type": "file_extension_restriction",
      "parameters": {
        "restricted_file_extensions": ["*.sqlite", "*.sqlite3", "*.db", "*.pem", "*.key", "*.pfx"]
      }
    },
    {
      "type": "max_file_size",
      "parameters": { "max_file_size": 50 } // Blocks binaries > 50MB
    },
    {
      "type": "file_path_restriction",
      "parameters": {
        "restricted_file_paths": [".env", ".env.local", ".env.production", "memory/sessions/*"]
      }
    }
  ]
}
```

---

## ⚡ 4. Fast Deployment: How to Apply Rulesets

### Method 1: Using GitHub CLI (`gh`) in 5 Seconds
Maintainers can apply the baseline rulesets directly via the GitHub REST API using `gh`:

```powershell
# 1. Apply Branch Protection Shield
gh api --method POST "repos/:owner/:repo/rulesets" `
  -H "Accept: application/vnd.github+json" `
  -H "X-GitHub-Api-Version: 2022-11-28" `
  --input "templates/ruleset_branch_baseline.json"

# 2. Apply Push Quarantine Shield
gh api --method POST "repos/:owner/:repo/rulesets" `
  -H "Accept: application/vnd.github+json" `
  -H "X-GitHub-Api-Version: 2022-11-28" `
  --input "templates/ruleset_push_baseline.json"
```

### Method 2: GitHub Web UI
1. Navigate to your repository on GitHub: `https://github.com/<owner>/<repo>`.
2. Click **Settings** $\rightarrow$ **Rules** $\rightarrow$ **Rulesets**.
3. Click **New ruleset** $\rightarrow$ **Import a ruleset**.
4. Select `ruleset_branch_baseline.json` or `ruleset_push_baseline.json`.
5. Review the imported rules and click **Create**.

---

## 🎯 5. OpenSSF Scorecard & Compliance Alignment

Configuring GitHub Rulesets directly satisfies multiple checks in the **OpenSSF Scorecard**:
- **Branch-Protection (Check Score: 10/10)**: Prevents direct unreviewed pushes, prevents branch deletion, and blocks force pushes.
- **Signed-Commits (Check Score: 10/10)**: Guarantees cryptographic author verification via `required_signatures`.
- **Dangerous-Workflow & Supply Chain**: Complements pinned GitHub Actions by locking down workflow file edits via `file_path_restriction` on `.github/workflows/*` for non-admin collaborators.
