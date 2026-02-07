#!/usr/bin/env bash
# ── s4d Power Menu (rofi) ──

entries="⏻ Shutdown\n⏼ Suspend\n Reboot\n Lock\n Logout"

selected=$(echo -e "$entries" | rofi -dmenu -p "Power" -i -theme-str '
window { width: 280px; }
listview { lines: 5; columns: 1; }
element-icon { enabled: false; }
')

case "$selected" in
    *Shutdown) systemctl poweroff ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Lock)     hyprlock ;;
    *Logout)   hyprctl dispatch exit ;;
esac
