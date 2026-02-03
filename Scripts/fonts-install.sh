#!/bin/bash
#=============================================================================
# FONT INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing fonts..."

# Core Nerd Fonts
NERD_FONTS=(
    "ttf-jetbrains-mono-nerd"
    "ttf-firacode-nerd"
    "ttf-cascadia-code-nerd"
    "ttf-hack-nerd"
    "ttf-iosevka-nerd"
    "ttf-meslo-nerd"
    "ttf-sourcecodepro-nerd"
)

# System Fonts
SYSTEM_FONTS=(
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "ttf-liberation"
    "ttf-dejavu"
    "ttf-roboto"
    "ttf-ubuntu-font-family"
    "inter-font"
    "adobe-source-sans-fonts"
    "adobe-source-serif-fonts"
    "adobe-source-code-pro-fonts"
)

# Icon Fonts
ICON_FONTS=(
    "ttf-font-awesome"
    "otf-font-awesome"
    "ttf-material-design-icons-extended"
)

log "${INFO} Installing Nerd Fonts..."
for font in "${NERD_FONTS[@]}"; do
    install_pkg "$font"
done

log "${INFO} Installing System Fonts..."
for font in "${SYSTEM_FONTS[@]}"; do
    install_pkg "$font"
done

log "${INFO} Installing Icon Fonts..."
for font in "${ICON_FONTS[@]}"; do
    install_pkg "$font"
done

# Refresh font cache
log "${INFO} Refreshing font cache..."
fc-cache -fv &>/dev/null

# Set default fonts for better rendering
mkdir -p "$HOME/.config/fontconfig"

cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- Default font families -->
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Inter</family>
            <family>Noto Sans</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    <alias>
        <family>monospace</family>
        <prefer>
            <family>JetBrainsMono Nerd Font</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    
    <!-- Enable subpixel rendering -->
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
        <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
        </edit>
    </match>
</fontconfig>
EOF

log "${OK} Font configuration created"
log "${OK} Fonts installed successfully"
