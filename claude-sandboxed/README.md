# claude-sandboxed

A lightweight alternative to the OrbStack-based sandbox that uses macOS's native `sandbox-exec` (Seatbelt) to restrict Claude Code's file write access.

## How It Works

1. MCP servers start on the host (outside sandbox) via supergateway
2. Claude runs inside `sandbox-exec` with restricted write permissions
3. Claude connects to MCP servers via HTTP/SSE on localhost
4. On exit, MCP servers are cleaned up

Since MCP servers run **outside** the sandbox, tools like `xcsift-mcp` can invoke `xcodebuild` and SPM freely—no nested sandbox issues.

**Note:** Using supergateway is not strictly necessary but since I usually deal with a mix of stdio and HTTP MCP servers, I prefer it for having a clean and easy way to configure MCPs from project to project.

## Usage

```fish
# From your project directory
/path/to/claude-sandboxed

# Or symlink to PATH
ln -s /path/to/claude-sandboxed ~/.local/bin/claude-sandboxed
claude-sandboxed
```

## MCP Configuration

Same as the OrbStack version—create `.claude/cc-sandbox-host.mcp.json`:

```fish
claude-sandboxed --init-mcp
```

This creates a config with [`xcsift-mcp`](https://github.com/johnnyclem/xcsift-mcp) (and [`cupertino`](https://github.com/mihaelamj/cupertino) if installed). Edit as needed.

### Config Format

```json
{
  "mcpServers": {
    "xcsift-mcp": {
      "command": "xcsift-mcp",
      "args": [],
      "port": 8001
    }
  }
}
```

- `command`: The executable to run
- `args`: Arguments (array)
- `port`: Port for supergateway to expose
- `env`: Environment variables (optional)

## What's Allowed

The sandbox profile (`cc-sandbox.sb`) allows writes to:

- Working directory (full access)
- `~/.claude`, `~/.claude.json` (Claude Code config/state)
- `/tmp`, `/var/folders` (temp files)
- `~/.npm`, `~/.cache`, `~/Library/Caches`

Everything else is read-only.

## vs OrbStack Version

| Aspect | OrbStack | sandbox-exec |
|--------|----------|--------------|
| Isolation | Docker container | Seatbelt process sandbox |
| Startup | ~1-2s | Instant |
| Dependencies | OrbStack + Docker | None (built into macOS) |
| File access | Explicit mounts | Profile-based restrictions |
| Network | Container networking | Native |

Use **sandbox-exec** for lighter weight, faster startup.
Use **OrbStack** for stronger isolation or when you need containerized tools.

## Requirements

- macOS (sandbox-exec is macOS-only)
- `claude` CLI installed
- `jq`, `gum`, `nc` (netcat)
- `npx` and `supergateway` (if using MCP servers)
