# Ballpits: Securing Claude Code and Agents on macOS

This is my personal take on sandboxing Claude Code and similar AI agents. I'm scratching my own itch here—restricting file write access so agents can only modify the current project and a few config directories.

This is an opinionated setup! I love fish shell, I dig [gum](https://github.com/charmbracelet/gum). The upside is that the scripts are documented and rather easy to read and translate. It's also a show-and-tell, not a full-fledged project, mind.

No guarantees, no claims of bulletproof security. I might be wrong about some of this. Use at your own risk.

Feel free to mix and match.

## Two Approaches

I've settled on two different approaches, and work with them 

| Approach | Isolation | Startup | Best For |
|----------|-----------|---------|----------|
| **[claude-containered](claude-containered/)** | Docker via OrbStack | ~1-2s | Stronger isolation, containerized tools, bit more involved to get git credentials going etc. |
| **[claude-sandboxed](claude-sandboxed/)** | macOS sandbox-exec | Instant | Lightweight, native performance |

## How It Works

Both approaches share the same idea:

1. **MCP servers run on the host** (outside the sandbox) via [supergateway](https://github.com/supercorp-ai/supergateway)
2. **Claude runs inside the sandbox** with restricted write access
3. **Claude connects to MCP servers** via HTTP/SSE

This lets tools like [xcsift-mcp](https://github.com/johnnyclem/xcsift-mcp) invoke `xcodebuild` freely—no nested sandbox issues. (Side note: Big Swift dev shoutout to [xcsift](https://github.com/ldomaradzki/xcsift)!)

## Quick Start

```fish
# OrbStack version (builds image on first run)
./claude-containered/claude-containered

# Native `sandbox-exec`-based version (macOS only)
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
