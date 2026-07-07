#!/bin/bash
set -euo pipefail

save_phase() { echo "$1" > "$STATE_FILE"; }

main() {
    ROM_DIR="$HOME/Emulation/roms/dos"
    STATE_DIR="$HOME/.config/dosdeck-setup"
    STATE_FILE="$STATE_DIR/phase"

    mkdir -p "$STATE_DIR"

    PHASE=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

    case "$PHASE" in
        0) phase_0 ;&
        1) phase_1 ;&
        2) phase_2 ;&
        3) phase_3 ;&
        4) phase_4 ;&
    esac
}

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

    # Check if DOSBox Pure core is installed (common locations)
    DOSBOX_CORE=""
    for p in \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so" \
        "$HOME/Emulation/roms/ports/RetroArch/cores/dosbox_pure_libretro.so" \
        "$HOME/.config/retroarch/cores/dosbox_pure_libretro.so"; do
        [ -f "$p" ] && DOSBOX_CORE="$p" && break
    done

    if [ -z "$DOSBOX_CORE" ]; then
        echo "─── Manual step ───"
        echo "Open RetroArch → Online Updater → Core Download"
        echo "Scroll down → install 'DOSBox Pure'"
        echo ""
        echo "Then re-run this script."
        save_phase 1
        exit 0
    fi
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
    sleep 2
    if ! pgrep -f "$SRM" >/dev/null 2>&1; then
        echo "─── Error ───"
        echo "Steam ROM Manager failed to start. Try launching it manually from:"
        echo "  $SRM"
        exit 1
    fi
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
    for cmd in \
        "steamos-session-select gamescope" \
        "loginctl terminate-user ${USER:-deck}"; do
        if command -v "${cmd%% *}" &>/dev/null; then
            $cmd && exit 0
        fi
    done
    echo "Failed to switch. Reboot or select Gaming Mode manually."
    exit 1
}

main "$@"
