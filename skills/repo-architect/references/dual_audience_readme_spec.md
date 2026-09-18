# 📄 The Dual-Audience README Specification

A world-class GitHub repository must cater to two fundamentally opposing audiences without alienating either:
1. **The Non-Technical User / Pragmatist**: Needs to know *what it does* in 5 seconds and *how to run it* in 30 seconds without reading code or dealing with complex build tools.
2. **The Peer Developer / Contributor**: Demands architectural transparency, idiomatic directory structure, reproducible build steps, and API contracts.

To satisfy both, `/repo-architect` enforces the **Progressive Disclosure Anatomy**.

---

## 🏛️ The Progressive Disclosure Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│ 1. THE 5-SECOND HOOK (For Everyone)                         │
│    Hero Title • Status Badges • 1-Line Value Proposition    │
│    Native ASCII Architecture / Data Flow Card               │
├─────────────────────────────────────────────────────────────┤
│ 2. THE 30-SECOND QUICKSTART (Non-Tech & Pragmatists)        │
│    Option A: Standalone Binary (Zero dependencies)          │
│    Option B: 1-Line Command (curl / pwsh / winget)          │
├─────────────────────────────────────────────────────────────┤
│ 3. THE MULTI-PATHWAY USAGE GUIDE                            │
│    CLI flags, configuration matrix, practical examples      │
├─────────────────────────────────────────────────────────────┤
│ 4. THE DEVELOPER & ARCHITECTURAL ENGINE (Deep Nerds)        │
│    System Internals • Local Build Loop • docs/architecture  │
├─────────────────────────────────────────────────────────────┤
│ 5. GOVERNANCE & SECURITY APPENDIX                           │
│    License • Security Policy • Contributing Guidelines      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📐 Section-by-Section Blueprint

### 1. 🎯 Hero & The 5-Second Hook
- **Repository Title**: Clean icon + name.
- **Badges**: CI Build status, License, Release version, Platform compatibility (Windows/Linux/macOS). Keep to 3–5 high-signal badges.
- **1-Line Elevator Pitch**: What problem does this solve in plain English? Avoid internal jargon.
- **Visual Flowcard**: A clean native ASCII or Unicode box card showing the flow of data or interaction. Never use wide horizontal trees that cause terminal line-wrapping.

```markdown
# ⚡ ToolName

> **Blazing-fast, zero-daemon thought capture HUD for Windows 11.**

[![CI](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg)](...)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078D4.svg)](...)

```text
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│  Ctrl+Alt+S    │ ──►  │ Native Win32   │ ──►  │ Append to      │
│  Global Hotkey │      │ Sub-10ms HUD   │      │ Daily Markdown │
└────────────────┘      └────────────────┘      └────────────────┘
```
```

---

### 2. ⚡ The 30-Second Quickstart (Zero-Friction Installation)
Always provide **Multi-Pathway Options** so the user chooses their preferred comfort level:

#### Option A: Standalone Binary (Non-Tech / Zero Dev Tools)
Direct link to GitHub Releases pre-compiled binary (`.exe` or portable binary). No compiler, no Python, no Node required.
```markdown
### 🚀 Quickstart

#### Option A: Standalone Binary (Fastest)
1. Download `ToolName.exe` from [Latest Releases](https://github.com/user/repo/releases/latest).
2. Move it to `~/.local/bin/` (or any folder in your `%PATH%`).
3. Run:
   ```cmd
   ToolName
   ```
```

#### Option B: 1-Line Installer (Pragmatist)
A single shell command that downloads and installs the tool:
```markdown
#### Option B: 1-Line PowerShell
```powershell
irm https://github.com/user/repo/raw/main/scripts/install.ps1 | iex
```
```

#### Option C: Package Manager
If distributed via standard package managers (`cargo install`, `npm install -g`, `winget`):
```markdown
#### Option C: Package Manager
```bash
winget install user.ToolName
```
```

---

### 3. 🛠️ Practical Usage & Everyday Workflows
Show realistic commands and sample outputs:
```markdown
## 🎮 Usage

### Basic Execution
```cmd
ToolName capture "Remember to review database indexes"
```

### Options & Flags
| Flag | Description | Default |
| :--- | :--- | :--- |
| `-t, --target` | Destination file or stream path | `~/.gemini/Spark.md` |
| `-v, --verbose` | Enable debug telemetry | `false` |
```

---

### 4. 🧠 Developer Engine & Architectural Specs (For Contributors)
Keep the root README clean by summarizing the build commands, and linking deep architectural documentation into `docs/`:

```markdown
## 🛠️ Development & Building from Source

### Prerequisites
- .NET 9 SDK (or Rust 1.80+ / Python 3.11+)
- PowerShell 7+

### Local Build Loop
```powershell
git clone https://github.com/user/repo.git
cd repo
dotnet build -c Release
```

For deep architectural design, component interactions, and state machine specifications, see [Architecture Guide](docs/architecture.md).
```

---

### 5. 🛡️ Security, Governance & License
Conclude with community and security anchors:
```markdown
## 🛡️ Security & Contributing
- **Security Disclosures**: Please see our [Security Policy](SECURITY.md) to report vulnerabilities privately.
- **Contributing**: Check [CONTRIBUTING.md](docs/contributing.md) for code conventions and pull request guidelines.
- **License**: Distributed under the [MIT License](LICENSE).
```
