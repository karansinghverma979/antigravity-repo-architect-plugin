# 🏛️ Repo Architect: Operational Rules & Repository Invariants

Whenever authoring code, generating configurations, modifying CI/CD workflows, or inspecting software repositories, all Antigravity agents must strictly obey these directives:

---

### 1. 🛡️ The Zero Absolute Local User Path Invariant
* **MANDATORY**: Never allow machine-specific local paths like `C:\Users\<username>\...`, `/Users/<username>/...`, or `%USERPROFILE%` to leak into git-tracked source code, JSON configs, or markdown documentation.
* **Enforce Dynamic Expansion**:
  - Python: `Path.home()` or `os.path.expanduser('~')`
  - PowerShell: `[Environment]::GetFolderPath('UserProfile')` or `$HOME`
  - Node.js: `os.homedir()`
  - Rust: `dirs::home_dir()`
  - Go: `os.UserHomeDir()`
* In documentation, always wrap placeholder paths with angle brackets (e.g., `C:\Users\<username>\...`).

---

### 2. ⚡ Runtime State Decoupling (Motobook Invariant)
* Runtime databases (`*.sqlite`, `*.db`, `*.sqlite3`), persistent caches, and session telemetry logs must **never** be committed into the git working tree.
* Isolate runtime data to:
  1. Operating System Data Directory: `%LOCALAPPDATA%/<app>/` (Windows) or `~/.local/share/<app>/` (Linux/macOS).
  2. Strictly git-ignored local directories (e.g. `.local/`, `data/`).
* Always trap `.env` in `.gitignore` and commit a sanitized `.env.example` with dummy values.

---

### 3. 🔒 OpenSSF Least-Privilege CI/CD Standard
* Every GitHub Actions workflow (`.github/workflows/*.yml`) must explicitly declare top-level read-only permissions:
  ```yaml
  permissions:
    contents: read
  ```
* Never grant broad `write-all` permissions across workflow runs. Scopes that require write permissions (such as release uploads or security alerts) must be isolated to the specific job or step.

---

### 4. 📌 Immutable 40-Character Commit SHA Pinning
* Every third-party GitHub Action must be pinned to an immutable 40-character commit SHA rather than a mutable version tag (e.g. `@v4` or `@main`), preventing supply-chain tag-hijacking:
  ```yaml
  uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
  ```
* Include the human-readable version tag as an inline comment hint.

---

### 5. 🧱 CRLF / LF Line-Ending Firewall
* Every repository must include a `.gitattributes` file at the repository root.
* Shell scripts (`*.sh`) must explicitly enforce Unix line endings (`*.sh text eol=lf`) to prevent bash syntax crashes on Linux CI runners and Docker containers.

---

### 6. 📄 Dual-Audience Documentation Standard
Always structure repository documentation using the **Inverted Pyramid of Progressive Disclosure**:
1. **The 5-Second Hook**: High-impact brand poster/logo, status badges, 1-line plain English purpose, and native ASCII architecture box card.
2. **The 30-Second Quickstart**: Standalone binary download or 1-line copy-paste installer for non-technical users, alongside local dev build commands.
3. **Deep Architectural Links**: Separate internal low-level implementation details into `docs/architecture.md` to avoid cognitive overload in root `README.md`.

---

### 7. 🛡️ The 5-Pass Vibe-Coding Pre-Launch Defense
Before any web application or API is pushed or published:
- **Pass 1 (Gitleaks)**: Zero hardcoded secrets, frontend prefix quarantine (`NEXT_PUBLIC_`, `REACT_APP_`, `VITE_`), Supabase RLS verification.
- **Pass 2 (Bearer)**: Personal data flow mapping, console log redaction, ban on auth tokens in `localStorage`, cryptographic hashing (`argon2`/`bcrypt`).
- **Pass 3 (ECC Production Audit)**: Mandatory startup env validation, debug endpoint cleanup, generic client errors without stack traces, security headers (`helmet`).
- **Pass 4 (Trail of Bits)**: IDOR ownership verification on every endpoint, sovereign server-side payment verification, SQL parameterization.
- **Pass 5 (ECC Security Review)**: Proactive attacker review: privilege escalation, admin backdoor probes, and business logic flaws.
