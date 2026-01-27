# Claude Code Sandboxed Environment (OrbStack)

Run Claude Code in a sandboxed Docker container via OrbStack with controlled filesystem access and MCP server integration.

## Security Model

- **R/W access**: Current working directory (mounted at exact same path)
- **R/O access**: Additional directories via `--ro` flag
- **Isolation**: Non-root user inside container, Docker's native mount restrictions
- **MCP access**: Host MCP servers exposed via SSE (supergateway)
- **Permissions**: Claude runs with `--dangerously-skip-permissions` (the sandbox *is* the safety boundary)

## Prerequisites

- [OrbStack](https://orbstack.dev/) running
- `jq` (for JSON processing)
- `gum` (for spinners)
- `supergateway` via npm (only if using MCP servers)

## Quick Start

```fish
# First run: builds the image automatically
./cc-sandbox.fish

# With read-only access to additional directories
./cc-sandbox.fish --ro ~/Documents --ro ~/Reference

# Run a different command instead of claude
./cc-sandbox.fish -- bash
```

## Usage

```
cc-sandbox [OPTIONS] [-- COMMAND...]

OPTIONS:
    --ro PATH       Add a read-only mount (can be repeated)
    --keep          Keep the container after exit
    --init-mcp      Create default MCP config file
    --help          Show help

COMMAND:
    If provided, runs this instead of claude (e.g., "bash" for a shell)
    Default: claude --dangerously-skip-permissions
```

## Persistent Config

The launcher mounts your host Claude configuration:

- `~/.claude` → `/home/claude/.claude` (auth, settings, project data)

This means:
- You authenticate once and it persists across sessions
- Project-specific settings are shared with your host
- Each project has its own config (paths are preserved)

## Workspace Mounting

The workspace is mounted at the exact same path as on the host:

| Host path | Container path |
|-----------|----------------|
| `/Users/you/Code/my-app` | `/Users/you/Code/my-app` |

This ensures Claude Code's project-specific configs match exactly between host and container.

## MCP Server Integration

The sandbox can connect to MCP servers running on your host via [supergateway](https://github.com/supercorp-ai/supergateway).

### Setup

1. Create MCP config (auto-detects installed servers):
   ```fish
   ./cc-sandbox.fish --init-mcp
   ```

2. This creates `.claude/cc-sandbox-host.mcp.json`:
   ```json
   {
     "mcpServers": {
       "xcodebuildmcp": {
         "command": "npx",
         "args": ["-y", "xcodebuildmcp"],
         "port": 8001
       },
       "cupertino": {
         "command": "/opt/homebrew/bin/cupertino",
         "args": ["serve"],
         "port": 8002
       }
     }
   }
   ```

3. Run the sandbox — MCP servers start automatically:
   ```fish
   ./cc-sandbox.fish
   ```

### How It Works

1. Launcher reads `.claude/cc-sandbox-host.mcp.json`
2. Starts a supergateway instance for each MCP server (bridges stdio to SSE)
3. Generates `.mcp.json` with SSE URLs for the container
4. Claude Code inside container connects to MCP servers via `http://host.internal:<port>/sse`
5. On exit, supergateway processes are killed automatically

### Adding MCP Servers

Edit `.claude/cc-sandbox-host.mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": ["--some-flag"],
      "port": 8003
    }
  }
}
```

## Building the Image

The image is built automatically on first run. To rebuild manually:

```fish
docker context use orbstack
docker build -t cc-sandbox .
```

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Alpine + Claude Code + dev tools |
| `cc-sandbox.fish` | Launcher script |
| `.claude/cc-sandbox-host.mcp.json` | Host MCP server config (per-project) |
| `.mcp.json` | Generated guest config (gitignore this) |

## Included Tools

The container includes:
- bash, git, curl
- Node.js, npm
- ripgrep, fd, sd
- Claude Code

## Docker Context

The launcher automatically:
1. Saves your current Docker context
2. Switches to `orbstack` context
3. Restores the original context on exit

This allows you to use OrbStack for sandboxing while keeping Docker Desktop as your default.
