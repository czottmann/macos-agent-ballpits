---
# ccsandbox-4wkf
title: OrbStack Claude Code Sandbox
status: completed
type: epic
priority: normal
created_at: 2026-01-27T18:22:53Z
updated_at: 2026-01-27T18:43:10Z
---

Run Claude Code in a sandboxed Docker container via OrbStack with:
- R/W access to workspace directory
- R/O access to additional mounted directories
- MCP servers on host exposed via supergateway (SSE)
- Fast startup, clean teardown

## Design Summary

**Architecture:**
- Docker container (not full VM) for fast startup (~1-2s)
- OAuth inside container (OrbStack has full networking)
- Integrated supergateway lifecycle management
- Project-local MCP config that gets transformed for guest

**Files:**
- `Dockerfile` — Alpine + Claude Code + dev tools
- `cc-sandbox.fish` — Launcher script
- `.claude/cc-sandbox-host.mcp.json` — Per-project host MCP config
- `.mcp.json` — Generated guest MCP config (gitignore)

**Launcher behavior:**
- Saves/restores Docker context (orbstack)
- Starts supergateway processes, aborts if any fail
- Generates guest MCP config
- Auto-builds image if missing
- Runs container with r/w workspace + r/o mounts
- Cleans up everything on exit
