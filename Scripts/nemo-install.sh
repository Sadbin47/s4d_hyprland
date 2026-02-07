#!/bin/bash
#=============================================================================
# NEMO FILE MANAGER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Nemo file manager..."

# Core package (required)
install_pkg "nemo"

# Optional extras - don't fail if unavailable
for pkg in "nemo-fileroller" "file-roller"; do
    install_pkg "$pkg" || log "${WARN} $pkg not available - skipping (non-essential)"
done

# Set Nemo as default file manager
xdg-mime default nemo.desktop inode/directory 2>/dev/null || true

# Configure Nemo
mkdir -p "$HOME/.config/nemo"

# Create basic nemo config if it doesn't exist
if [[ ! -f "$HOME/.config/nemo/nemo-preferences.xml" ]]; then
    cat > "$HOME/.config/nemo/nemo-preferences.xml" << 'EOF'
<?xml version="1.0"?>
<nemo-preferences>
  <preferences>
    <show-hidden-files>false</show-hidden-files>
    <default-folder-viewer>icon-view</default-folder-viewer>
    <show-location-entry>true</show-location-entry>
  </preferences>
</nemo-preferences>
EOF
    log "${OK} Nemo preferences file created"
fi

log "${OK} Nemo installed and configured"

