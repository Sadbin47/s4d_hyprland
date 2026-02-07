#!/bin/bash
#=============================================================================
# FONT INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing fonts..."

NERD_FONTS=(
    "ttf-jetbrains-mono-nerd"
    "ttf-firacode-nerd"
    "ttf-cascadia-code-nerd"
    "ttf-hack-nerd"
)

SYSTEM_FONTS=(
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "ttf-liberation"
    "ttf-dejavu"
    "ttf-roboto"
    "inter-font"
)

ICON_FONTS=(
    "ttf-font-awesome"
    "otf-font-awesome"
    "ttf-material-design-icons-extended"
)

for font in "${NERD_FONTS[@]}" "${SYSTEM_FONTS[@]}" "${ICON_FONTS[@]}"; do
    install_pkg "$font"
done

fc-cache -fv &>/dev/null || true

mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
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
    <match target="font">
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
        <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    </match>
</fontconfig>
EOF

log "${OK} Fonts installed"
