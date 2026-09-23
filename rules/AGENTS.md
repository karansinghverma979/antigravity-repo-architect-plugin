# 🏛️ Repo Architect: Core Invariants

1. **Runtime State Decoupling**: Runtime databases (`*.sqlite`, `*.db`) and session logs must never be committed to git. Isolate to `%LOCALAPPDATA%/<app>/` or git-ignored directories. Trap `.env` in `.gitignore`.
2. **Solo Developer CI/CD**:
   - Use official major tags (`actions/checkout@v4`, `actions/setup-python@v5`, `actions/setup-dotnet@v4`).
   - Top-level `permissions: contents: read`.
   - Never enforce 40-character SHA pinning, CodeQL, or Dependabot on solo projects. Never fail builds over cosmetic linter diffs.
3. **CRLF/LF Firewall**: Repos must include `.gitattributes` (`*.sh text eol=lf`).
4. **Dual-Audience Documentation**: Root `README.md` features the 5-second visual hook and 30-second quickstart. Deep internal implementation belongs in `docs/architecture.md`.
