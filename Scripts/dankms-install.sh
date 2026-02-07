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

[Service]
Type=simple
ExecStart=/usr/bin/dms run
ExecReload=/usr/bin/pkill -USR1 -x dms
Restart=on-failure
RestartSec=2
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
# NOTE: Hyprland config (exec-once lines) is handled by
# dotfiles-apply.sh -> configure_status_bar() using the marker system.
# This script only installs DMS, it does NOT modify hyprland.conf.
#=============================================================================

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
