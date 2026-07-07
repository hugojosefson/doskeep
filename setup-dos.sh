#!/bin/bash
set -euo pipefail

# ─── Config ───
ROM_DIR="$HOME/Emulation/roms/dos"
STATE_DIR="$HOME/.config/dosdeck-setup"
STATE_FILE="$STATE_DIR/phase"

mkdir -p "$STATE_DIR"

save_phase() { echo "$1" > "$STATE_FILE"; }

phase_0() {
    [ -d "$HOME/Emulation" ] && return 0
    echo ">>> Installing EmuDeck..."
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash
    save_phase 1
    echo ""
    echo "─── Manual step ───"
    echo "The EmuDeck app should be open now."
    echo "In EmuDeck: Custom Mode → only check RetroArch → Steam ROM Manager → Install"
    echo ""
    echo "After that, re-run this script."
    exit 0
}

phase_1() {
    if [ ! -d "$HOME/Emulation" ]; then
        echo "─── Manual step ───"
        echo "Complete the EmuDeck GUI setup first, then re-run."
        save_phase 1
        exit 0
    fi
    mkdir -p "$ROM_DIR"
    return 0
}

phase_2() {
    if [ -z "$(ls -A "$ROM_DIR/" 2>/dev/null || true)" ]; then
        echo "─── Manual step ───"
        echo "Place DOS game .zip files into:"
        echo "  $ROM_DIR"
        echo ""
        echo "Get games from eXoDOS on archive.org:"
        echo "  https://archive.org/details/exodos-520"
        echo ""
        echo "Then re-run this script."
        save_phase 2
        exit 0
    fi
    return 0
}

phase_3() {
    SRM="$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    if [ ! -f "$SRM" ]; then
        echo "─── Error ───"
        echo "Steam ROM Manager not found at:"
        echo "  $SRM"
        echo "Re-run EmuDeck and make sure Steam ROM Manager is selected."
        save_phase 1
        exit 1
    fi
    echo ">>> Launching Steam ROM Manager..."
    "$SRM" &
    save_phase 4
    echo ""
    echo "─── Manual step ───"
    echo "In Steam ROM Manager:"
    echo "  1. Check 'DOSBox Pure (RetroArch)' parser"
    echo "  2. Click Preview"
    echo "  3. Click Save to Steam"
    echo "  4. Close Steam ROM Manager"
    echo ""
    echo "Then re-run this script."
    exit 0
}

phase_4() {
    echo ">>> Setup complete!"
    rm -f "$STATE_FILE"
    echo ">>> Returning to Gaming Mode..."
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null
    fi
    if command -v loginctl &>/dev/null; then
        loginctl terminate-user "$USER" 2>/dev/null
    fi
    echo "Failed to switch. Reboot or select Gaming Mode manually."
    exit 1
}

# ─── Main ───
PHASE=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

case "$PHASE" in
    0) phase_0 ;&
    1) phase_1 ;&
    2) phase_2 ;&
    3) phase_3 ;&
    4) phase_4 ;&
esac
