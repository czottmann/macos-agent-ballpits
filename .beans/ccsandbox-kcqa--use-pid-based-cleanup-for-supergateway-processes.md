---
# ccsandbox-kcqa
title: Use PID-based cleanup for supergateway processes
status: todo
type: bug
priority: normal
created_at: 2026-01-29T12:18:54Z
updated_at: 2026-01-29T12:18:57Z
parent: ccsandbox-co2x
---

Both launchers use `pkill -f "supergateway.*--port"` to clean up supergateway processes on exit. This kills *all* matching processes system-wide, not just the ones started by the current session.

**Problem:**
Running multiple sandbox sessions simultaneously causes them to interfere—exiting one session kills the MCP servers of all other sessions.

**Current state:**
- `claude-containered` already collects PIDs into `supergateway_pids` (line 145) but never uses them
- `claude-sandboxed` doesn't track PIDs at all

**Fix:**
Track PIDs in both launchers and kill only those specific processes on cleanup:
```fish
for pid in $supergateway_pids
    kill $pid 2>/dev/null
end
```

**Affected files:**
- claude-containered/claude-containered
- claude-sandboxed/claude-sandboxed