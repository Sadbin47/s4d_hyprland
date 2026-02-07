#!/bin/bash
# ── s4d Wallpaper Manager ────────────────────────────────────────────────────
# Uses swww for smooth wallpaper transitions

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
CACHE_FILE="${HOME}/.cache/s4d-hyprland/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")" "$WALLPAPER_DIR"

set_wallpaper() {
    local wallpaper="$1"
    if [[ ! -f "$wallpaper" ]]; then
        echo "File not found: $wallpaper"
        return 1
    fi
    
    # Wait for swww-daemon
    for i in {1..10}; do
        swww query &>/dev/null && break
        sleep 0.5
    done
    
    swww img "$wallpaper" \
        --transition-type grow \
        --transition-pos "$(hyprctl cursorpos)" \
        --transition-duration 2 \
        --transition-fps 60 \
        --transition-step 90 2>/dev/null || \
    swww img "$wallpaper" \
        --transition-type fade \
        --transition-duration 1 2>/dev/null
    
    echo "$wallpaper" > "$CACHE_FILE"
}

random_wallpaper() {
    if [[ ! -d "$WALLPAPER_DIR" ]] || [[ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]]; then
        echo "No wallpapers in $WALLPAPER_DIR"
        return 1
    fi
    local wallpaper
    wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" -o -name "*.gif" \) | shuf -n 1)
    if [[ -n "$wallpaper" ]]; then
        set_wallpaper "$wallpaper"
    fi
}

next_wallpaper() {
    local current=$(cat "$CACHE_FILE" 2>/dev/null)
    local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | sort))
    local count=${#wallpapers[@]}
    
    if [[ $count -eq 0 ]]; then return 1; fi
    
    local idx=0
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            idx=$(( (i + 1) % count ))
            break
        fi
    done
    
    set_wallpaper "${wallpapers[$idx]}"
}

prev_wallpaper() {
    local current=$(cat "$CACHE_FILE" 2>/dev/null)
    local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | sort))
    local count=${#wallpapers[@]}
    
    if [[ $count -eq 0 ]]; then return 1; fi
    
    local idx=$((count - 1))
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            idx=$(( (i - 1 + count) % count ))
            break
        fi
    done
    
    set_wallpaper "${wallpapers[$idx]}"
}

restore_wallpaper() {
    if [[ -f "$CACHE_FILE" ]]; then
        local saved=$(cat "$CACHE_FILE")
        if [[ -f "$saved" ]]; then
            set_wallpaper "$saved"
            return
        fi
    fi
    random_wallpaper
}

select_wallpaper() {
    local selected
    selected=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | \
        while read -r f; do basename "$f"; done | \
        rofi -dmenu -p "Wallpaper" -i)
    
    if [[ -n "$selected" ]]; then
        set_wallpaper "$WALLPAPER_DIR/$selected"
    fi
}

case "${1:-restore}" in
    set)      set_wallpaper "$2" ;;
    random)   random_wallpaper ;;
    next)     next_wallpaper ;;
    prev)     prev_wallpaper ;;
    restore)  restore_wallpaper ;;
    select)   select_wallpaper ;;
    *)        echo "Usage: wallpaper.sh {set <file>|random|next|prev|restore|select}" ;;
esac
