#!/bin/bash
#=============================================================================
# ASUS ROG LAPTOP SUPPORT
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing ASUS ROG laptop support..."

# Add ASUS Linux repository
setup_asus_repo() {
    log "${INFO} Setting up ASUS Linux (g14) repository..."
    
    # Check if repo already exists and working
    if grep -q "\[g14\]" /etc/pacman.conf; then
        log "${INFO} [g14] repository already exists, testing..."
        if sudo pacman -Sy g14 2>/dev/null; then
            log "${OK} [g14] repository is working"
            return 0
        else
            log "${WARN} [g14] repository exists but has issues, fixing..."
        fi
    fi
    
    # Method 1: Download key directly from asus-linux.org (most reliable)
    log "${INFO} Downloading GPG key from asus-linux.org..."
    local key_imported=false
    
    if curl -fsSL -o /tmp/asus-linux.gpg https://asus-linux.org/key.gpg 2>/dev/null; then
        if sudo pacman-key --add /tmp/asus-linux.gpg 2>/dev/null; then
            sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null
            key_imported=true
            log "${OK} GPG key imported from asus-linux.org"
            rm -f /tmp/asus-linux.gpg
        fi
    fi
    
    # Method 2: Try keyserver.ubuntu.com (fallback)
    if [[ "$key_imported" == false ]]; then
        log "${INFO} Trying keyserver.ubuntu.com..."
        if sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null; then
            sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null
            key_imported=true
            log "${OK} GPG key imported from keyserver.ubuntu.com"
        fi
    fi
    
    # Method 3: Try default keyserver
    if [[ "$key_imported" == false ]]; then
        log "${INFO} Trying default keyserver..."
        if sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null; then
            sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 2>/dev/null
            key_imported=true
        fi
    fi
    
    if [[ "$key_imported" == false ]]; then
        log "${WARN} Could not import GPG key automatically"
        log "${INFO} You may need to manually run:"
        log "${INFO}   curl -O https://asus-linux.org/key.gpg && sudo pacman-key --add key.gpg"
        log "${INFO}   sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
    fi
    
    # Add repository if not present
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        log "${INFO} Adding [g14] repository to pacman.conf..."
        cat << 'EOF' | sudo tee -a /etc/pacman.conf >/dev/null

[g14]
Server = https://arch.asus-linux.org
EOF
    fi
    
    # Update package database
    log "${INFO} Updating package database..."
    sudo pacman -Syy
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
