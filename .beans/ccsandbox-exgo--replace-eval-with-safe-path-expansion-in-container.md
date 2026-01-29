---
# ccsandbox-exgo
title: Replace eval with safe path expansion in containered
status: completed
type: bug
priority: normal
created_at: 2026-01-29T12:19:24Z
updated_at: 2026-01-29T12:49:48Z
---

`claude-containered` uses `eval echo $ro_path` (line 296) to expand paths provided via `--ro`. While the input comes from the user, using `eval` is unnecessarily risky and fish has safer alternatives.

**Current code:**
```fish
set -l expanded_path (eval echo $ro_path)
```

**Fix:**
Use fish's string replacement:
```fish
set -l expanded_path (string replace '~' "$HOME" -- $ro_path)
```

Or simply rely on `realpath` which already handles `~` on modern systems.

**Affected files:**
- claude-containered/claude-containered

## Summary of Changes

Replaced `eval echo $ro_path` with `path normalize "$ro_path"` — fish's built-in path normalization that safely expands `~` without eval risks.