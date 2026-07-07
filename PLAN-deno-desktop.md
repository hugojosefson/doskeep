# Plan: rewrite doskeep as a Deno Desktop app for Steam Deck Game Mode

## What exists now (`doskeep`)

Bash script with inlined Python, single file. Works in both Desktop Mode (tty) and
Game Mode (zenity fallback). Phases: precondition checks → game browser → Steam
shortcut → finish.

## Target: Deno Desktop app

Based on [deno-desktop-steamdeck](../deno-desktop-steamdeck/) — minimal
hello-world with auto-update, controller support, and AppImage build.

### Key differences

| Aspect | Bash doskeep | Deno Desktop doskeep |
| :----- | :----------- | :------------------- |
| UI | `read -rp` / `zenity` | HTML + CSS + JS webview, controller-native |
| Distribution | `curl \| bash` | AppImage (click-to-run) |
| Auto-update | sha256 comparison with remote | `Deno.autoUpdate()` built-in |
| Steam shortcut | inline Python + `vdf` | Deno subprocess or JS vdf lib |
| Game Mode | zenity fallback for prompts | Native Gamepad API, designed for Game Mode |
| Precondition checks | bash `[[ -f ... ]]` | `Deno.stat()`, `Deno.readDir()` |
| Game browser | curl + grep + read loop | `fetch()` + `<input>` search + download button |
| Language | bash + Python inline | TypeScript, single runtime |

### Architecture

```
main.ts
├── autoUpdate() — hourly check
├── Deno.serve() — HTTP server
│   ├── GET / → HTML shell + SPA
│   ├── API routes
│   │   ├── GET /api/status
│   │   ├── POST /api/emudeck/install
│   │   ├── GET /api/games/list
│   │   ├── POST /api/games/download
│   │   └── POST /api/shortcut/add
│   └── static assets (inline)
├── Deno Desktop — webview window
└── AppImage packaging
```

### App flow (from Game Mode)

1. Launch AppImage → webview opens with controller-friendly UI
2. Status page shows 4 checkboxes (EmuDeck, core, games, SRM)
3. Each failed check shows an action button
4. When all pass, game browser appears (search + download)
5. After downloads, "Add to Steam" button creates the shortcut
6. User closes app, games appear in Steam

### Decisions so far

| Question | Decision |
| :------- | :------- |
| Bash coexistence? | Replace entirely. Deno Desktop becomes the only doskeep. |
| Steam shortcut vdf? | `npm:steam-binary-vdf` — works with Deno, no Python needed. Read + write round-trip verified. |
| Auto-update? | `Deno.autoUpdate()` with release manifest (same pattern as hello-world POC). |
| First feature? | Both precondition status + game browser together in initial version. |

### Unknowns / questions

- AppImage path: `~/Emulation/tools/doskeep` or `~/.local/bin/`?
- User data storage: Deno KV or flat files?
- Dual bootstrap: keep bash script for `curl | bash` alongside AppImage?

## Implementation order

1. Set up project skeleton (`deno.jsonc`, `main.ts`, HTML shell, build task)
2. Precondition checks (filesystem status API)
3. eXoDOS game browser (search + download UI)
4. Steam shortcut creation (vdf via `npm:steam-binary-vdf`)
5. Auto-update, AppImage build, GitHub Actions CI + release
6. Remove bash script
