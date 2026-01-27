---
# ccsandbox-94ej
title: Create Dockerfile
status: completed
type: task
priority: normal
created_at: 2026-01-27T18:23:11Z
updated_at: 2026-01-27T18:28:29Z
parent: orbstack-cc-sandbox-4wkf
---

Create Alpine-based Docker image with Claude Code pre-installed.

**Files:**
- Create: `Dockerfile`

**Contents:**
- Base: `alpine:latest`
- Packages: bash, curl, ca-certificates, git, nodejs, npm, ripgrep, fd, sd, shadow
- User: Non-root `claude` user with bash shell
- Claude Code: Installed via `https://claude.ai/install.sh`
- PATH: Include `/home/claude/.local/bin`
- Workdir: `/workspace`
- CMD: `claude`

**Verification:**
- [x] `docker build -t cc-sandbox .` succeeds
- [x] Image size is reasonable (325MB)
- [x] `docker run --rm cc-sandbox which claude` returns path

## Summary of Changes
Created Dockerfile based on Alpine with Claude Code pre-installed. Image builds successfully at 325MB.
