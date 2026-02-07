#!/bin/bash
#=============================================================================
# WALLPAPER SETUP — Use bundled wallpapers, create management script
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIGS_DIR="$SCRIPT_DIR/../Configs"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

log "${INFO} Setting up wallpapers..."

mkdir -p "$WALLPAPER_DIR"

# Copy bundled wallpapers
if [[ -d "$CONFIGS_DIR/Wallpapers" ]]; then
    local_count=$(find "$CONFIGS_DIR/Wallpapers" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | wc -l)
    if [[ "$local_count" -gt 0 ]]; then
        cp -n "$CONFIGS_DIR/Wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null || true
        log "${OK} Copied $local_count bundled wallpaper(s) to $WALLPAPER_DIR"
    fi
fi

# If still empty, download a default
total_count=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
if [[ "$total_count" -eq 0 ]]; then
    log "${INFO} No wallpapers found, downloading a default..."
    curl -fsSL -o "$WALLPAPER_DIR/catppuccin_triangle.png" \
        "https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic/catppuccin_triangle.png" 2>/dev/null || true
fi

# Create wallpaper management script
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/wallpaper" << 'WALLSCRIPT'
#!/usr/bin/env bash
# s4d Wallpaper Manager
# Usage: wallpaper {set <path>|random|select|next|prev|restore}

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE="$HOME/.cache/s4d-hyprland/current_wallpaper"
mkdir -p "$(dirname "$CACHE")" "$WALL_DIR"

get_walls() {
    find "$WALL_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | sort
}

ensure_swww() {
    pgrep -x swww-daemon > /dev/null 2>&1 || { swww-daemon & sleep 1; }
}

set_wall() {
    [[ ! -f "$1" ]] && echo "Not found: $1" && return 1
    ensure_swww
    swww img "$1" --transition-type grow --transition-pos 0.9,0.1 --transition-duration 1.5 --transition-fps 60 2>/dev/null
    echo "$1" > "$CACHE"
}

case "${1:-restore}" in
    set)
        [[ -n "$2" ]] && set_wall "$2" ;;
    random)
        mapfile -t walls < <(get_walls)
        [[ ${#walls[@]} -gt 0 ]] && set_wall "${walls[RANDOM % ${#walls[@]}]}" ;;
    next|prev)
        mapfile -t walls < <(get_walls)
        [[ ${#walls[@]} -eq 0 ]] && exit 0
        current=""; [[ -f "$CACHE" ]] && current=$(cat "$CACHE")
        idx=0
        for i in "${!walls[@]}"; do [[ "${walls[$i]}" == "$current" ]] && idx=$i && break; done
        [[ "$1" == "next" ]] && idx=$(( (idx + 1) % ${#walls[@]} )) || idx=$(( (idx - 1 + ${#walls[@]}) % ${#walls[@]} ))
        set_wall "${walls[$idx]}" ;;
    select)
        command -v rofi &>/dev/null || { echo "rofi required"; exit 1; }
        selected=$(get_walls | rofi -dmenu -p "Wallpaper" -i)
        [[ -n "$selected" ]] && set_wall "$selected" ;;
    restore)
        if [[ -f "$CACHE" ]] && [[ -f "$(cat "$CACHE")" ]]; then
            set_wall "$(cat "$CACHE")"
        else
            mapfile -t walls < <(get_walls)
            [[ ${#walls[@]} -gt 0 ]] && set_wall "${walls[0]}"
        fi ;;
    *)
        echo "Usage: wallpaper {set <path>|random|select|next|prev|restore}"
        echo ""; echo "Add wallpapers to: $WALL_DIR" ;;
esac
WALLSCRIPT

chmod +x "$HOME/.local/bin/wallpaper"

log "${OK} Wallpaper setup done"
log "${INFO} Add wallpapers to: $WALLPAPER_DIR"
log "${INFO} Commands: wallpaper random | wallpaper select | wallpaper next"
