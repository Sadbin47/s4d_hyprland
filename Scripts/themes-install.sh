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

    # Adwaita-dark ships with GTK3/4 — no external theme needed
    # Install gnome-themes-extra for Adwaita-dark GTK2 support
    install_pkg "gnome-themes-extra" || true

    log "${OK} GTK themes ready (using Adwaita-dark)"
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

    # ── S4D Dark theme: Pure black/white transparent Kvantum theme ──
    # No Catppuccin — clean monochrome aesthetic
    local S4D_THEME_DIR="$KVANTUM_DIR/s4d-dark"
    mkdir -p "$S4D_THEME_DIR"

    cat > "$S4D_THEME_DIR/s4d-dark.kvconfig" << 'THEMEEOF'
[%General]
author=s4d
comment=Pure black & white transparent theme for s4d Hyprland
x11drag=all
alt_mnemonic=true
left_tabs=true
attach_active_tab=false
mirror_doc_tabs=true
group_toolbar_buttons=false
toolbar_item_spacing=0
toolbar_interior_spacing=2
spread_progressbar=true
composite=true
menu_shadow_depth=7
spread_menuitems=true
tooltip_shadow_depth=0
splitter_width=1
scroll_width=9
scroll_arrows=false
scroll_min_extent=36
slider_width=2
slider_handle_width=22
slider_handle_length=22
tickless_slider_handle_size=22
center_toolbar_handle=true
check_size=16
textless_progressbar=false
menubar_mouse_tracking=true
slim_toolbars=false
toolbutton_style=1
translucent_windows=false
blurring=true
popup_blurring=true
vertical_spin_indicators=false
spin_button_width=16
fill_rubberband=false
merge_menubar_with_toolbar=false
small_icon_size=16
large_icon_size=32
button_icon_size=16
toolbar_icon_size=22
combo_as_lineedit=true
animate_states=true
button_contents_shift=false
combo_menu=true
hide_combo_checkboxes=false
combo_focus_rect=false
scrollbar_in_view=false
transient_scrollbar=true
transient_groove=true
layout_spacing=2
layout_margin=4
no_window_pattern=false
opaque=
reduce_window_opacity=0
reduce_menu_opacity=20
respect_DE=true
scrollable_menu=true
submenu_overlap=0
submenu_delay=250
tree_branch_line=true
no_inactiveness=false
click_behavior=0
contrast=1.00
dialog_button_layout=0
intensity=1.00
saturation=1.00
shadowless_popup=false
drag_from_buttons=false
menu_blur_radius=4
tooltip_delay=-1
THEMEEOF

    cat >> "$S4D_THEME_DIR/s4d-dark.kvconfig" << 'HACKSEOF'

[Hacks]
transparent_dolphin_view=true
blur_konsole=true
transparent_ktitle_label=true
transparent_menutitle=true
respect_darkness=true
kcapacitybar_as_progressbar=true
iconless_pushbutton=false
iconless_menu=false
disabled_icon_opacity=70
normal_default_pushbutton=true
transparent_pcmanfm_sidepane=true
transparent_pcmanfm_view=true
blur_translucent=true
tint_on_mouseover=0
middle_click_scroll=false
no_selection_tint=false
transparent_arrow_button=true
lxqtmainmenu_iconsize=22
HACKSEOF

    # Create a minimal SVG for the theme (required by Kvantum)
    cat > "$S4D_THEME_DIR/s4d-dark.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="640">
  <defs>
    <linearGradient id="pointed" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" style="stop-color:#1a1a1a;stop-opacity:1"/>
      <stop offset="1" style="stop-color:#0d0d0d;stop-opacity:1"/>
    </linearGradient>
  </defs>
  <!-- Window interior -->
  <rect id="WindowInterior" x="0" y="0" width="100" height="100" rx="0" ry="0"
        style="fill:#0a0a0a;fill-opacity:0.85"/>
  <!-- Generic frame -->
  <rect id="GenericFrame" x="0" y="100" width="100" height="100" rx="0" ry="0"
        style="fill:#0a0a0a;fill-opacity:0.9;stroke:#2a2a2a;stroke-width:1"/>
</svg>
SVGEOF

    # Set s4d-dark as the active Kvantum theme
    cat > "$KVANTUM_DIR/kvantum.kvconfig" << 'EOF'
[General]
theme=s4d-dark
translucent_windows=false
blurring=true
composite=true
reduce_window_opacity=0
reduce_menu_opacity=10
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
gtk-theme-name="Adwaita-dark"
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
gtk-theme-name=Adwaita-dark
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
gtk-theme-name=Adwaita-dark
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
ColorScheme=S4DDark
Name=S4D Dark
fixed=JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
font=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
menuFont=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
smallestReadableFont=Inter,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
toolBarFont=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[Colors:View]
BackgroundNormal=10,10,10
BackgroundAlternate=18,18,18
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Window]
BackgroundNormal=8,8,8
BackgroundAlternate=15,15,15
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Button]
BackgroundNormal=25,25,25
BackgroundAlternate=35,35,35
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Selection]
BackgroundNormal=255,255,255
BackgroundAlternate=200,200,200
ForegroundNormal=0,0,0
ForegroundInactive=30,30,30
ForegroundActive=0,0,0
ForegroundLink=0,0,0
ForegroundVisited=40,40,40
ForegroundNegative=200,0,0
ForegroundNeutral=180,150,0
ForegroundPositive=0,150,0
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Tooltip]
BackgroundNormal=15,15,15
BackgroundAlternate=20,20,20
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Complementary]
BackgroundNormal=5,5,5
BackgroundAlternate=12,12,12
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[Colors:Header]
BackgroundNormal=12,12,12
BackgroundAlternate=18,18,18
ForegroundNormal=230,230,230
ForegroundInactive=140,140,140
ForegroundActive=255,255,255
ForegroundLink=180,180,180
ForegroundVisited=120,120,120
ForegroundNegative=255,85,85
ForegroundNeutral=255,200,60
ForegroundPositive=85,255,85
DecorationFocus=255,255,255
DecorationHover=200,200,200

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
widgetStyle=kvantum-dark
contrast=7

[Icons]
Theme=Papirus-Dark

[WM]
activeBackground=10,10,10
activeForeground=230,230,230
inactiveBackground=5,5,5
inactiveForeground=140,140,140
activeBlend=255,255,255
inactiveBlend=40,40,40
frame=5,5,5
EOF

    log "${OK} KDE dark mode configured (pure black & white)"
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
