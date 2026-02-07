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
    log "${INFO} Creating clean Dolphin config..."

    cat > "$HOME/.config/dolphinrc" << 'EOF'
[General]
BrowseThroughArchives=true
ConfirmClosingMultipleTabs=true
ShowFullPath=true
ShowFullPathInTitlebar=true
ShowZoomSlider=false
Version=202
GlobalViewProps=true
RememberOpenedTabs=true

[MainWindow]
MenuBar=Disabled
ToolBarsMovable=Disabled

[PreviewsTab]
Plugins=directorythumbnail,imagethumbnail,jpegthumbnail,ffmpegthumbs

[DetailsMode]
ExpandableFolders=false
PreviewSize=22

[CompactMode]
PreviewSize=32

[IconsMode]
PreviewSize=80

[PlacesPanel]
IconSize=22

[Search]
Location=Everywhere

[VersionControl]
enabledPlugins=Git
EOF

    # Dolphin state — start in Details view with a clean layout
    mkdir -p "$HOME/.local/share/dolphin"
    cat > "$HOME/.config/dolphinstaterc" << 'EOF'
[State]
firstRun=false
EOF

else
    log "${OK} Dolphin config already exists - preserving your dotfiles settings"
fi

log "${OK} Dolphin installed and configured"

