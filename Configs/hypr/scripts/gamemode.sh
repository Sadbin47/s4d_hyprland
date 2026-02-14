#!/usr/bin/env bash
# ── s4d Game Mode Toggle ──
# Disables animations, blur, borders & reduces gaps for maximum performance
# Toggle on/off with the same keybind (SUPER+ALT+G)
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/s4d-hyprland/gamemode"
mkdir -p "$(dirname "$CACHE")"

notify() { command -v notify-send &>/dev/null && notify-send -t 2000 -a "s4d" "$@"; }

if [[ -f "$CACHE" ]]; then
    # ── Disable game mode — restore normal settings ──
    hyprctl --batch "\
        keyword animations:enabled true;\
        keyword decoration:blur:enabled true;\
        keyword general:gaps_in 3;\
        keyword general:gaps_out 7;\
        keyword general:border_size 2;\
        keyword decoration:rounding 4;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 0.999;\
        keyword misc:vfr true"
    rm -f "$CACHE"
    notify "🎮 Game Mode" "Disabled — effects restored"
    echo "Game mode: OFF"
else
    # ── Enable game mode — disable eye candy ──
    hyprctl --batch "\
        keyword animations:enabled false;\
        keyword decoration:blur:enabled false;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 1;\
        keyword misc:vfr false"
    touch "$CACHE"
    notify "🎮 Game Mode" "Enabled — max performance"
    echo "Game mode: ON"
fi
