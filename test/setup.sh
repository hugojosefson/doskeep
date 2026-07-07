#!/usr/bin/env bash
set -euo pipefail
FAIL=0

SCRIPT_DIR="/steamdeck"

clean() {
    rm -rf /tmp/test-home
}

test_no_emu() {
    echo "=== Test: no Emulation dir ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "Installing EmuDeck"; then
        echo "PASS: detected missing Emulation dir"
    else
        echo "FAIL: expected 'Installing EmuDeck'"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_emu_no_core() {
    echo "=== Test: Emulation dir exists, no core ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/Emulation"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "DOSBox Pure"; then
        echo "PASS: detected missing DOSBox Pure core"
    else
        echo "FAIL: expected DOSBox Pure core warning"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_core_no_games() {
    echo "=== Test: core present, no games ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/Emulation" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "No game files found"; then
        echo "PASS: detected empty ROM dir"
    else
        echo "FAIL: expected 'No game files found'"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_games_no_srm() {
    echo "=== Test: games present, no SRM ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "Steam ROM Manager not found"; then
        echo "PASS: detected missing SRM"
    else
        echo "FAIL: expected 'Steam ROM Manager not found'"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_srm_needed() {
    echo "=== Test: SRM present, no Steam shortcuts ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    cat > "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage" << 'SRMOCK'
#!/bin/bash
sleep 10
SRMOCK
    chmod +x "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "Launching Steam ROM Manager"; then
        echo "PASS: SRM launched"
    else
        echo "FAIL: expected SRM launch"
        echo "$output"
        FAIL=1
    fi
    pgrep -f "Steam-ROM-Manager.AppImage" | xargs -r kill 2>/dev/null || true
    echo ""
}

test_all_done() {
    echo "=== Test: everything set up ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores" \
        "$HOME/.local/share/Steam/userdata/12345/config"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    touch "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    echo "binary with dosbox_pure in it" \
        > "$HOME/.local/share/Steam/userdata/12345/config/shortcuts.vdf"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "doskeep setup complete"; then
        echo "PASS: completed all checks, reached end"
    else
        echo "FAIL: expected 'doskeep setup complete' at end"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_no_emu
test_emu_no_core
test_core_no_games
test_games_no_srm
test_srm_needed
test_all_done

echo "============"
if [[ $FAIL == 0 ]]; then
    echo "All tests PASSED"
else
    echo "Some tests FAILED"
fi
exit "$FAIL"
