# doskeep project rules

## Shebang

- Use `#!/usr/bin/env bash` — never `#!/bin/bash` or other paths.
- Script files must have no file extension (e.g. `doskeep`, never `doskeep.sh`).

## Bashisms

- Always prefer `[[ ... ]]` over `[ ... ]` (fewer quoting bugs, more features).
- Use `&>/dev/null` instead of `>/dev/null 2>&1`.
- Use `(( ... ))` for arithmetic instead of `$(( ... ))` where possible.
- Prefer `${var,,}` / `${var^^}` for case manipulation.
- Use `local` for all function-scoped variables.
- Use `set -euo pipefail` at the top of every script.

## Single-file self-management

- One script file, zero dependencies beyond Steam Deck baseline.
- The script detects `curl | bash` pipe → downloads canonical copy → exec.
- On subsequent runs, compare sha256 with remote → self-update in-place → exec.
- All logic (Steam shortcut Python, game browser UI) must be inlined, not
  separate files.

## Idempotency

- Every phase must be safe to re-run. State tracked in
  `~/.config/doskeep-setup/phase`.
- Never assume prior state; check files, dirs, and installed tools before
  acting.
- Manual steps pause with a message and `exit 0` so the user re-runs after
  completing them.

## Testing

- Tests run via Docker on `docker.io/ianburgwin/steamos:base`.
- Every phase gets a dedicated test case.
- All tests must pass before any commit.

## Conventions

- Only edit the year and full name in LICENSE; never touch legal boilerplate.
- No emojis in code, docs, or commit messages.
- Be concise. No preamble, no summary, no thank-yous.
- Commit messages use conventional commits: `feat:`, `fix:`, `chore:`, etc.
- Run `deno fmt .` before every commit.
- Never commit without running `make test` first (and `make` if docs changed).
- Commit early, commit often, push each commit. No stashing or sitting on
  changes.
