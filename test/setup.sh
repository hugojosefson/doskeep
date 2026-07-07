#!/bin/bash
set -euo pipefail
FAIL=0

SCRIPT_DIR="/steamdeck"

clean() {
    rm -rf /tmp/test-home
    rm -f /tmp/state
}

test_phase0_no_emu() {
    echo "=== Test: phase 0, no Emulation dir ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config"
    bash "$SCRIPT_DIR/dosdeck" 2>&1 || true
    if [ -f "$HOME/.config/dosdeck-setup/phase" ]; then
        echo "FAIL: state file created despite no curl"
        FAIL=1
    else
        echo "PASS: no state file (curl failed, as expected)"
    fi
    echo ""
}

test_phase0_emu_exists() {
    echo "=== Test: phase 0, Emulation dir exists ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config/dosdeck-setup" "$HOME/Emulation"
    output=$(bash "$SCRIPT_DIR/dosdeck" 2>&1 || true)
    if echo "$output" | grep -q "DOSBox Pure"; then
        echo "PASS: detected missing DOSBox Pure core"
    else
        echo "FAIL: expected DOSBox Pure core warning"
        echo "$output"
        FAIL=1
    fi
    if [ "$(cat "$HOME/.config/dosdeck-setup/phase" 2>/dev/null)" = "1" ]; then
        echo "PASS: phase=1 saved"
    else
        echo "FAIL: expected phase=1 state"
        FAIL=1
    fi
    echo ""
}

test_phase1_core_present() {
    echo "=== Test: phase 1, DOSBox Pure core present ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config/dosdeck-setup" "$HOME/Emulation/roms/dos" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    echo "1" > "$HOME/.config/dosdeck-setup/phase"
    output=$(bash "$SCRIPT_DIR/dosdeck" 2>&1 || true)
    if echo "$output" | grep -q "Place DOS game"; then
        echo "PASS: detected empty ROM dir"
    else
        echo "FAIL: expected empty ROM dir warning"
        echo "$output"
        FAIL=1
    fi
    if [ "$(cat "$HOME/.config/dosdeck-setup/phase" 2>/dev/null)" = "2" ]; then
        echo "PASS: phase=2 saved"
    else
        echo "FAIL: expected phase=2 state"
        FAIL=1
    fi
    echo ""
}

test_phase2_games_present() {
    echo "=== Test: phase 2, games present, no SRM ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config/dosdeck-setup" "$HOME/Emulation/roms/dos" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    echo "2" > "$HOME/.config/dosdeck-setup/phase"
    output=$(bash "$SCRIPT_DIR/dosdeck" 2>&1 || true)
    if echo "$output" | grep -q "Steam ROM Manager not found"; then
        echo "PASS: detected missing SRM"
    else
        echo "FAIL: expected SRM not found error"
        echo "$output"
        FAIL=1
    fi
    echo ""
}

test_phase3_srm_present() {
    echo "=== Test: phase 3, SRM present ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config/dosdeck-setup" "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    cat > "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage" << 'SRMOCK'
#!/bin/bash
sleep 10
SRMOCK
    chmod +x "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    echo "3" > "$HOME/.config/dosdeck-setup/phase"
    output=$(bash "$SCRIPT_DIR/dosdeck" 2>&1 || true)
    if echo "$output" | grep -q "Launching Steam ROM Manager"; then
        echo "PASS: SRM launched"
    else
        echo "FAIL: expected SRM launch"
        echo "$output"
        FAIL=1
    fi
    if [ "$(cat "$HOME/.config/dosdeck-setup/phase" 2>/dev/null)" = "4" ]; then
        echo "PASS: phase=4 saved"
    else
        echo "FAIL: expected phase=4 state"
        FAIL=1
    fi
    pgrep -f "Steam-ROM-Manager.AppImage" | xargs -r kill 2>/dev/null || true
    echo ""
}

test_phase4_cleanup() {
    echo "=== Test: phase 4, cleanup ==="
    clean
    export HOME=/tmp/test-home
    mkdir -p "$HOME/.config/dosdeck-setup" "$HOME/Emulation/roms/dos"
    echo "4" > "$HOME/.config/dosdeck-setup/phase"
    output=$(bash "$SCRIPT_DIR/dosdeck" 2>&1 || true)
    if echo "$output" | grep -q "Failed to switch"; then
        echo "PASS: detected no Gaming Mode switch available"
    else
        echo "FAIL: expected 'Failed to switch' message"
        echo "$output"
        FAIL=1
    fi
    if [ ! -f "$HOME/.config/dosdeck-setup/phase" ]; then
        echo "PASS: state file removed"
    else
        echo "FAIL: state file should be removed"
        FAIL=1
    fi
    echo ""
}

test_phase0_emu_exists
test_phase1_core_present
test_phase2_games_present
test_phase3_srm_present
test_phase4_cleanup

echo "============"
if [ "$FAIL" = "0" ]; then
    echo "All tests PASSED"
else
    echo "Some tests FAILED"
fi
exit "$FAIL"
