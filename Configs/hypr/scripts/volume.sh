#!/bin/bash
# ── Volume OSD Notification ──────────────────────────────────────────────────
# Usage: volume.sh --inc | --dec | --toggle | --toggle-mic

step=5

case "$1" in
    --inc)
        pamixer -i $step
        vol=$(pamixer --get-volume)
        notify-send -t 800 -r 2593 -h int:value:$vol "Volume" "${vol}%"
        ;;
    --dec)
        pamixer -d $step
        vol=$(pamixer --get-volume)
        notify-send -t 800 -r 2593 -h int:value:$vol "Volume" "${vol}%"
        ;;
    --toggle)
        pamixer -t
        if pamixer --get-mute | grep -q "true"; then
            notify-send -t 800 -r 2593 "Volume" "Muted 󰖁"
        else
            vol=$(pamixer --get-volume)
            notify-send -t 800 -r 2593 -h int:value:$vol "Volume" "${vol}%"
        fi
        ;;
    --toggle-mic)
        pamixer --default-source -t
        if pamixer --default-source --get-mute | grep -q "true"; then
            notify-send -t 800 -r 2594 "Microphone" "Muted 󰍭"
        else
            notify-send -t 800 -r 2594 "Microphone" "Unmuted 󰍬"
        fi
        ;;
esac
