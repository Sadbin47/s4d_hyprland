#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  s4d Theme Manager — Switch animation / wallpaper / colors  ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
THEME_DIR="$CONFIG_DIR/animations"
COLOR_DIR="$CONFIG_DIR/colors"
WALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/s4d/wallpapers"
ROUTER="$CONFIG_DIR/animations.conf"

# ── Helpers ──
notify() { command -v notify-send &>/dev/null && notify-send -a "s4d-theme" "$@"; }
reload() { hyprctl reload &>/dev/null || true; }

usage() {
    cat <<'EOF'
s4d Theme Manager

USAGE:
  s4d-theme <command> [args]

COMMANDS:
  animation list           List available animation presets
  animation set <name>     Switch animation preset
  color list               List available color palettes
  color set <name>         Switch color palette
  wallpaper set <path>     Set wallpaper
  wallpaper random         Random wallpaper from collection
  wallpaper select         Pick wallpaper via rofi
  status                   Show current theme info
  help                     Show this help
EOF
}

# ── Animation Commands ──
animation_list() {
    echo "Available animation presets:"
    for f in "$THEME_DIR"/*.conf; do
        name=$(basename "$f" .conf)
        current=""
        grep -q "source.*animations/${name}.conf" "$ROUTER" 2>/dev/null && current=" ← active"
        echo "  • $name$current"
    done
}

animation_set() {
    local name="$1"
    local target="$THEME_DIR/${name}.conf"
    if [[ ! -f "$target" ]]; then
        echo "Error: animation preset '$name' not found"
        animation_list
        return 1
    fi
    # Update the router file
    echo "# Animation preset — managed by s4d-theme" > "$ROUTER"
    echo "source = ~/.config/hypr/animations/${name}.conf" >> "$ROUTER"
    reload
    notify "Animation" "Switched to: $name"
    echo "Animation preset set to: $name"
}

# ── Color Commands ──
color_list() {
    echo "Available color palettes:"
    for f in "$COLOR_DIR"/*.conf; do
        name=$(basename "$f" .conf)
        echo "  • $name"
    done
}

color_set() {
    local name="$1"
    local target="$COLOR_DIR/${name}.conf"
    if [[ ! -f "$target" ]]; then
        echo "Error: color palette '$name' not found"
        color_list
        return 1
    fi
    # Update the source line in hyprland.conf
    local main="$CONFIG_DIR/hyprland.conf"
    if grep -q "^source.*colors/" "$main"; then
        sed -i "s|^source.*colors/.*|source = ~/.config/hypr/colors/${name}.conf|" "$main"
    fi
    reload
    notify "Colors" "Switched to: $name"
    echo "Color palette set to: $name"
}

# ── Wallpaper Commands (delegate to wallpaper.sh) ──
wallpaper_cmd() {
    local wall_script="$CONFIG_DIR/scripts/wallpaper.sh"
    if [[ ! -x "$wall_script" ]]; then
        echo "Error: wallpaper.sh not found or not executable"
        return 1
    fi
    "$wall_script" "$@"
}

# ── Status ──
status() {
    echo "╭─ s4d Theme Status ─╮"
    # Current animation
    if [[ -f "$ROUTER" ]]; then
        local anim
        anim=$(grep "^source" "$ROUTER" 2>/dev/null | sed 's|.*animations/||;s|\.conf||' || echo "unknown")
        echo "│ Animation: $anim"
    fi
    # Current color
    local main="$CONFIG_DIR/hyprland.conf"
    if [[ -f "$main" ]]; then
        local color
        color=$(grep "^source.*colors/" "$main" 2>/dev/null | sed 's|.*colors/||;s|\.conf||' || echo "unknown")
        echo "│ Colors:    $color"
    fi
    # Current wallpaper
    local wall_cache="${XDG_CACHE_HOME:-$HOME/.cache}/s4d/current_wallpaper"
    if [[ -f "$wall_cache" ]]; then
        echo "│ Wallpaper: $(cat "$wall_cache")"
    fi
    echo "╰─────────────────────╯"
}

# ── Main Dispatch ──
case "${1:-help}" in
    animation)
        case "${2:-list}" in
            list) animation_list ;;
            set)  animation_set "${3:?Usage: s4d-theme animation set <name>}" ;;
            *)    echo "Usage: s4d-theme animation {list|set <name>}" ;;
        esac ;;
    color)
        case "${2:-list}" in
            list) color_list ;;
            set)  color_set "${3:?Usage: s4d-theme color set <name>}" ;;
            *)    echo "Usage: s4d-theme color {list|set <name>}" ;;
        esac ;;
    wallpaper)
        shift
        wallpaper_cmd "$@" ;;
    status)
        status ;;
    help|--help|-h|*)
        usage ;;
esac
