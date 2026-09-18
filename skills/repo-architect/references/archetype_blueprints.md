# 📦 Canonical Archetype Blueprints

Every software project belongs to an architectural archetype. `/repo-architect` uses these canonical layouts to organize repositories cleanly without unnecessary boilerplate.

---

## 🚀 Archetype 1: Standalone CLI Tool / Native Binary (.NET / Rust / Go)
*Examples: Sakshi modules (`Death`, `Apex`, `Spark`), command-line utilities.*

### Directory Layout
```text
repo-root/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                 # Build & test across Ubuntu/Windows
│   │   └── release.yml            # Multi-target compile & attach .exe to GitHub Releases
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   └── architecture.md            # Internal Win32/DirectX/OS hooks specs
├── scripts/
│   ├── build.ps1                  # Local reproducible release build
│   └── install.ps1                # User 1-line installation script
├── src/                           # Pure source code engine
├── tests/                         # Unit and integration test suite
├── .gitattributes                 # LF for scripts, auto text
├── .gitignore                     # Ignores bin/, obj/, target/, .vs/
├── CHANGELOG.md                   # Semantic versioning release log
├── LICENSE                        # MIT / Apache 2.0
├── README.md                      # Dual-audience with binary download link
└── SECURITY.md                    # OpenSSF vulnerability disclosure
```

### GitHub Actions Release Pipeline
Automatically builds a standalone native `.exe` on every tagged release (`v*.*.*`) and attaches it to GitHub Releases so users do not need a compiler.

---

## 🔌 Archetype 2: Antigravity Customization Plugin / MCP Server
*Examples: `win-janitor-plugin`, `google-workspace-mcp`, `play-console-mcp`.*

### Directory Layout
```text
repo-root/
├── .github/
│   └── workflows/
│       └── ci.yml                 # Lint, JSON schema validation, test suite
├── agents/                        # Autonomous Agent definitions (optional)
│   └── agent_name.md
├── docs/
│   └── tool_specifications.md     # Protocol / tool schema documentation
├── skills/                        # Skill runbooks & progressive instructions
│   └── skill-name/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── src/                           # TypeScript/Python MCP server code (if MCP server)
├── .env.example                   # Dummy keys for required API credentials
├── .gitattributes
├── .gitignore                     # Ignores .env, keys/, auth tokens
├── LICENSE
├── plugin.json                    # Antigravity plugin manifest
├── README.md                      # Setup guide for both Antigravity & Claude Desktop
└── SECURITY.md
```

---

## 🐍 Archetype 3: Modern Python Package / CLI Tool
*Uses standard `src/` layout (PEP 518/621), `pyproject.toml`, and strict type hinting.*

### Directory Layout
```text
repo-root/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Ruff lint, mypy typecheck, pytest matrix
│       └── publish.yml            # Trusted publishing to PyPI on release
├── docs/
│   └── api_reference.md
├── src/
│   └── package_name/              # Clean namespace import
│       ├── __init__.py
│       ├── py.typed               # PEP 561 marker
│       └── core.py
├── tests/
│   └── test_core.py
├── .env.example
├── .gitattributes
├── .gitignore                     # Ignores __pycache__/, .venv/, *.egg-info/, .pytest_cache/
├── pyproject.toml                 # Modern single-source build metadata (hatchling/flit/poetry)
├── LICENSE
├── README.md
└── SECURITY.md
```

---

## 🌐 Archetype 4: Modern Web / Fullstack Service
*Examples: Next.js, Vite frontend + FastAPI backend.*

### Directory Layout
```text
repo-root/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Lint, build, frontend/backend tests
│       └── docker.yml             # Docker build and container scan
├── backend/ (or src/api/)         # API service
├── frontend/ (or src/web/)        # Client web application
├── docs/
│   └── deployment.md
├── scripts/
│   └── dev.ps1                    # 1-command local development runner
├── .dockerignore
├── .env.example                   # Full parameter blueprint
├── .gitattributes
├── .gitignore                     # Ignores node_modules/, dist/, build/, .next/, .env
├── docker-compose.yml             # Optional container orchestration
├── LICENSE
├── README.md
└── SECURITY.md
```
