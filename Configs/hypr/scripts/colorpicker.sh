#!/usr/bin/env bash
# ── s4d Color Picker ──
# Requires: hyprpicker, wl-copy
set -euo pipefail

color=$(hyprpicker -a 2>/dev/null) || exit 0

if [[ -n "$color" ]]; then
    echo -n "$color" | wl-copy 2>/dev/null || true
    notify-send -a "Color Picker" "Copied: $color" 2>/dev/null || true
    echo "$color"
fi
