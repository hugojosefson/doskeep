# eXoDOS + EmuDeck on Steam Deck

> **Warning:** This guide is untested. It may not work or may cause issues. Use
> at your own risk.

Play 7,600+ DOS games from Gaming Mode with full controller support.

## How it works

EmuDeck installs RetroArch + DOSBox Pure + Steam ROM Manager. You drop
individual eXoDOS game zips into the ROMs folder, run Steam ROM Manager, and
each game appears in your Steam library. No Desktop Mode needed after setup.

## Prerequisites

- Steam Deck with ~10 GB free for EmuDeck + RetroArch + DOSBox Pure
- Additional space per game (~1-500 MB each)
- A way to transfer eXoDOS game files to the Deck (USB drive, network, or
  download directly on Deck)

## Step-by-step

### Step 1 — Switch to Desktop Mode

Press `STEAM` button → **Power** → **Switch to Desktop**.

### Step 2 — Install EmuDeck

Open a browser, go to [emudeck.com](https://www.emudeck.com), download the
SteamOS installer (`EmuDeck.desktop`). Run it.

A terminal window opens. Let it install. When the EmuDeck app launches:

1. Click **Custom Mode**
2. Set storage to **Internal** (or your SD card)
3. On the emulator selection screen, **uncheck everything except RetroArch** (we
   only need DOS)
4. Click **Install**
5. When prompted, select **Steam ROM Manager** as your front end
6. Let it finish

### Step 3 — Get eXoDOS game files

You need individual game `.zip` files from the eXoDOS collection.

**Option A — Download individual games from archive.org:**

Browse https://archive.org/details/exodos-520 and download the `.zip` files for
games you want. Save them anywhere convenient.

**Option B — Transfer from another machine:**

Download the eXoDOS v6.04 full torrent (638 GB) or the v5.2 collection
(individual zips on archive.org) on a PC. Copy the `.zip` files to the Deck via
USB drive or `scp`.

### Step 4 — Place game zips in the ROMs folder

Open Dolphin (file manager). Navigate to:

```
/home/deck/Emulation/roms/dos/
```

Copy all your eXoDOS game `.zip` files into this folder.

DOSBox Pure can run `.zip` files directly — no extraction needed.

### Step 5 — Run Steam ROM Manager

Open the EmuDeck app, go to **Steam ROM Manager** in the sidebar, click **Run
Steam ROM Manager**.

A new window opens:

1. Make sure **DOSBox Pure (RetroArch)** parser is checked (it should be by
   default)
2. Click **Preview** — you'll see all your DOS games with artwork
3. Click **Save to Steam**
4. Close Steam ROM Manager

### Step 6 — Switch back to Gaming Mode

Double-click **Return to Gaming Mode** on the desktop.

### Step 7 — Play

Open your Steam library. You'll see a new **DOSBox Pure** collection with all
your games, each with box art. Pick one and launch it.

Controls are mapped automatically by EmuDeck:

- Left stick / D-pad = mouse movement
- Right stick = mouse (fine control)
- R2 = left click
- L2 = right click
- Start = Enter
- Select = Escape
- R stick click = show on-screen keyboard

## Where to find eXoDOS game files

| Source                    | URL                                                | Notes                           |
| :------------------------ | :------------------------------------------------- | :------------------------------ |
| eXoDOS v5.2 (archive.org) | https://archive.org/details/exodos-520             | Individual zips, ~20 GB total   |
| eXoDOS v6.04 full         | https://www.retro-exo.com/exodos.html              | 638 GB torrent, every game      |
| eXoDOS v6.04 Lite         | https://www.retro-exo.com/exodos.html              | 5 GB, downloads games on demand |
| Total DOS Collection      | https://archive.org/details/total-dos-collection-a | Raw zips, 29 GB just for A      |

For casual use, browse archive.org and grab specific games. For a complete
library, torrent the full eXoDOS v6.04 on a PC and transfer zips over.

## Adding more games later

Repeat steps 4-5 whenever you want to add new games. No need to redo EmuDeck.

## Troubleshooting

| Problem                   | Fix                                                                                |
| :------------------------ | :--------------------------------------------------------------------------------- |
| Games don't show in Steam | Run Steam ROM Manager again, click **Preview** then **Save to Steam**              |
| Controls don't work       | In RetroArch, go to Settings → Input → RetroPad Binds → set your device            |
| Game runs at wrong speed  | In RetroArch quick menu (F1), adjust DOSBox Pure CPU cycles                        |
| Black screen on launch    | Game may need mounting — open RetroArch quick menu → Disk Control → mount the .zip |
| Want per-game configs     | Right-click game in Steam → Properties → Launch Options → add `--ARG` flags        |
