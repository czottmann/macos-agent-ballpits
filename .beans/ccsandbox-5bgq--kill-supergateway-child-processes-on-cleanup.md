---
# ccsandbox-5bgq
title: Kill supergateway child processes on cleanup
status: completed
type: bug
priority: normal
created_at: 2026-04-11T16:33:39Z
updated_at: 2026-04-11T16:37:10Z
---

## Context

`claude-containered` (and `claude-sandboxed`) start supergateway in the background to bridge stdio MCP servers to HTTP/SSE. On cleanup we `kill $pid` the supergateway process, but supergateway doesn't reliably propagate SIGTERM to its spawned MCP child. Observed with `cupertino`: supergateway exits but the `cupertino serve` process lingers as an orphan. xcodebuild-mcp/kagi-ken-mcp happen to exit on stdin EOF, which masked the bug.

## Success criteria

- [x] `cleanup` in `claude-containered` kills the full descendant tree of each tracked supergateway PID, not just the PID itself
- [x] Same fix mirrored into `claude-sandboxed` (had the identical vulnerable pattern)
- [x] Works on macOS (no `setsid`, no GNU-only flags)
- [x] Still scoped to this session's PIDs — no system-wide `pkill` by pattern
- [x] Manual test: run with the cupertino MCP config, quit Claude, verify no `cupertino` process remains (e.g. `pgrep cupertino`)

## Observed vs. expected

- **Observed:** after exiting claude-containered, `pgrep cupertino` still returns a PID.
- **Expected:** no supergateway-spawned MCP processes remain after the launcher exits.

## Summary of Changes

Added a recursive `kill_tree` helper to both `claude-containered` and `claude-sandboxed` that walks the descendant tree of a given PID via `pgrep -P` and kills each process post-order. The `cleanup` function in each launcher now calls `kill_tree` for every tracked supergateway PID instead of a flat `kill`, so any MCP child that doesn't handle SIGTERM or stdin EOF cleanly (`cupertino serve` being the concrete case) gets terminated along with supergateway itself.

## Insights

- The bug was latent for a long time because `xcodebuild-mcp` and `kagi-ken-mcp` exit on stdin EOF when supergateway dies, which masked supergateway's failure to forward SIGTERM. `cupertino serve` is the first MCP we've used that stays alive past stdin close.
- `setsid` isn't available on macOS without installing util-linux, so the cleanest portable approach is walking `pgrep -P` recursively rather than trying to put each supergateway in its own process group.
