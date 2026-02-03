#!/bin/bash
#=============================================================================
# ASUS ROG LAPTOP SUPPORT
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing ASUS ROG laptop support..."

# Add ASUS Linux repository
setup_asus_repo() {
    log "${INFO} Setting up ASUS Linux (g14) repository..."
    
    # Import GPG key
    sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null
    sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null
    
    # Add repository if not present
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        log "${INFO} Adding [g14] repository to pacman.conf..."
        echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a /etc/pacman.conf >/dev/null
    else
        log "${INFO} [g14] repository already exists"
    fi
    
    # Update package database
    sudo pacman -Syy
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
