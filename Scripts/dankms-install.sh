#!/bin/bash
#=============================================================================
# DANK MATERIAL SHELL (DMS) INSTALLATION
# Installs DankMaterialShell - complete desktop shell for Hyprland
# Reference: https://github.com/AvengeMedia/DankMaterialShell
# Replaces: waybar, swayidle, mako, polkit, etc.
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing DankMaterialShell..."

#=============================================================================
# INSTALL DMS FROM AUR (RECOMMENDED)
#=============================================================================
install_dms_aur() {
    log "${INFO} Installing DMS from AUR..."
    
    # Check for dms-shell-bin (prebuilt binary - faster)
    if pkg_installed "dms-shell-bin" || pkg_installed "dms-shell-git" || pkg_installed "dms-shell"; then
        log "${OK} DMS is already installed"
        return 0
    fi
    
    # Try binary package first (faster)
    if yay -Si dms-shell-bin &>/dev/null 2>&1; then
        log "${INFO} Installing dms-shell-bin (prebuilt binary)..."
        install_pkg "dms-shell-bin"
        return 0
    fi
    
    # Fall back to git version (compiles from source)
    log "${WARN} Installing dms-shell-git from AUR (this may take 15-30 minutes to compile)..."
    install_pkg "dms-shell-git"
}

#=============================================================================
# INSTALL DMS FROM SOURCE (FALLBACK)
#=============================================================================
install_dms_source() {
    log "${INFO} Installing DMS from source..."
    
    # Install build dependencies
    DMS_DEPS=(
        "qt6-base"
        "qt6-declarative"
        "qt6-wayland"
        "qt6-svg"
        "qt6-shadertools"
        "qt6-imageformats"
        "pipewire"
        "libpulse"
        "pam"
        "wayland"
        "wayland-protocols"
        "jq"
        "cmake"
        "ninja"
        "go"
        "git"
        "brightnessctl"
        "networkmanager"
        "bluez"
        "bluez-utils"
    )
    
    # Install quickshell (required runtime dependency)
    if ! pkg_installed "quickshell-git" && ! pkg_installed "quickshell"; then
        if yay -Si quickshell &>/dev/null 2>&1; then
            DMS_DEPS+=("quickshell")
        else
            DMS_DEPS+=("quickshell-git")
        fi
    fi
    
    log "${INFO} Installing build dependencies..."
    for pkg in "${DMS_DEPS[@]}"; do
        install_pkg "$pkg"
    done
    
    # Clone DankMaterialShell
    DMS_DIR="$HOME/.local/share/dms-source"
    
    if [[ -d "$DMS_DIR" ]]; then
        log "${INFO} DankMaterialShell exists, updating..."
        cd "$DMS_DIR"
        git pull --ff-only 2>/dev/null || {
            log "${WARN} Update failed, re-cloning..."
            cd "$HOME"
            rm -rf "$DMS_DIR"
            git clone --depth 1 https://github.com/AvengeMedia/DankMaterialShell.git "$DMS_DIR"
        }
    else
        log "${INFO} Cloning DankMaterialShell..."
        git clone --depth 1 https://github.com/AvengeMedia/DankMaterialShell.git "$DMS_DIR"
    fi
    
    # Build and install using Makefile
    log "${INFO} Building and installing DMS..."
    cd "$DMS_DIR"
    
    if make build; then
        log "${OK} DMS built successfully"
        log "${INFO} Installing DMS (requires sudo)..."
        sudo make install
        log "${OK} DMS installed to /usr/local/bin/dms"
    else
        log "${ERROR} DMS build failed"
        return 1
    fi
}

#=============================================================================
# SETUP DMS SYSTEMD SERVICE
#=============================================================================
setup_dms_service() {
    log "${INFO} Setting up DMS systemd user service..."
    
    mkdir -p "$HOME/.config/systemd/user"
    
    # Create DMS service file
    cat > "$HOME/.config/systemd/user/dms.service" << 'EOF'
[Unit]
Description=Dank Material Shell (DMS)
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
Type=dbus
BusName=org.freedesktop.Notifications
ExecStart=/usr/bin/dms run --session
ExecReload=/usr/bin/pkill -USR1 -x dms
Restart=on-failure
RestartSec=1.23
TimeoutStopSec=10

[Install]
WantedBy=graphical-session.target
EOF

    # Adjust path if installed to /usr/local/bin
    if [[ -x /usr/local/bin/dms ]] && [[ ! -x /usr/bin/dms ]]; then
        sed -i 's|/usr/bin/dms|/usr/local/bin/dms|g' "$HOME/.config/systemd/user/dms.service"
    fi
    
    # Reload and enable the service
    systemctl --user daemon-reload
    systemctl --user enable dms.service
    
    log "${OK} DMS systemd service enabled"
}

#=============================================================================
# UPDATE HYPRLAND CONFIG
#=============================================================================
update_hyprland_config() {
    HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
    
    if [[ ! -f "$HYPR_CONF" ]]; then
        log "${WARN} Hyprland config not found at $HYPR_CONF"
        return
    fi
    
    log "${INFO} Updating Hyprland configuration for DMS..."
    
    # Comment out waybar if present (DMS replaces it)
    if grep -q "^exec-once = waybar" "$HYPR_CONF"; then
        sed -i 's/^exec-once = waybar/# exec-once = waybar  # Disabled - using DMS/' "$HYPR_CONF"
        log "${INFO} Commented out waybar (DMS replaces it)"
    fi
    
    # Comment out swaync if present (DMS replaces notifications)
    if grep -q "^exec-once = swaync" "$HYPR_CONF"; then
        sed -i 's/^exec-once = swaync/# exec-once = swaync  # Disabled - using DMS/' "$HYPR_CONF"
        log "${INFO} Commented out swaync (DMS replaces it)"
    fi
    
    # Comment out hypridle if present (DMS has session management)
    if grep -q "^exec-once = hypridle" "$HYPR_CONF"; then
        sed -i 's/^exec-once = hypridle/# exec-once = hypridle  # Disabled - using DMS/' "$HYPR_CONF"
        log "${INFO} Commented out hypridle (DMS replaces it)"
    fi
    
    # Comment out polkit agent if present (DMS has built-in polkit)
    if grep -q "^exec-once = /usr/lib/polkit" "$HYPR_CONF"; then
        sed -i 's|^exec-once = /usr/lib/polkit|# exec-once = /usr/lib/polkit|' "$HYPR_CONF"
        log "${INFO} Commented out polkit agent (DMS replaces it)"
    fi
    
    # Remove any old quickshell entries
    sed -i '/^exec-once = quickshell/d' "$HYPR_CONF"
    sed -i '/^# DankMaterialShell bar/d' "$HYPR_CONF"
    
    # Add DMS autostart using dms run
    if ! grep -q "dms run" "$HYPR_CONF"; then
        cat >> "$HYPR_CONF" << 'EOF'

# DankMaterialShell - Complete desktop shell
# Replaces: waybar, swaync, hypridle, polkit-agent
exec-once = dms run
EOF
        log "${OK} Added DMS to Hyprland autostart"
    fi
}

#=============================================================================
# MAIN INSTALLATION
#=============================================================================

# Try AUR first (recommended and faster)
if command -v yay &>/dev/null || command -v paru &>/dev/null; then
    install_dms_aur
else
    log "${WARN} No AUR helper found, installing from source..."
    install_dms_source
fi

# Verify dms is installed
if ! command -v dms &>/dev/null; then
    # Check if installed to /usr/local/bin
    if [[ -x /usr/local/bin/dms ]]; then
        export PATH="/usr/local/bin:$PATH"
    else
        log "${ERROR} DMS installation failed - dms command not found"
        exit 1
    fi
fi

# Setup systemd service for proper session integration
setup_dms_service

# Update Hyprland config
update_hyprland_config

log "${OK} DankMaterialShell installation complete!"
log ""
log "${INFO} DMS replaces these applications:"
log "         - waybar (status bar)"
log "         - swaync/mako (notifications)"
log "         - hypridle/swayidle (idle management)"
log "         - polkit-gnome (authentication)"
log "         - fuzzel/rofi (launcher - use Super key)"
log ""
log "${INFO} Start DMS manually: dms run"
log "${INFO} DMS will auto-start on next Hyprland session"
log "${INFO} IPC commands: dms ipc call spotlight toggle"
