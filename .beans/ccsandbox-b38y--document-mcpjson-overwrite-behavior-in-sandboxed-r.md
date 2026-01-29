---
# ccsandbox-b38y
title: Document .mcp.json overwrite behavior in sandboxed README
status: todo
type: task
created_at: 2026-01-29T12:19:18Z
updated_at: 2026-01-29T12:19:18Z
---

`claude-containered/README.md` warns that `.mcp.json` is overwritten (line 114):
> Generates `.mcp.json` with SSE URLs for the container (**NOTE: this overwrites any existing file\!**)

`claude-sandboxed/README.md` doesn't mention this behavior at all, despite having identical logic.

**Fix:**
Add the same warning to the sandboxed README's MCP section.

**Affected files:**
- claude-sandboxed/README.md