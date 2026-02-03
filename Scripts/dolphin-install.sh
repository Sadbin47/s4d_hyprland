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

# Configure Dolphin for Wayland
mkdir -p "$HOME/.config"

cat > "$HOME/.config/dolphinrc" << 'EOF'
[General]
BrowseThroughArchives=true
ConfirmClosingMultipleTabs=true
FilterBar=false
GlobalViewProps=true
RememberOpenedTabs=true
ShowFullPath=true
ShowFullPathInTitlebar=true
ShowZoomSlider=true
SortingChoice=CaseInsensitiveSorting
UseTabForSwitchingSplitView=false
Version=202
ViewPropsTimestamp=2024,1,1,0,0,0

[DetailsMode]
PreviewSize=22

[IconsMode]
PreviewSize=80

[KFileDialog Settings]
Places Icons Auto-resize=false
Places Icons Static Size=22

[PreviewSettings]
Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jaborathumbnail,kraborathumbnail,opendocumentthumbnail,gaborathumbnail,cursorthumbnail,windowsexethumbnail,windowsimagethumbnail,ffmpegthumbs,svgthumbnail,textthumbnail

[Search]
Location=Everywhere

[Toolbar mainToolBar]
ToolButtonStyle=IconOnly
EOF

log "${OK} Dolphin installed and configured"
