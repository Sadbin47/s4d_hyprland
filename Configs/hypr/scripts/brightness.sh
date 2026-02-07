#!/bin/bash
# ── Brightness OSD Notification ──────────────────────────────────────────────
# Usage: brightness.sh --inc | --dec

step=10

case "$1" in
    --inc)
        brightnessctl set +${step}%
        ;;
    --dec)
        brightnessctl set ${step}%-
        ;;
esac

brightness=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
notify-send -t 800 -r 2595 -h int:value:$brightness "Brightness" "${brightness}%"
