#!/bin/bash
#=============================================================================
# NEMO FILE MANAGER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Nemo file manager..."

NEMO_PACKAGES=(
    "nemo"
    "nemo-fileroller"         # Archive integration
    "nemo-preview"            # Quick preview
    "file-roller"             # Archive manager
)

for pkg in "${NEMO_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Set Nemo as default file manager
xdg-mime default nemo.desktop inode/directory 2>/dev/null || true

# Configure Nemo
mkdir -p "$HOME/.config/nemo"

# Set basic Nemo preferences via dconf (if available)
if command -v dconf &>/dev/null; then
    dconf write /org/nemo/preferences/show-hidden-files false
    dconf write /org/nemo/preferences/default-folder-viewer "'icon-view'"
    dconf write /org/nemo/preferences/show-location-entry true
fi

log "${OK} Nemo installed and configured"
