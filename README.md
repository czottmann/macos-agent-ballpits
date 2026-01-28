# Ballpits: Securing Claude Code and Agents on macOS

**Just a show-and-tell, basically, not a full-fledged project.**

This is my personal take on sandboxing Claude Code and similar AI agents.

## Problem statement

I want…

1. to run LLM agents inside clearly defined boundaries on macOS to restrict file write access.
1. a sandbox to put them in, one they can't break.
1. read-write access to the current folder, and configurable optional read-only access to others.
1. the agents to be able to build Xcode projects (because that's what I do), which is usually not as easy, lest you set up a full macOS VM with a full Xcode setup inside, and … nope.

Also, I want that thing to boot up in less than 5s.

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

## Disclaimer

I'm scratching my own itch here—restricting file write access so agents can only modify the current project and a few config directories. None of this is rocket science, but I was learning a few things, and sharing is caring.

This is an opinionated setup! I love fish shell, I dig [gum](https://github.com/charmbracelet/gum). The upside is that the scripts are documented and rather easy to read and translate.

No guarantees, no claims of bulletproof security. I might be wrong about some of this. Use at your own risk. Feel free to mix and match!

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
