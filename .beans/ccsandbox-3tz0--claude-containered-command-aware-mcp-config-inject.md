---
# ccsandbox-3tz0
title: 'claude-containered: command-aware MCP config injection + streamableHttp transport'
status: completed
type: task
priority: normal
created_at: 2026-06-02T11:31:45Z
updated_at: 2026-06-02T11:56:44Z
---

## Context

`claude-containered` unconditionally appends `--mcp-config <json>` to whatever command runs (line 489-492). claude and pi understand that flag, but codex does not — it errors on the unknown flag and reads MCP servers from TOML (`[mcp_servers.*]`) instead. So `claude-containered -- codex` breaks.

Verified by live test (2026-06-02): supergateway `--outputTransport streamableHttp` (endpoint `/mcp`) connects cleanly for claude (live health-check ✓), pi (source: pi-mcp-adapter probes StreamableHTTPClientTransport first), and codex (native `--url` support; `tools/call` returned `Echo: CODEXPING42` end-to-end). SSE is deprecated for both claude and pi, so moving the gateway to streamableHttp is a strict upgrade.

codex's read-only-sandbox cancellation of MCP tool calls is OUT OF SCOPE — Carlo handles the sandbox side separately.

## Scope boundaries

- IN: switch supergateway to `--outputTransport streamableHttp`; guest JSON config uses `type:"http"` + `/mcp` URL; detect the target agent and inject MCP config the agent's native way (claude/pi: `--mcp-config <json>`; codex: per-server `-c 'mcp_servers.NAME.url="http://host.internal:PORT/mcp"'`).
- OUT: codex sandbox-mode flags; per-agent strategy abstraction (only 3 agents — keep it inline); any change to pi's existing delivery beyond the URL/type inside the generated JSON.

## Success criteria

- [x] supergateway is launched with `--outputTransport streamableHttp` for every server
- [x] generated guest JSON uses `{type:"http", url:"http://host.internal:PORT/mcp"}`
- [x] target agent is derived from the command (default `claude` when no `--` command given; otherwise first token of CLAUDE_ARGS)
- [x] claude and pi still receive `--mcp-config <guest_json>`
- [x] codex receives `-c 'mcp_servers.NAME.url="..."'` per server and NO `--mcp-config`
- [x] Agent: re-run the live streamableHttp test (supergateway + everything server) and confirm claude `mcp list` shows ✓ Connected and codex `tools/call` returns the echo result via the gateway log
- [x] Human: run `claude-containered -- codex` against a real MCP config in the container and confirm codex sees the tools

## Summary of Changes

`claude-containered/claude-containered`:

1. supergateway is now launched with `--outputTransport streamableHttp` (endpoint `/mcp`) instead of the default SSE.
2. The generated guest JSON uses `{type:"http", url:"http://host.internal:PORT/mcp"}` (was `type:"sse"`, `/sse`). SSE is deprecated for both claude and pi, so this is a strict upgrade.
3. New global `codex_mcp_overrides`, populated in the `start_mcp_servers` generation loop with one `-c 'mcp_servers.NAME.url="…/mcp"'` pair per server.
4. The command/injection block now derives the target `agent` from the first token of CLAUDE_ARGS (default `claude`) and injects MCP config the agent's native way: claude/pi get `--mcp-config <json>` (unchanged); codex gets the `-c` overrides and NO `--mcp-config`.
5. Help-text transport wording updated to "stdio → streamable HTTP".

Verified live (host, supergateway + @modelcontextprotocol/server-everything):
- claude: `mcp list` shows `✓ Connected` against the script-format guest JSON.
- codex: the script-format `-c` override (in trailing position, as the script appends it) drives a real `tools/call` that reaches the gateway and returns `Echo: …`.
- Agent dispatch unit-checked: claude/pi → `--mcp-config`, codex → `-c` overrides, default(no cmd) → claude + `--mcp-config`.

## Insights

- codex's `-c` value is parsed as TOML, so the URL must be a quoted TOML string (`url="…"`); the escaped quotes are required, confirmed by live tool call.
- codex `exec` defaults to `sandbox: read-only`, which **cancels MCP tool calls** (`user cancelled MCP tool call`) regardless of transport — tool *listing* works, the *call* dies client-side. Fixed by a non-read-only sandbox mode. OUT OF SCOPE here (Carlo handles the sandbox side).
- Known limitation (not handled, per scope): a server name containing a `.` would produce a wrong TOML dotted key path (`mcp_servers.my.server.url` parses as 3 levels). Current names (xcsift-mcp, cupertino) are unaffected. Quoting the segment risks breaking codex's `-c` path parser, so left as-is.
- Carlo had pre-existing uncommitted changes in the same file (env-var forwarding, extra mounts); `fish_indent` also normalized some quoting on those lines. Commit selectively.
