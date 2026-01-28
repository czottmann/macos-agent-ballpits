# Claude Code Sandboxed

Run Claude Code in a sandboxed environment with MCP server integration. Two approaches available:

| Approach | Isolation | Startup | Best For |
|----------|-----------|---------|----------|
| **[claude-containered](claude-containered/)** | Docker via OrbStack | ~1-2s | Stronger isolation, containerized tools |
| **[claude-sandboxed](claude-sandboxed/)** | macOS sandbox-exec | Instant | Lightweight, native performance |

## How It Works

Both approaches share the same architecture:

1. **MCP servers run on the host** (outside the sandbox) via [supergateway](https://github.com/supercorp-ai/supergateway)
2. **Claude runs inside the sandbox** with restricted write access
3. **Claude connects to MCP servers** via HTTP/SSE

This design lets tools like [xcsift-mcp](https://github.com/johnnyclem/xcsift-mcp) invoke `xcodebuild` freely—no nested sandbox issues.

## Quick Start

```fish
# OrbStack version (builds image on first run)
./claude-containered/claude-containered

# Native sandbox version (macOS only)
./claude-sandboxed/claude-sandboxed
```

## MCP Configuration

Both use the same config format. Create `.claude/cc-sandbox-host.mcp.json` in your project:

```fish
./claude-containered/claude-containered --init-mcp
# or
./claude-sandboxed/claude-sandboxed --init-mcp
```

See the individual READMEs for details.

## Requirements

**claude-containered:**
- [OrbStack](https://orbstack.dev/)
- `jq`, `gum`

**claude-sandboxed:**
- macOS
- `jq`, `gum`, `nc`

Both require `npx` and `supergateway` if using MCP servers.
