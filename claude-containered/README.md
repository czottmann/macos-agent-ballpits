# claude-containered

Run Claude Code in a sandboxed Docker container via OrbStack with controlled filesystem access and MCP server integration.

## Security Model

- **R/W access**: Current working directory (mounted at exact same path)
- **R/O access**: Additional directories via `--ro` flag (mounted at exact same paths)
- **Isolation**: Non-root user inside container, Docker's native mount restrictions
- **MCP access**: Host MCP servers exposed via SSE (supergateway)
- **Permissions**: Claude automatically runs with `--dangerously-skip-permissions` (the sandbox *is* the safety boundary)

## Prerequisites

- [OrbStack](https://orbstack.dev/) — provides Docker runtime and CLI
- `jq` — JSON processing
- `gum` — terminal spinners
- `supergateway` via npm — only if using MCP servers

## Quick Start

```fish
# First run: builds the image automatically
./claude-containered

# Run pre-installed pi-coding-agent instead of Claude Code
./claude-containered -- pi

# With read-only access to additional directories
./claude-containered --ro ~/Documents --ro ~/Reference

# Run a shell for manual exploration
./claude-containered -- bash
```

## Usage

```
claude-containered [OPTIONS] [-- COMMAND...]

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

The launcher mounts your host configuration (container paths use your host username):

- `~/.claude` → `/home/<username>/.claude` (project data, settings)
- `~/.claude-sandbox.json` → `/home/<username>/.claude.json` (sandbox-specific auth)
- `~/.pi` → `/home/<username>/.pi` (pi-coding-agent config, if present)
- `~/.kimi` → `/home/<username>/.kimi` (kimi-cli config, if present)

This means:
- You authenticate once and it persists across sessions
- Project-specific settings are shared with your host
- Each project has its own config (paths are preserved)

## Workspace Mounting

The workspace and read-only mounts use the same paths in host and container:

| Host path | Container path | Access |
|-----------|----------------|--------|
| `/Users/you/Code/my-app` | `/Users/you/Code/my-app` | r/w |
| `/Users/you/Documents` (via `--ro`) | `/Users/you/Documents` | r/o |

This ensures Claude Code's project-specific configs match exactly between host and container.

## MCP Server Integration

The sandbox can connect to MCP servers running on your host via [supergateway](https://github.com/supercorp-ai/supergateway). By default, it configures [xcsift-mcp](https://github.com/johnnyclem/xcsift-mcp) for Xcode/Swift development (and [cupertino](https://github.com/mihaelamj/cupertino) if installed).

### Setup

1. Create MCP config for the current project/folder (auto-detects installed servers):
   ```fish
   ./claude-containered --init-mcp
   ```

2. This creates `.claude/cc-sandbox-host.mcp.json`:
   ```json
   {
     "mcpServers": {
       "xcsift-mcp": {
         "command": "xcsift-mcp",
         "args": [],
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
   ./claude-containered
   ```

### How It Works

1. Launcher reads `.claude/cc-sandbox-host.mcp.json`
2. Starts a supergateway instance for each MCP server (bridges stdio to SSE)
3. Generates `.mcp.json` with SSE URLs for the container (**NOTE: prompts before overwriting existing file**)
4. Claude Code inside container connects to MCP servers via `http://host.internal:<port>/sse`
5. On exit, supergateway processes are killed automatically

### Adding MCP Servers

Edit `<project-root>/.claude/cc-sandbox-host.mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": ["--some-flag"],
      "port": 8003,
      "env": {
        "MY_VAR": "value"
      }
    }
  }
}
```

Config fields:
- `command`: The executable to run
- `args`: Arguments (array)
- `port`: Port for supergateway to expose
- `env`: Environment variables (optional)

## Building the Image

The image is built automatically on first run with your host username baked in via `--build-arg USERNAME=$(whoami)`. To rebuild manually:

```fish
mise run build-container
```

## Files

| File | Purpose |
|------|---------|
| `claude-containered` | Launcher script |
| `Dockerfile` | Debian + Claude Code + pi + dev tools |

## Included Tools

The container includes:
- [Claude Code](https://claude.com/product/claude-code)
- [pi-coding-agent](https://shittycodingagent.ai/)
- bash, git, curl
- Node.js, npm, Go
- ripgrep, fd, sd, jq
- [beans](https://github.com/hmans/beans) (flat-file issue tracker for humans and robots)

## Known Limitations

- **Git credentials**: Git inside the container currently lacks authentication/credentials, preventing operations like push, pull, and clone from authenticated repos. See [ccsandbox-1y6z](/.beans/ccsandbox-1y6z--set-up-git-credentials-in-orbstack-vm.md).

## Docker Context

The launcher automatically switches to the `orbstack` Docker context and restores your previous context on exit.
