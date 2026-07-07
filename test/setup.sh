#!/usr/bin/env bash
set -euo pipefail
FAIL=0

SCRIPT_DIR="/steamdeck"

clean() {
    rm -rf /tmp/test-home
}

# Create a valid VDF with a dummy DOSBox Pure shortcut (for SRM detection)
create_vdf_with_dosbox() {
    local file="$1"
    python3 -c "
import sys, vdf
file = sys.argv[1]
shortcuts = {
    'shortcuts': {
        '0': {
            'appname': 'DOSBox Pure Dummy',
            'exe': '/dummy/dosbox_pure/retroarch',
        }
    }
}
with open(file, 'wb') as f:
    vdf.binary_dump(shortcuts, f)
" "$file"
}

vdf_has_shortcut() {
    local file="$1" name="$2"
    grep -q "$name" "$file" 2>/dev/null
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
    local userdata="$HOME/.local/share/Steam/userdata/12345/config"
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores" \
        "$userdata"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    touch "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    create_vdf_with_dosbox "$userdata/shortcuts.vdf"
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

test_shortcut_create() {
    echo "=== Test: Steam shortcut creation ==="
    clean
    export HOME=/tmp/test-home
    local userdata="$HOME/.local/share/Steam/userdata/12345/config"
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores" \
        "$userdata"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    touch "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    create_vdf_with_dosbox "$userdata/shortcuts.vdf"
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "Added Steam shortcut"; then
        echo "PASS: shortcut added"
    else
        echo "FAIL: expected 'Added Steam shortcut'"
        echo "$output"
        FAIL=1
    fi
    if vdf_has_shortcut "$userdata/shortcuts.vdf" "eXoDOS Browser"; then
        echo "PASS: eXoDOS Browser found in VDF"
    else
        echo "FAIL: eXoDOS Browser not in VDF"
        FAIL=1
    fi
    echo ""
}

test_shortcut_idempotent() {
    echo "=== Test: Steam shortcut idempotent ==="
    clean
    export HOME=/tmp/test-home
    local userdata="$HOME/.local/share/Steam/userdata/12345/config"
    mkdir -p "$HOME/Emulation/roms/dos" \
        "$HOME/Emulation/tools" \
        "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores" \
        "$userdata"
    touch "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/dosbox_pure_libretro.so"
    touch "$HOME/Emulation/roms/dos/wolf3d.zip"
    touch "$HOME/Emulation/tools/Steam-ROM-Manager.AppImage"
    # First run: create the shortcut
    create_vdf_with_dosbox "$userdata/shortcuts.vdf"
    bash "$SCRIPT_DIR/doskeep" 2>&1 || true
    # Second run: should detect existing shortcut
    output=$(bash "$SCRIPT_DIR/doskeep" 2>&1 || true)
    if echo "$output" | grep -q "already exists"; then
        echo "PASS: shortcut already exists detected"
    else
        echo "FAIL: expected 'already exists' on second run"
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
test_shortcut_create
test_shortcut_idempotent

echo "============"
if [[ $FAIL == 0 ]]; then
    echo "All tests PASSED"
else
    echo "Some tests FAILED"
fi
exit "$FAIL"
