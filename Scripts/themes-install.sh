#!/bin/bash
#=============================================================================
# THEME INSTALLATION - GTK, Qt, Icons, Cursors
# Reference: JaKooLit/GTK-themes-icons and Catppuccin
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing themes..."

# Theme directories
THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.icons"
CURSORS_DIR="$HOME/.icons"  # Cursors go in .icons too

mkdir -p "$THEMES_DIR" "$ICONS_DIR"

#=============================================================================
# GTK THEMES
#=============================================================================
install_gtk_themes() {
    log "${INFO} Installing GTK themes..."
    
    # Install GTK engine first
    install_pkg "gtk-engine-murrine"
    install_pkg "unzip"
    
    # Method 1: Clone JaKooLit's GTK themes (pre-packaged, includes Catppuccin)
    log "${INFO} Downloading GTK themes from JaKooLit..."
    local tmp_dir=$(mktemp -d)
    
    if git clone --depth 1 https://github.com/JaKooLit/GTK-themes-icons.git "$tmp_dir" 2>/dev/null; then
        cd "$tmp_dir"
        if [[ -f "auto-extract.sh" ]]; then
            chmod +x auto-extract.sh
            ./auto-extract.sh 2>/dev/null
            log "${OK} GTK themes extracted to ~/.themes and ~/.icons"
        else
            # Manual extraction if script not found
            for zip in *.tar.gz *.zip; do
                [[ -f "$zip" ]] && tar -xzf "$zip" -C "$HOME/.themes/" 2>/dev/null || unzip -q "$zip" -d "$HOME/.themes/" 2>/dev/null
            done
        fi
        cd - >/dev/null
    else
        log "${WARN} Could not clone JaKooLit GTK themes, trying Catppuccin directly..."
    fi
    rm -rf "$tmp_dir"
    
    # Method 2: Try AUR packages as fallback (some may fail, that's OK)
    for theme in "catppuccin-gtk-theme-mocha" "catppuccin-gtk-theme"; do
        if install_pkg "$theme" 2>/dev/null; then
            break
        fi
    done
    
    # Ensure we have at least Adwaita dark as fallback
    install_pkg "adwaita-dark" 2>/dev/null || true
}

#=============================================================================
# ICON THEMES  
#=============================================================================
install_icon_themes() {
    log "${INFO} Installing icon themes..."
    
    # Papirus is in official repos
    install_pkg "papirus-icon-theme"
    
    # Try to set folder color (optional)
    if command -v papirus-folders &>/dev/null; then
        papirus-folders -C cat-mocha-mauve --theme Papirus-Dark 2>/dev/null || true
    fi
    
    # Catppuccin Papirus folders (from GitHub)
    log "${INFO} Installing Catppuccin Papirus folders..."
    local tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$tmp_dir" 2>/dev/null; then
        if [[ -f "$tmp_dir/install.sh" ]]; then
            cd "$tmp_dir"
            chmod +x install.sh
            ./install.sh 2>/dev/null || true
            cd - >/dev/null
        fi
    fi
    rm -rf "$tmp_dir"
}

#=============================================================================
# CURSOR THEMES
#=============================================================================
install_cursor_themes() {
    log "${INFO} Installing cursor themes..."
    
    # Try different Bibata packages
    for cursor in "bibata-cursor-theme" "bibata-cursor-theme-bin" "bibata-modern-classic-bin"; do
        if install_pkg "$cursor" 2>/dev/null; then
            log "${OK} Cursor theme installed"
            return 0
        fi
    done
    
    # Fallback: Download Bibata directly from GitHub
    log "${INFO} Downloading Bibata cursor from GitHub..."
    local cursor_url="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.6/Bibata-Modern-Classic.tar.xz"
    local tmp_file=$(mktemp)
    
    if curl -fsSL -o "$tmp_file" "$cursor_url" 2>/dev/null; then
        tar -xf "$tmp_file" -C "$CURSORS_DIR/" 2>/dev/null
        log "${OK} Bibata cursor installed to ~/.icons"
    fi
    rm -f "$tmp_file"
}

#=============================================================================
# KVANTUM THEMES
#=============================================================================
install_kvantum_themes() {
    log "${INFO} Installing Kvantum themes..."
    
    # Install Catppuccin Kvantum theme
    local KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    
    # Clone Catppuccin Kvantum
    local tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/catppuccin/Kvantum.git "$tmp_dir" 2>/dev/null; then
        cp -r "$tmp_dir/src/"* "$KVANTUM_DIR/"
        log "${OK} Catppuccin Kvantum theme installed"
    fi
    rm -rf "$tmp_dir"
    
    # Set Kvantum theme
    cat > "$KVANTUM_DIR/kvantum.kvconfig" << 'EOF'
[General]
theme=Catppuccin-Mocha-Mauve
EOF
}

#=============================================================================
# CONFIGURE GTK
#=============================================================================
configure_gtk() {
    log "${INFO} Configuring GTK..."
    
    # GTK 2
    cat > "$HOME/.gtkrc-2.0" << 'EOF'
gtk-theme-name="Catppuccin-Mocha-Standard-Mauve-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Inter 11"
gtk-cursor-theme-name="Bibata-Modern-Classic"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
gtk-application-prefer-dark-theme=1
EOF
    
    # GTK 3 settings
    mkdir -p "$HOME/.config/gtk-3.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Inter 11
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF
    
    # GTK 4 settings
    mkdir -p "$HOME/.config/gtk-4.0"
    cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Inter 11
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
    
    log "${OK} GTK configured"
}

#=============================================================================
# MAIN
#=============================================================================
main() {
    install_gtk_themes
    install_icon_themes
    install_cursor_themes
    install_kvantum_themes
    configure_gtk
    
    log "${OK} Theme installation complete"
}

main
