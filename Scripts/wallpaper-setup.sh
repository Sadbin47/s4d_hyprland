#!/bin/bash
#=============================================================================
# WALLPAPER SETUP - Download sample wallpapers and configure SWWW
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Setting up wallpapers..."

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"

#=============================================================================
# DOWNLOAD SAMPLE WALLPAPERS
#=============================================================================
download_wallpapers() {
    log "${INFO} Downloading sample wallpapers..."
    
    # Catppuccin wallpapers from GitHub
    local WALL_REPO="https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic"
    
    local wallpapers=(
        "catppuccin_triangle.png"
        "catppuccin-colors.png"
    )
    
    for wall in "${wallpapers[@]}"; do
        if [[ ! -f "$WALLPAPER_DIR/$wall" ]]; then
            curl -sL "$WALL_REPO/$wall" -o "$WALLPAPER_DIR/$wall" 2>/dev/null || true
        fi
    done
    
    log "${OK} Wallpapers downloaded to $WALLPAPER_DIR"
}

#=============================================================================
# CREATE WALLPAPER SCRIPT
#=============================================================================
create_wallpaper_script() {
    log "${INFO} Creating wallpaper management script..."
    
    mkdir -p "$HOME/.local/bin"
    
    cat > "$HOME/.local/bin/wallpaper" << 'EOF'
#!/bin/bash
# Wallpaper management script for SWWW

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/current_wallpaper"

set_wallpaper() {
    local wall="$1"
    
    if [[ ! -f "$wall" ]]; then
        echo "Wallpaper not found: $wall"
        exit 1
    fi
    
    # Check if swww-daemon is running
    if ! pgrep -x swww-daemon > /dev/null; then
        swww-daemon &
        sleep 1
    fi
    
    # Set wallpaper with transition
    swww img "$wall" \
        --transition-type grow \
        --transition-pos 0.9,0.1 \
        --transition-duration 1.5 \
        --transition-fps 60
    
    # Cache current wallpaper
    echo "$wall" > "$CACHE_FILE"
    
    echo "Wallpaper set: $wall"
}

random_wallpaper() {
    local walls=("$WALLPAPER_DIR"/*)
    
    if [[ ${#walls[@]} -eq 0 ]]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    
    local random_wall="${walls[RANDOM % ${#walls[@]}]}"
    set_wallpaper "$random_wall"
}

select_wallpaper() {
    if ! command -v rofi &>/dev/null; then
        echo "Rofi is required for wallpaper selection"
        exit 1
    fi
    
    local selected
    selected=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | \
        rofi -dmenu -p "Wallpaper" -i)
    
    if [[ -n "$selected" ]]; then
        set_wallpaper "$selected"
    fi
}

restore_wallpaper() {
    if [[ -f "$CACHE_FILE" ]]; then
        local cached_wall
        cached_wall=$(cat "$CACHE_FILE")
        if [[ -f "$cached_wall" ]]; then
            set_wallpaper "$cached_wall"
            return
        fi
    fi
    
    # Fallback to random
    random_wallpaper
}

case "$1" in
    set)
        set_wallpaper "$2"
        ;;
    random)
        random_wallpaper
        ;;
    select)
        select_wallpaper
        ;;
    restore)
        restore_wallpaper
        ;;
    *)
        echo "Usage: wallpaper {set <path>|random|select|restore}"
        exit 1
        ;;
esac
EOF
    
    chmod +x "$HOME/.local/bin/wallpaper"
    log "${OK} Wallpaper script created: ~/.local/bin/wallpaper"
}

#=============================================================================
# MAIN
#=============================================================================
main() {
    download_wallpapers
    create_wallpaper_script
    
    # Set initial wallpaper
    if command -v swww &>/dev/null; then
        "$HOME/.local/bin/wallpaper" random 2>/dev/null || true
    fi
    
    log "${OK} Wallpaper setup complete"
    log "${INFO} Use 'wallpaper random' or 'wallpaper select' to change wallpapers"
}

main
