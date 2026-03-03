---
# ccsandbox-y9n5
title: Add required --mcp-config flag to claude-containered
status: completed
type: task
priority: normal
created_at: 2026-02-19T23:01:42Z
updated_at: 2026-02-19T23:02:57Z
---

Replace the hardcoded MCP config path (.claude/cc-sandbox-host.mcp.json) with a required --mcp-config <path> flag. The flag accepts a JSON file in the current format. For --init-mcp, use the --mcp-config path if given, else fall back to the old default.

## Summary of Changes

- Replaced hardcoded `.claude/cc-sandbox-host.mcp.json` with a required `--mcp-config <path>` flag
- The flag is validated early: missing flag shows an error + usage; missing file shows an error with hint to use `--init-mcp`
- `--init-mcp` now writes to the `--mcp-config` path (deferred parsing so both flags can appear in any order)
- Updated help text, examples, and status output
- Fixed edge case: relative vs absolute paths when combined with `--workdir`
- Updated CLAUDE.md to reflect the new interface
