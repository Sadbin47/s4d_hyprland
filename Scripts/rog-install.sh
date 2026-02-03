#!/bin/bash
#=============================================================================
# ASUS ROG LAPTOP SUPPORT
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing ASUS ROG laptop support..."

# Add ASUS Linux repository
setup_asus_repo() {
    log "${INFO} Setting up ASUS Linux (g14) repository..."
    
    # Remove any existing g14 entry to start fresh
    if grep -q "\[g14\]" /etc/pacman.conf; then
        log "${INFO} Removing existing [g14] entry to reconfigure..."
        sudo sed -i '/\[g14\]/,/^$/d' /etc/pacman.conf
    fi
    
    # Add repository with signature bypass (ASUS repo is trusted)
    log "${INFO} Adding [g14] repository (skipping GPG verification)..."
    cat << 'EOF' | sudo tee -a /etc/pacman.conf >/dev/null

[g14]
SigLevel = Never
Server = https://arch.asus-linux.org
EOF
    
    # Update package database
    log "${INFO} Updating package database..."
    sudo pacman -Syy --noconfirm
    log "${OK} [g14] repository configured"
}

# Setup repository
setup_asus_repo

# Install ASUS packages
ROG_PACKAGES=(
    "asusctl"
    "supergfxctl"
    "rog-control-center"
    "power-profiles-daemon"
)

for pkg in "${ROG_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Enable services (some may fail if not on actual ROG hardware - that's OK)
log "${INFO} Enabling ROG services..."

if sudo systemctl enable power-profiles-daemon 2>/dev/null; then
    sudo systemctl start power-profiles-daemon 2>/dev/null || true
    log "${OK} power-profiles-daemon enabled"
fi

if sudo systemctl enable supergfxd 2>/dev/null; then
    sudo systemctl start supergfxd 2>/dev/null || true
    log "${OK} supergfxd enabled"
fi

# asusd may fail to start if not on actual ASUS hardware - enable but don't start
if sudo systemctl enable asusd 2>/dev/null; then
    log "${OK} asusd enabled (will start on reboot)"
else
    log "${INFO} asusd will be available after reboot on ASUS hardware"
fi

log "${INFO} Note: ROG services will fully work after reboot on actual ASUS ROG hardware"

# Create keybindings for ROG laptop in Hyprland
mkdir -p "$HOME/.config/hypr"

cat > "$HOME/.config/hypr/rog.conf" << 'EOF'
# ASUS ROG Laptop Keybindings
# Include this in your hyprland.conf with: source = ./rog.conf

# ROG Key - Open ROG Control Center
bind = , XF86Launch1, exec, rog-control-center

# Fan Profile Cycling
bind = , XF86Launch4, exec, asusctl profile -n

# Screen brightness with ROG keys
bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Keyboard backlight (if supported)
bind = , XF86KbdBrightnessUp, exec, asusctl -n
bind = , XF86KbdBrightnessDown, exec, asusctl -p

# Toggle Aura lighting
bind = SUPER, F5, exec, asusctl led-mode -n
EOF

log "${OK} ROG configuration file created: ~/.config/hypr/rog.conf"
log "${INFO} Add 'source = ./rog.conf' to your hyprland.conf to enable ROG keybindings"

log "${OK} ASUS ROG support installed successfully"
