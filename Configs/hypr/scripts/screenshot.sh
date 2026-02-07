#!/usr/bin/env bash
# ── s4d Screenshot Helper ──
# Requires: grim, slurp, wl-copy (wl-clipboard)
set -euo pipefail

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"

timestamp=$(date +%Y%m%d_%H%M%S)
filename="$SAVE_DIR/screenshot_${timestamp}.png"
notify() { command -v notify-send &>/dev/null && notify-send -i "$filename" "$@"; }

case "${1:-full}" in
    full)
        grim "$filename"
        wl-copy < "$filename" 2>/dev/null || true
        notify "Screenshot" "Fullscreen saved & copied"
        ;;
    area)
        region=$(slurp 2>/dev/null) || exit 0
        grim -g "$region" "$filename"
        wl-copy < "$filename" 2>/dev/null || true
        notify "Screenshot" "Area saved & copied"
        ;;
    active)
        geo=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [[ -n "$geo" && "$geo" != "null" ]]; then
            grim -g "$geo" "$filename"
            wl-copy < "$filename" 2>/dev/null || true
            notify "Screenshot" "Window saved & copied"
        else
            grim "$filename"
            wl-copy < "$filename" 2>/dev/null || true
            notify "Screenshot" "Fullscreen saved & copied"
        fi
        ;;
    *)
        echo "Usage: screenshot.sh {full|area|active}"
        exit 1
        ;;
esac
