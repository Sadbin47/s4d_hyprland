#!/bin/bash
# ── Touchpad Toggle ──────────────────────────────────────────────────────────
HYPRLAND_DEVICE=$(hyprctl devices -j | grep -oP '"name": "\K[^"]*touchpad[^"]*' | head -1)

if [[ -z "$HYPRLAND_DEVICE" ]]; then
    notify-send "Touchpad" "No touchpad device found"
    exit 1
fi

STATUS=$(hyprctl getoption "device[$HYPRLAND_DEVICE]:enabled" -j | grep -oP '"int": \K\d+')

if [[ "$STATUS" == "1" ]]; then
    hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
    notify-send -t 1500 "Touchpad" "Disabled"
else
    hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
    notify-send -t 1500 "Touchpad" "Enabled"
fi
