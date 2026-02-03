#!/bin/bash
#=============================================================================
# SDDM INSTALLATION & CONFIGURATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing SDDM display manager..."

# Install SDDM packages
SDDM_PACKAGES=(
    "sddm"
    "qt5-quickcontrols"
    "qt5-quickcontrols2"
    "qt5-graphicaleffects"
)

for pkg in "${SDDM_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Create SDDM configuration directory
sudo mkdir -p /etc/sddm.conf.d

# Configure SDDM for Wayland
cat << 'EOF' | sudo tee /etc/sddm.conf.d/10-wayland.conf >/dev/null
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
EOF

log "${OK} SDDM Wayland configuration created"

# Install a theme (optional)
if confirm "Install a modern SDDM theme?" "y"; then
    log "${INFO} Installing SDDM theme..."
    
    # Install sddm-sugar-candy theme from AUR
    if install_pkg "sddm-sugar-candy-git"; then
        cat << 'EOF' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
[Theme]
Current=sugar-candy
EOF
        log "${OK} SDDM theme configured"
    else
        # Fallback to breeze
        install_pkg "sddm-kcm" || true
    fi
fi

# Enable SDDM service
sudo systemctl enable sddm
log "${OK} SDDM enabled and configured"
