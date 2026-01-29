---
# ccsandbox-b38y
title: Document .mcp.json overwrite behavior in sandboxed README
status: completed
type: task
priority: normal
created_at: 2026-01-29T12:19:18Z
updated_at: 2026-01-29T12:51:34Z
---

`claude-containered/README.md` warns that `.mcp.json` is overwritten (line 114):
> Generates `.mcp.json` with SSE URLs for the container (**NOTE: this overwrites any existing file\!**)

`claude-sandboxed/README.md` doesn't mention this behavior at all, despite having identical logic.

**Fix:**
Add the same warning to the sandboxed README's MCP section.

**Affected files:**
- claude-sandboxed/README.md

## Summary of Changes

- Added step about `.mcp.json` generation to sandboxed README's "How It Works" section
- Updated both READMEs to reflect new prompting behavior (was: "overwrites any existing file", now: "prompts before overwriting")