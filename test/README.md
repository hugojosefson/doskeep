# test

Tests run in Docker on `docker.io/ianburgwin/steamos:base` (Arch Linux, no GUI,
no Steam). Python3 + `vdf` are installed for Steam shortcut testing.

## What is tested

| Test                       | What it checks                                                                                                                       |
| :------------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| `test_no_emu`              | `ensure_emulation_dir` detects missing `~/Emulation`                                                                                 |
| `test_emu_no_core`         | `ensure_dosbox_pure_core` detects missing DOSBox Pure core                                                                           |
| `test_core_no_games`       | `ensure_games_present` detects empty ROM dir                                                                                         |
| `test_games_no_srm`        | `ensure_srm_completed` detects missing Steam ROM Manager                                                                             |
| `test_srm_needed`          | `ensure_srm_completed` launches SRM when no DOS shortcuts exist in Steam                                                             |
| `test_all_done`            | Full end-to-end: all preconditions pass, Steam shortcut runs, browser opens, `prompt()` falls back to `echo` (no zenity), clean exit |
| `test_shortcut_create`     | `add_steam_shortcut` creates a new Steam shortcut entry in `shortcuts.vdf`                                                           |
| `test_shortcut_idempotent` | Second run detects existing shortcut, prints "already exists" without adding duplicate                                               |

## What is NOT tested

| Gap                                  | Why                                                                            |
| :----------------------------------- | :----------------------------------------------------------------------------- |
| Steam ROM Manager logic              | SRM is a mock script (`sleep 10`). Only launch detection is tested.            |
| `zenity` / `notify-send` popups      | No GUI stack in Docker. `notify()` and `prompt()` both fall through to `echo`. |
| Self-update (`sha256sum` comparison) | No network to the remote URL; `curl -sL "$REMOTE_URL"` returns nothing.        |
| `curl \| bash` pipe install          | `is_piped` path is never triggered (script runs from local `bash`).            |
| `exodos_browser` downloads           | No network to archive.org; the `curl \| grep` pipeline fails.                  |
| Gaming Mode return                   | `steamos-session-select` and `loginctl` don't exist in Docker.                 |
