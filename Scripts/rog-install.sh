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

# Enable services
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now supergfxd
sudo systemctl enable --now asusd

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
