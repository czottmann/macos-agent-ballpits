---
# ccsandbox-dvlw
title: Create launcher script
status: completed
type: task
priority: normal
created_at: 2026-01-27T18:23:12Z
updated_at: 2026-01-27T19:10:12Z
parent: orbstack-cc-sandbox-4wkf
---

Create fish shell launcher script that manages the full sandbox lifecycle.

**Files:**
- Create: `cc-sandbox.fish`

**Features:**

1. **Argument parsing:**
   - `--ro PATH` — Add read-only mount (repeatable)
   - `--keep` — Don't remove container on exit
   - `--init-mcp` — Create default MCP config (auto-detects installed servers)
   - `--help` — Show usage
   - `--` — Pass remaining args to claude

2. **Docker context management:**
   - Save current context: `docker context show`
   - Switch to orbstack: `docker context use orbstack`
   - Restore on cleanup

3. **MCP handling (if `.claude/cc-sandbox-host.mcp.json` exists):**
   - Read host config
   - Start supergateway for each MCP server (using `nohup` + `disown` for proper detachment)
   - Generate `.mcp.json` with SSE URLs (`http://host.internal:<port>/sse`)
   - Wait up to 30s for each server port (using `nc -z 127.0.0.1`)
   - Log supergateway output to temp files for debugging

4. **`--init-mcp` command:**
   - Creates config with xcodebuildmcp (always)
   - Auto-detects cupertino if installed via Homebrew

5. **Image management:**
   - Check if `cc-sandbox` image exists
   - Auto-build if missing

6. **Container execution:**
   - TTY detection (only use -it when TTY available)
   - Mount workspace: `-v $(pwd):/workspace`
   - Mount R/O dirs: `-v path:/roN:ro`
   - Pass claude args

7. **Cleanup (via trap):**
   - Kill all supergateway processes (`pkill -f`)
   - Restore docker context
   - Remove generated `.mcp.json`

**Verification:**
- [x] `cc-sandbox --help` shows usage
- [x] `cc-sandbox --init-mcp` creates config file with detected servers
- [x] Docker context is restored after exit
- [x] MCP servers start and are accessible
- [x] Supergateways are killed on exit

## Summary of Changes
Created cc-sandbox.fish launcher script with full lifecycle management. Key fixes during testing:
- Used `nohup` + `disown` to properly detach supergateway processes
- Used `nc -z 127.0.0.1` instead of `lsof` for reliable port detection on macOS
- Added debug logging to temp files for troubleshooting

## Insights
- Fish's background process handling with `&` doesn't fully detach processes; `nohup` + `disown` is needed
- `lsof -sTCP:LISTEN` is unreliable on macOS; `nc -z` is more robust for port checking
- Using `127.0.0.1` instead of `localhost` avoids IPv6/DNS resolution issues
