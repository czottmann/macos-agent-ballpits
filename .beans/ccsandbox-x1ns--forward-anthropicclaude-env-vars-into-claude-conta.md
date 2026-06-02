---
# ccsandbox-x1ns
title: Forward Anthropic/Claude env vars into claude-containered Docker container
status: completed
type: feature
priority: normal
created_at: 2026-05-27T08:42:26Z
updated_at: 2026-05-27T08:43:25Z
---

## Context

The `claude-containered` launcher runs Claude Code inside a Docker container, but currently does not forward Anthropic/Claude-related env vars from the host process. This means callers cannot route Claude Code to alternate Anthropic-compatible providers (DeepSeek, etc.) by setting env vars before invoking the script — e.g. `set -x ANTHROPIC_BASE_URL …` has no effect inside the container.

## Scope boundaries

- Only forwards an allowlist of known Anthropic/Claude env vars.
- Does NOT hard-code any provider details in the script.
- Does NOT change the existing `-e TERM` / `-e COLORTERM` forwarding block.

## Success criteria

- [x] Right after the existing `set -a docker_args -e TERM` / `-e COLORTERM` block, the script conditionally appends `-e VAR` for each of the following env vars if `set -q VAR` is true:
  - `ANTHROPIC_BASE_URL`
  - `ANTHROPIC_AUTH_TOKEN`
  - `ANTHROPIC_API_KEY` (note: may be intentionally empty string — `set -q` is still true, which is correct)
  - `ANTHROPIC_MODEL`
  - `ANTHROPIC_DEFAULT_OPUS_MODEL`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL`
  - `CLAUDE_CODE_SUBAGENT_MODEL`
  - `CLAUDE_CODE_EFFORT_LEVEL`
  - `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`
  - `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK`
- [x] Agent: `ANTHROPIC_BASE_URL=foo claude-containered -- env | grep ANTHROPIC_BASE_URL` prints `foo` from inside the container.

## Summary of Changes

Added a fish `for` loop right after the `-e TERM`/`-e COLORTERM` block in `claude-containered/claude-containered` that iterates over an allowlist of Anthropic/Claude env vars and appends `-e VAR` (no `=value`) to `docker_args` when `set -q VAR` is true. Docker then reads each value from the host at run time, so callers can route Claude Code to alternate Anthropic-compatible providers by exporting the relevant vars before invoking the script.

Verified: `ANTHROPIC_BASE_URL=foo claude-containered -- env | grep ANTHROPIC_BASE_URL` prints `ANTHROPIC_BASE_URL=foo` from inside the container.
