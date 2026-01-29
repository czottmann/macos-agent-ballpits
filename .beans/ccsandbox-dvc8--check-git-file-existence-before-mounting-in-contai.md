---
# ccsandbox-dvc8
title: Check git file existence before mounting in containered
status: todo
type: bug
created_at: 2026-01-29T12:19:12Z
updated_at: 2026-01-29T12:19:12Z
---

`claude-containered` mounts `~/.gitconfig` and `~/.git-credentials` unconditionally. If these files don't exist on the host, Docker creates *directories* at the mount points inside the container, which breaks git.

**Current behavior (lines 276-277):**
```fish
set -a docker_args -v "$HOME/.gitconfig:/home/claude/.gitconfig"
set -a docker_args -v "$HOME/.git-credentials:/home/claude/.git-credentials"
```

**Inconsistency:**
The `.pi` directory handling (lines 289-291) properly checks existence first:
```fish
if test -d "$HOME/.pi"
    set -a docker_args -v "$HOME/.pi:/home/claude/.pi"
end
```

**Fix:**
Apply the same pattern to git files—only mount if they exist.

**Affected files:**
- claude-containered/claude-containered