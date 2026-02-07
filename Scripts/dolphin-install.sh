#!/bin/bash
#=============================================================================
# DOLPHIN FILE MANAGER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Dolphin file manager..."

DOLPHIN_PACKAGES=(
    "dolphin"
    "ark"                     # Archive manager
    "kde-cli-tools"           # KDE utilities
    "ffmpegthumbs"            # Video thumbnails
    "kdegraphics-thumbnailers" # Image thumbnails
    "qt5-imageformats"        # Image format support
    "kimageformats5"          # Additional image formats
    "kio-extras"              # Extra KIO plugins
)

for pkg in "${DOLPHIN_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Only create minimal Dolphin config if none exists
# This respects any existing dotfiles configuration
mkdir -p "$HOME/.config"

if [[ ! -f "$HOME/.config/dolphinrc" ]]; then
    log "${INFO} Creating minimal Dolphin config (preserves theme from dotfiles)"
    
    cat > "$HOME/.config/dolphinrc" << 'EOF'
[General]
BrowseThroughArchives=true
ConfirmClosingMultipleTabs=true
ShowFullPath=true
ShowZoomSlider=true
Version=202

[Search]
Location=Everywhere
EOF
else
    log "${OK} Dolphin config already exists - preserving your dotfiles settings"
fi

log "${OK} Dolphin installed and configured"

