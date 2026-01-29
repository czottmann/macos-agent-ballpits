---
# ccsandbox-0083
title: Auto-assign supergateway ports instead of requiring manual configuration
status: todo
type: feature
priority: normal
created_at: 2026-01-28T21:00:48Z
updated_at: 2026-01-29T12:18:57Z
parent: ccsandbox-co2x
---

Currently, the MCP host config (cc-sandbox-host.mcp.json) requires users to manually specify a port for each server. This is error-prone (conflicting ports) and unnecessary friction.

**Proposed behavior:**
- Make port optional in the config schema
- When starting MCP servers, auto-assign ports starting from 8001
- Check port availability before assignment (using nc -z)
- Track assigned ports during startup to avoid conflicts between servers
- Still allow explicit port override if someone needs a specific port

**Affected files:**
- claude-sandboxed/claude-sandboxed
- claude-containered/claude-containered
- (both share nearly identical start_mcp_servers logic)