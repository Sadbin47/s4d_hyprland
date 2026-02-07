#!/bin/bash
#=============================================================================
# SDDM INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing SDDM..."

for pkg in sddm qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects; do
    install_pkg "$pkg"
done

sudo mkdir -p /etc/sddm.conf.d

cat << 'EOF' | sudo tee /etc/sddm.conf.d/10-wayland.conf >/dev/null
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
EOF

log "${OK} SDDM configured"

# Try to install a theme (non-interactive)
if install_pkg "sddm-sugar-candy-git" 2>/dev/null; then
    cat << 'EOF' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
[Theme]
Current=sugar-candy
EOF
    log "${OK} SDDM theme installed"
fi

sudo systemctl enable sddm 2>/dev/null || true
log "${OK} SDDM enabled"
