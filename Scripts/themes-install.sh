#!/bin/bash
#=============================================================================
# THEME INSTALLATION - GTK, Qt, Icons, Cursors
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing themes..."

#=============================================================================
# GTK THEMES
#=============================================================================
install_gtk_themes() {
    log "${INFO} Installing GTK themes..."
    
    # Catppuccin GTK Theme
    if ! pkg_installed "catppuccin-gtk-theme-mocha"; then
        install_pkg "catppuccin-gtk-theme-mocha"
    fi
    
    # Additional themes
    install_pkg "arc-gtk-theme"
    install_pkg "materia-gtk-theme" || true
}

#=============================================================================
# ICON THEMES
#=============================================================================
install_icon_themes() {
    log "${INFO} Installing icon themes..."
    
    install_pkg "papirus-icon-theme"
    install_pkg "papirus-folders" || true
    
    # Set Papirus folder color to mauve
    if command -v papirus-folders &>/dev/null; then
        papirus-folders -C cat-mocha-mauve --theme Papirus-Dark 2>/dev/null || true
    fi
}

#=============================================================================
# CURSOR THEMES
#=============================================================================
install_cursor_themes() {
    log "${INFO} Installing cursor themes..."
    
    install_pkg "bibata-cursor-theme" || install_pkg "bibata-cursor-theme-bin"
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
