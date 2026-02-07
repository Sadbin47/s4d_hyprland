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
    log "${INFO} Installing Kvantum and Qt configuration tools..."
    
    # Install Kvantum and Qt config tools
    install_pkg "kvantum"
    install_pkg "qt5ct"
    install_pkg "qt6ct"
    
    # Install Catppuccin Kvantum theme
    local KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    
    # Clone Catppuccin Kvantum (themes are in themes/ folder, not src/)
    local tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/catppuccin/Kvantum.git "$tmp_dir" 2>/dev/null; then
        # Copy all Mocha variant themes (mocha is the darkest/best for dark mode)
        if [[ -d "$tmp_dir/themes" ]]; then
            cp -r "$tmp_dir/themes/catppuccin-mocha-"* "$KVANTUM_DIR/" 2>/dev/null
            log "${OK} Catppuccin Kvantum Mocha themes installed"
        else
            log "${WARN} Kvantum themes folder not found in repo"
        fi
    else
        log "${WARN} Could not clone Catppuccin Kvantum repo"
    fi
    rm -rf "$tmp_dir"
    
    # Set Kvantum theme to catppuccin-mocha-mauve (lowercase as per repo)
    cat > "$KVANTUM_DIR/kvantum.kvconfig" << 'EOF'
[General]
theme=catppuccin-mocha-mauve
EOF
    
    # Configure qt5ct
    mkdir -p "$HOME/.config/qt5ct"
    cat > "$HOME/.config/qt5ct/qt5ct.conf" << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/Catppuccin-Mocha.conf
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
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF
    
    # Configure qt6ct
    mkdir -p "$HOME/.config/qt6ct"
    cat > "$HOME/.config/qt6ct/qt6ct.conf" << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/Catppuccin-Mocha.conf
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
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF
    
    log "${OK} Kvantum and Qt configuration complete"
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
# CONFIGURE KDE/DOLPHIN DARK MODE
#=============================================================================
configure_kde_dark() {
    log "${INFO} Configuring KDE apps dark mode (Dolphin, etc.)..."
    
    # Create kdeglobals for KDE apps (Dolphin uses this)
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

[Colors:Tooltip]
BackgroundNormal=49,50,68
ForegroundNormal=205,214,244

[Colors:Complementary]
BackgroundNormal=24,24,37
ForegroundNormal=205,214,244

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
widgetStyle=kvantum-dark
colorScheme=CatppuccinMochaMauve

[Icons]
Theme=Papirus-Dark
EOF

    # Install Catppuccin color scheme files for qt5ct/qt6ct
    # These are needed for color_scheme_path in qt5ct/qt6ct.conf
    for qt_dir in /usr/share/qt5ct/colors /usr/share/qt6ct/colors; do
        if [[ -d "$(dirname "$qt_dir")" ]] && [[ ! -f "$qt_dir/Catppuccin-Mocha.conf" ]]; then
            sudo mkdir -p "$qt_dir"
            sudo tee "$qt_dir/Catppuccin-Mocha.conf" > /dev/null << 'COLOREOF'
[ColorScheme]
active_colors=#ffcdd6f4, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff313244, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff585b70, #ffcba6f7, #ff11111b, #ff89b4fa, #ffcba6f7, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
inactive_colors=#ffcdd6f4, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff313244, #ff6c7086, #ffcdd6f4, #ff6c7086, #ff1e1e2e, #ff181825, #ff585b70, #ff313244, #ff6c7086, #ff89b4fa, #ffcba6f7, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
disabled_colors=#ff6c7086, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff313244, #ff6c7086, #ff6c7086, #ff6c7086, #ff1e1e2e, #ff1e1e2e, #ff585b70, #ff181825, #ff6c7086, #ff89b4fa, #ffcba6f7, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
COLOREOF
            log "${OK} Catppuccin color scheme installed for $(basename $(dirname "$qt_dir"))"
        fi
    done

    log "${OK} KDE dark mode configured"
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
    configure_kde_dark
    
    log "${OK} Theme installation complete"
}

main
