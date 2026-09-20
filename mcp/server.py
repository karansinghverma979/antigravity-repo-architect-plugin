#!/usr/bin/env python3
"""
Repo Architect MCP Server
Autonomous GitHub Repository Architect, OpenSSF Security Hardener & Governance Gateway.
Pure Python standard library stdio JSON-RPC implementation.
"""

import sys
import json
import os
import subprocess
import traceback
from pathlib import Path

# Force UTF-8 on Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

PLUGIN_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = PLUGIN_ROOT / "skills" / "repo-architect"
SCRIPTS_DIR = SKILLS_DIR / "scripts"
TEMPLATES_DIR = SKILLS_DIR / "templates"
AUDIT_SCRIPT = SCRIPTS_DIR / "audit_repo.ps1"
SCAFFOLD_SCRIPT = SCRIPTS_DIR / "scaffold_repo.ps1"

TOOLS = [
    {
        "name": "repo_architect_audit",
        "description": "Execute high-speed security, path portability, and OpenSSF audit on a target repository.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Path to the repository to audit. Defaults to current directory."
                },
                "strict": {
                    "type": "boolean",
                    "description": "Fail on warnings as well as critical errors.",
                    "default": False
                }
            }
        }
    },
    {
        "name": "repo_architect_scaffold",
        "description": "Scaffold canonical OpenSSF assets, workflows, issue templates, and governance files into a target directory.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Target repository path to scaffold. Defaults to current directory."
                },
                "archetype": {
                    "type": "string",
                    "description": "Project archetype: 'cli', 'mcp', 'python', 'web', or 'standard'.",
                    "enum": ["cli", "mcp", "python", "web", "standard"],
                    "default": "standard"
                }
            }
        }
    },
    {
        "name": "repo_architect_get_ruleset",
        "description": "Retrieve baseline declarative GitHub Ruleset JSON configuration (branch protection or push filters).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "type": {
                    "type": "string",
                    "description": "Ruleset type: 'branch' (branch protection) or 'push' (push quarantine filter).",
                    "enum": ["branch", "push"],
                    "default": "push"
                }
            },
            "required": ["type"]
        }
    }
]

def handle_audit(args: dict) -> dict:
    target_path = args.get("path") or os.getcwd()
    strict = bool(args.get("strict", False))

    cmd = ["pwsh", "-NoProfile", "-File", str(AUDIT_SCRIPT), "-Path", target_path]
    if strict:
        cmd.append("-Strict")

    proc = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    return {
        "exit_code": proc.returncode,
        "success": proc.returncode == 0,
        "target": target_path,
        "strict": strict,
        "output": proc.stdout.strip(),
        "errors": proc.stderr.strip() if proc.stderr else None
    }

def handle_scaffold(args: dict) -> dict:
    target_path = args.get("path") or os.getcwd()
    archetype = args.get("archetype", "standard")

    cmd = ["pwsh", "-NoProfile", "-File", str(SCAFFOLD_SCRIPT), "-Path", target_path, "-Archetype", archetype]
    proc = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    return {
        "exit_code": proc.returncode,
        "success": proc.returncode == 0,
        "target": target_path,
        "archetype": archetype,
        "output": proc.stdout.strip(),
        "errors": proc.stderr.strip() if proc.stderr else None
    }

def handle_get_ruleset(args: dict) -> dict:
    ruleset_type = args.get("type", "push")
    filename = "ruleset_branch_baseline.json" if ruleset_type == "branch" else "ruleset_push_baseline.json"
    filepath = TEMPLATES_DIR / filename
    if not filepath.exists():
        raise FileNotFoundError(f"Ruleset template not found: {filename}")

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {
        "ruleset_type": ruleset_type,
        "filename": filename,
        "schema": data
    }

def send_json(data: dict):
    payload = json.dumps(data, ensure_ascii=False)
    sys.stdout.write(payload + "\n")
    sys.stdout.flush()

def handle_jsonrpc(line: str):
    line = line.strip()
    if not line:
        return
    try:
        req = json.loads(line)
    except Exception as err:
        send_json({
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32700, "message": f"Parse error: {str(err)}"}
        })
        return

    req_id = req.get("id")
    method = req.get("method")
    params = req.get("params", {})

    if method == "initialize":
        send_json({
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {}
                },
                "serverInfo": {
                    "name": "repo-architect",
                    "version": "1.1.0"
                }
            }
        })
    elif method == "notifications/initialized":
        pass
    elif method == "tools/list":
        send_json({
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "tools": TOOLS
            }
        })
    elif method == "tools/call":
        tool_name = params.get("name")
        tool_args = params.get("arguments", {})

        handlers = {
            "repo_architect_audit": handle_audit,
            "repo_architect_scaffold": handle_scaffold,
            "repo_architect_get_ruleset": handle_get_ruleset
        }

        handler = handlers.get(tool_name)
        if not handler:
            send_json({
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Tool '{tool_name}' not found."}
            })
            return

        try:
            res_data = handler(tool_args)
            send_json({
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [
                        {
                            "type": "text",
                            "text": json.dumps(res_data, indent=2)
                        }
                    ],
                    "isError": False
                }
            })
        except Exception as err:
            send_json({
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [
                        {
                            "type": "text",
                            "text": f"Error in '{tool_name}': {str(err)}\n{traceback.format_exc()}"
                        }
                    ],
                    "isError": True
                }
            })
    elif method == "ping":
        send_json({"jsonrpc": "2.0", "id": req_id, "result": {}})
    else:
        if req_id is not None:
            send_json({
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Method '{method}' not implemented."}
            })

def main():
    for line in sys.stdin:
        handle_jsonrpc(line)

if __name__ == "__main__":
    main()
