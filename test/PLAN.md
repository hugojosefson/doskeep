# Plan: closing test gaps

## Gaps that are fixable

| Gap                        | Fix                                                                                                                        |
| :------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| Python shortcut creation   | Install `python` + `python-pip` + `vdf` pip package in Dockerfile. Then `add_steam_shortcut` actually runs.                |
| Steam shortcut idempotency | Same Python fix. After first run creates shortcut, second run prints "already exists". Tests verify both messages.         |
| Gaming Mode return         | Add mock `steamos-session-select` to PATH; run via `script` pseudo-tty to make `[[ -t 0 ]]` true. Verify mock was invoked. |

## Gaps NOT fixable

| Gap                                                     | Why                                                                  |
| :------------------------------------------------------ | :------------------------------------------------------------------- |
| Steam ROM Manager logic                                 | Would need real SRM .AppImage in Docker. Not practical.              |
| `zenity` / `notify-send` popups                         | Need a GUI stack (X11/Wayland). Not available in Docker.             |
| Self-update / curl-bash pipe / exodos-browser downloads | Need a local HTTP server. Possible but complex; low value vs effort. |

## Changes to make

### Dockerfile

- Add `python python-pip` to `pacman -Syu` line
- Add `pip install vdf` after

### test/setup.sh

- Add `create_vdf_with_dosbox()` helper: writes valid binary VDF with a dummy
  "DOSBox Pure" shortcut (so SRM check passes)
- Add `vdf_has_shortcut()` helper: grep binary VDF for shortcut name
- `test_all_done` — use `create_vdf_with_dosbox` instead of fake text file
- New `test_shortcut_create` — verify "Added Steam shortcut" message + shortcut
  appears in VDF
- New `test_shortcut_idempotent` — second run prints "already exists"
- Remove unused `create_empty_vdf()` helper

### test/README.md

- Move "Python shortcut creation" and "Steam shortcut idempotency" from NOT
  tested → tested
- Add "Gaming Mode return" as potentially testable (needs pseudo-tty)
