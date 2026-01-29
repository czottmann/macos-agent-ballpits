---
# ccsandbox-ij3y
title: Prompt before overwriting existing .mcp.json
status: completed
type: bug
priority: normal
created_at: 2026-01-29T12:19:04Z
updated_at: 2026-01-29T12:50:50Z
---

Both launchers unconditionally overwrite any existing `.mcp.json` in the project directory when starting MCP servers. This silently destroys user data if they had a manually-configured MCP setup.

**Current behavior:**
- Launchers generate `.mcp.json` with SSE URLs for Claude
- Any pre-existing file is silently overwritten
- The `generated_mcp_config` flag only controls deletion on exit, not creation

**Fix:**
When an existing `.mcp.json` is detected, show a gum confirmation prompt:
```
Overwrite existing .mcp.json?
```
If user declines, exit early with a message explaining they need to remove or rename the file.

**Affected files:**
- claude-containered/claude-containered
- claude-sandboxed/claude-sandboxed

## Summary of Changes

Added `gum confirm` prompt in `start_mcp_servers` that checks for existing `.mcp.json` before proceeding. If user declines, exits with message to remove/rename the file.