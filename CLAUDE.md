# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides two approaches for running Claude Code in a sandboxed environment with MCP server integration:

1. **OrbStack** (`claude-containered/`) — Docker-based sandbox via OrbStack
2. **sandbox-exec** (`claude-sandboxed/`) — Native macOS Seatbelt sandbox

Both share the same MCP configuration format and use supergateway to bridge stdio-based MCP servers to HTTP/SSE.

## Architecture

```
Host machine:
├── supergateway processes (one per MCP server, outside sandbox)
│   └── bridges stdio MCP servers to HTTP/SSE on localhost ports
│
└── Sandboxed Claude:
    ├── OrbStack: Docker container with mounted workspace
    │   └── connects to MCP via http://host.internal:<port>/sse
    │
    └── sandbox-exec: Native process with Seatbelt restrictions
        └── connects to MCP via http://127.0.0.1:<port>/sse
```

**Key insight**: MCP servers run *outside* the sandbox, allowing tools like xcsift-mcp to invoke xcodebuild/SPM without nested sandbox issues.

## Key Files

| File | Purpose |
|------|---------|
| `claude-containered/claude-containered` | OrbStack launcher (fish shell) |
| `claude-containered/Dockerfile` | Container image definition |
| `claude-sandboxed/claude-sandboxed` | sandbox-exec launcher (fish shell) |
| `claude-sandboxed/cc-sandbox.sb` | Seatbelt profile defining allowed writes |
| `mise.toml` | Task runner configuration |

## MCP Config Format

Both launchers use `.claude/cc-sandbox-host.mcp.json`:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["--flag"],
      "port": 8001,
      "env": {"VAR": "value"}
    }
  }
}
```

The launchers generate `.mcp.json` at runtime with SSE URLs for Claude to consume.

## Testing Changes

No automated tests. Manual testing required:

```fish
# Test OrbStack version
./claude-containered/claude-containered

# Test sandbox-exec version (from a normal terminal, not inside Claude Code)
./claude-sandboxed/claude-sandboxed
```

**Note**: The sandbox-exec version cannot be tested from within Claude Code (nested sandbox restriction).

## Rebuild Docker Image

```fish
mise run build-container
```

The image is built with the current host username via `--build-arg USERNAME=$(whoami)`. The container user and home directory paths match your macOS username.
