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

## State-less precondition checking

- No state files. Every function checks the actual system state before acting.
- Functions inspect files, directories, and installed tools to decide if a step
  is already done.
- Each function returns 0 if its precondition is met, otherwise acts or
  instructs the user.
- Manual steps pause with a message and `exit 0` so the user re-runs after
  completing them.

## Game Mode awareness

- When run from Game Mode (`[[ -t 0 ]]` is false), do not prompt interactively.
- Use `zenity --info` (available on Steam Deck) for output visible in Game Mode.
- When not a tty, skip browser launch and gaming-mode-switch since already
  there.
- The Steam shortcut should work with zero arguments; the script auto-detects
  tty vs Game Mode and adapts behavior.

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
