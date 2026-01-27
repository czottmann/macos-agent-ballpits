---
# ccsandbox-ejs0
title: Switch Docker image to Debian for pi-coding-agent compatibility
status: completed
type: task
priority: normal
created_at: 2026-01-27T21:27:13Z
updated_at: 2026-01-27T21:46:02Z
---

Switch Docker image from Alpine to Debian for pi-coding-agent compatibility.

**Problem:**
Alpine uses musl libc which lacks support for @mariozechner/clipboard native module.

**Solution:**
Switch from Alpine to Debian (glibc-based) for native module compatibility.

**Files:**
- Modified: `Dockerfile`

**Changes:**
- [x] Switch base image from `alpine:latest` to `debian:bookworm-slim`
- [x] Convert apk commands to apt-get
- [x] Handle fd (named fdfind in Debian, added symlink)
- [x] Install sd via binary download (musl build works on glibc)
- [x] Install Go 1.24 from official source (Debian's too old for beans)
- [x] Install Node.js 22 from NodeSource (Debian's v18 too old for pi-coding-agent)
- [x] Verify pi-coding-agent works

**Verification:**
- [x] `docker build` succeeds
- [x] `pi` command works in container

## Summary of Changes
Switched from Alpine to Debian bookworm-slim. Required installing Go and Node.js from external sources since Debian stable versions were too old.