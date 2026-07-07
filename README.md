# doskeep

> **Warning:** Everything here is untested. It may not work or may cause issues.
> Use at your own risk.

Idempotent setup + game browser for playing eXoDOS games on Steam Deck via
RetroArch + DOSBox Pure.

Install with one command, then re-run anytime to browse and download more games:

```bash
curl -L https://raw.githubusercontent.com/hugojosefson/doskeep/main/doskeep | bash
```

The script:
1. Installs EmuDeck + RetroArch + DOSBox Pure + Steam ROM Manager
2. Checks for game files — offers to browse/download from eXoDOS on archive.org
3. Launches Steam ROM Manager to add games to your Steam library
4. Adds itself as a non-Steam game so you can browse/download from Gaming Mode
5. When setup is complete, opens the game browser automatically

Re-run it after each manual step to continue where you left off.

## Files

| File | Purpose |
| :--- | :------ |
| [doskeep](doskeep) | main CLI tool |
| [exodos-browser.sh](exodos-browser.sh) | standalone game browser (used by doskeep) |
| [exodos-emudeck.md](exodos-emudeck.md) | step-by-step manual guide |

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and testing.
