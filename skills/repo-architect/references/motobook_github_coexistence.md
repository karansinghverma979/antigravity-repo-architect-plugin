# ⚡ The Motobook ⇄ GitHub Co-existence & Live Security Invariant

When developing tools, skills, or applications on a daily primary workstation (`Motobook`), developers face a fundamental tension:
> **You run and execute the code locally every single day (relying on local databases, local ports, user directories, and private environment keys), while simultaneously pushing live commits to a public GitHub repository.**

Without a strict architectural boundary, this duality inevitably leads to:
1. Leaking private tokens, API keys, or database rows into GitHub commit history.
2. Hardcoding machine-specific paths (e.g. `C:\Users\<username>\...`) that break when other developers or CI runners execute the project.
3. Committing dirty runtime state (`*.sqlite`, `*.log`, session cache) that causes merge conflicts and repository bloat.
4. Git line-ending clashes (Windows CRLF vs Linux/CI LF) that corrupt shell scripts.

---

## 🏛️ The 4-Wall Quarantine Architecture

To achieve zero-friction local execution alongside 100% public hygiene, every project must implement the **4-Wall Quarantine**:

```text
┌─────────────────────────────────────────────────────────────┐
│                    THE 4-WALL QUARANTINE                    │
├─────────────────────────────────────────────────────────────┤
│ WALL 1: RUNTIME STATE DECOUPLING                            │
│ Zero databases or logs in git-tracked paths                 │
├─────────────────────────────────────────────────────────────┤
│ WALL 2: ZERO-CONFIG DYNAMIC PATH RESOLUTION                 │
│ Dynamic OS expansion, zero hardcoded user paths             │
├─────────────────────────────────────────────────────────────┤
│ WALL 3: DUAL-STAGE ENVIRONMENT SHIELD                       │
│ .env strictly ignored, .env.example committed               │
├─────────────────────────────────────────────────────────────┤
│ WALL 4: CRLF/LF LINE-ENDING FIREWALL                        │
│ .gitattributes normalizes text eol and forces LF on .sh     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧱 Wall 1: Runtime State Decoupling

**The Golden Rule**: The git working directory must only contain **stateless source code, static assets, and configurations**. Never allow runtime databases or session files to live directly inside the repository tree unless placed in an explicitly ignored directory.

### ✅ Recommended State Paths
1. **OS User Data Directories (Best Practice)**:
   - Windows: `%LOCALAPPDATA%/<app-name>/` or `%USERPROFILE%/.<app-name>/`
   - Linux/Termux: `~/.local/share/<app-name>/` or `$XDG_DATA_HOME/<app-name>/`
2. **Ignored Local Quarantine Directory**:
   If state must reside relative to the project, isolate it in `.local/`, `data/`, or `storage/` and add to `.gitignore`:
   ```gitignore
   # Runtime state quarantine
   .local/
   data/*.sqlite
   data/*.db
   storage/
   logs/
   *.log
   ```

---

## 🧱 Wall 2: Zero-Config Dynamic Path Resolution

**The Invariant**: Source code, test scripts, and configurations must **NEVER** hardcode absolute local paths (`C:\Users\<username>\...`, `/home/<username>/...`).

### 🛑 Anti-Pattern
```python
# Broken on GitHub & other machines
DB_PATH = "C:\\Users\\<username>\\data\\app.sqlite"
```

### ✅ Portable Dynamic Resolution
Use standard library home resolution or environment overrides:

#### Python
```python
from pathlib import Path
import os

# 1. Check environment variable override
# 2. Fallback to OS user directory
APP_DIR = Path(os.getenv("APP_DATA_DIR") or (Path.home() / ".local" / "share" / "my_tool"))
APP_DIR.mkdir(parents=True, exist_ok=True)
DB_PATH = APP_DIR / "app.sqlite"
```

#### PowerShell / .NET
```powershell
$AppDir = if ($env:APP_DATA_DIR) { 
    $env:APP_DATA_DIR 
} else { 
    Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "my_tool" 
}
if (-not (Test-Path $AppDir)) { New-Item -ItemType Directory -Path $AppDir -Force }
```

#### Node.js / TypeScript
```typescript
import os from 'os';
import path from 'path';

const appDir = process.env.APP_DATA_DIR || path.join(os.homedir(), '.config', 'my_tool');
```

---

## 🧱 Wall 3: Dual-Stage Environment Shield

When a tool requires API credentials (e.g. OpenAI, Anthropic, GitHub Tokens, Database Passwords):
1. **`.env` (Private Local State)**: Contains actual working keys. **Must be included in `.gitignore`**.
2. **`.env.example` (Public Blueprint)**: Contains dummy placeholder keys and descriptive comments. **Must be tracked in git**.

### Example `.env.example`
```bash
# Server Configuration
PORT=8080
NODE_ENV=development

# Authentication Secrets (Replace with your actual keys in your local .env)
API_SECRET_KEY=your_secret_key_here
DATABASE_URL=sqlite:///./data/dev.sqlite
```

---

## 🧱 Wall 4: CRLF / LF Line-Ending Firewall

Windows workstations checkout files with `CRLF` (`\r\n`) by default. If a shell script (`.sh`) or GitHub Action is committed with `CRLF`, bash fails with `\r: command not found`.

Every repository must contain a `.gitattributes` at root:
```gitattributes
# Auto-detect text files and normalize to LF in git index
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

# Windows PowerShell scripts require CRLF
*.ps1 text eol=crlf
*.bat text eol=crlf
*.cmd text eol=crlf
```

---

## 🔍 Pre-Push 50ms Security Sweep

Before executing `git push`, run `/repo-architect audit` or `audit_repo.ps1`:
1. Scans all staged and unstaged files for `C:\Users\` or user profile paths.
2. Checks for uncommitted or accidentally tracked `.env` or `*.pem` / `*.key` files.
3. Checks for high-entropy tokens (GitHub tokens `ghp_`, OpenAI keys `sk-`, Google API keys `AIza`).
4. Verifies `.gitignore` and `.gitattributes` exist and are valid.
