#!/bin/bash
#=============================================================================
# THEME INSTALLATION — GTK, Qt, Icons, Cursors
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing themes..."

mkdir -p "$HOME/.themes" "$HOME/.icons"

#=============================================================================
# GTK THEMES
#=============================================================================
install_gtk_themes() {
    log "${INFO} Installing GTK themes..."
    install_pkg "gtk-engine-murrine"
    install_pkg "unzip"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/JaKooLit/GTK-themes-icons.git "$tmp_dir" 2>/dev/null; then
        if [[ -f "$tmp_dir/auto-extract.sh" ]]; then
            chmod +x "$tmp_dir/auto-extract.sh"
            (cd "$tmp_dir" && ./auto-extract.sh 2>/dev/null) || true
            log "${OK} GTK themes extracted"
        fi
    else
        log "${INFO} Trying Catppuccin GTK from AUR..."
        install_pkg "catppuccin-gtk-theme-mocha" || install_pkg "catppuccin-gtk-theme" || true
    fi
    rm -rf "$tmp_dir"
}

#=============================================================================
# ICON THEMES
#=============================================================================
install_icon_themes() {
    log "${INFO} Installing icon themes..."
    install_pkg "papirus-icon-theme"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$tmp_dir" 2>/dev/null; then
        (cd "$tmp_dir" && chmod +x install.sh && ./install.sh 2>/dev/null) || true
    fi
    rm -rf "$tmp_dir"
}

#=============================================================================
# CURSOR THEMES
#=============================================================================
install_cursor_themes() {
    log "${INFO} Installing cursor themes..."
    for cursor in bibata-cursor-theme bibata-cursor-theme-bin bibata-modern-classic-bin; do
        if pkg_installed "$cursor" || install_pkg "$cursor"; then
            log "${OK} Cursor installed"
            return 0
        fi
    done

    # GitHub fallback
    local tmp_file
    tmp_file=$(mktemp)
    if curl -fsSL -o "$tmp_file" "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.6/Bibata-Modern-Classic.tar.xz" 2>/dev/null; then
        tar -xf "$tmp_file" -C "$HOME/.icons/" 2>/dev/null || true
        log "${OK} Bibata cursor installed"
    fi
    rm -f "$tmp_file"
}

#=============================================================================
# KVANTUM (Qt theming)
#=============================================================================
install_kvantum_themes() {
    log "${INFO} Installing Kvantum..."
    install_pkg "kvantum"
    install_pkg "qt5ct"
    install_pkg "qt6ct"

    local KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/catppuccin/Kvantum.git "$tmp_dir" 2>/dev/null; then
        [[ -d "$tmp_dir/themes" ]] && cp -r "$tmp_dir/themes/catppuccin-mocha-"* "$KVANTUM_DIR/" 2>/dev/null
    fi
    rm -rf "$tmp_dir"

    cat > "$KVANTUM_DIR/kvantum.kvconfig" << 'EOF'
[General]
theme=catppuccin-mocha-mauve
EOF

    # qt5ct config
    mkdir -p "$HOME/.config/qt5ct"
    cat > "$HOME/.config/qt5ct/qt5ct.conf" << 'EOF'
[Appearance]
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
general="Inter,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

    # qt6ct config
    mkdir -p "$HOME/.config/qt6ct"
    cat > "$HOME/.config/qt6ct/qt6ct.conf" << 'EOF'
[Appearance]
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

    log "${OK} Kvantum and Qt configured"
}

#=============================================================================
# CONFIGURE GTK
#=============================================================================
configure_gtk() {
    log "${INFO} Configuring GTK..."

    cat > "$HOME/.gtkrc-2.0" << 'EOF'
gtk-theme-name="Catppuccin-Mocha-Standard-Mauve-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Inter 11"
gtk-cursor-theme-name="Bibata-Modern-Classic"
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
EOF

    mkdir -p "$HOME/.config/gtk-3.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Inter 11
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF

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
# KDE APPS DARK MODE (for Dolphin etc.)
#=============================================================================
configure_kde_dark() {
    cat > "$HOME/.config/kdeglobals" << 'EOF'
[General]
ColorScheme=CatppuccinMochaMauve
Name=Catppuccin Mocha Mauve

[Colors:View]
BackgroundNormal=30,30,46
ForegroundNormal=205,214,244

[Colors:Window]
BackgroundNormal=24,24,37
ForegroundNormal=205,214,244

[Colors:Button]
BackgroundNormal=49,50,68
ForegroundNormal=205,214,244

[Colors:Selection]
BackgroundNormal=203,166,247
ForegroundNormal=17,17,27

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
widgetStyle=kvantum-dark

[Icons]
Theme=Papirus-Dark
EOF

    log "${OK} KDE dark mode configured"
}

#=============================================================================
# MAIN
#=============================================================================
install_gtk_themes
install_icon_themes
install_cursor_themes
install_kvantum_themes
configure_gtk
configure_kde_dark

log "${OK} Theme installation done"
