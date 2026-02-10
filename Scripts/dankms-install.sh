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
    
    # Install quickshell (required runtime dependency — prefer git for DMS compat)
    if ! pkg_installed "quickshell-git" && ! pkg_installed "quickshell"; then
        DMS_DEPS+=("quickshell-git")
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
    log "${INFO} Setting up DMS launch configuration..."

    # DMS is launched via exec-once in hyprland.conf, NOT via systemd user service.
    # Using both methods causes conflicts (double-launch, wallpaper races).
    # The exec-once method is more reliable and gives DMS direct access to
    # the Hyprland environment variables without needing dbus workarounds.

    # Disable any previously enabled systemd service to avoid conflicts
    systemctl --user stop dms.service 2>/dev/null || true
    systemctl --user disable dms.service 2>/dev/null || true
    log "${OK} DMS will launch via exec-once in hyprland.conf (no systemd service)"
}

#=============================================================================
# NOTE: Hyprland config (exec-once lines) is handled by
# dotfiles-apply.sh -> configure_status_bar() using the marker system.
# This script only installs DMS, it does NOT modify hyprland.conf.
#=============================================================================

#=============================================================================
# INSTALL DMS RUNTIME DEPENDENCIES
#=============================================================================
install_dms_dependencies() {
    log "${INFO} Installing DMS runtime dependencies..."

    # Quickshell (required - DMS UI engine)
    # DMS requires quickshell >= 0.3; the Arch 'quickshell' package (0.2.1) is too old.
    # Always prefer quickshell-git which builds the latest revision.
    if ! pkg_installed "quickshell-git" && ! pkg_installed "quickshell"; then
        log "${INFO} Installing quickshell-git (DMS needs >= 0.3)..."
        install_pkg "quickshell-git"
        # Final verification
        if pkg_installed "quickshell-git"; then
            log "${OK} quickshell-git installed"
        else
            log "${WARN} quickshell-git failed, trying quickshell as fallback..."
            install_pkg "quickshell"
            if pkg_installed "quickshell"; then
                log "${WARN} quickshell 0.2.1 installed — DMS may show version warnings. Consider building quickshell-git manually."
            else
                log "${WARN} quickshell could not be installed — DMS may not function properly"
            fi
        fi
    elif pkg_installed "quickshell" && ! pkg_installed "quickshell-git"; then
        # Upgrade from quickshell (0.2.1) to quickshell-git
        log "${WARN} quickshell 0.2.1 detected — upgrading to quickshell-git for DMS compatibility..."
        # Remove old quickshell first, then install git version
        sudo pacman -Rdd --noconfirm quickshell 2>/dev/null || true
        install_pkg "quickshell-git"
        if pkg_installed "quickshell-git"; then
            log "${OK} Upgraded to quickshell-git"
        else
            # Re-install old one if git version fails
            install_pkg "quickshell"
            log "${WARN} Could not upgrade quickshell — DMS may show version warnings"
        fi
    else
        log "${OK} quickshell already installed"
    fi

    # Matugen (required - dynamic color/theme generation from wallpaper)
    if ! command -v matugen &>/dev/null; then
        log "${INFO} Installing matugen..."
        install_pkg "matugen-bin"
        # Check if it actually installed; if not, try non-bin variant
        if ! command -v matugen &>/dev/null; then
            install_pkg "matugen"
        fi
        # Still not found? Try cargo install as last resort
        if ! command -v matugen &>/dev/null; then
            if command -v cargo &>/dev/null; then
                log "${INFO} Trying cargo install matugen..."
                cargo install matugen &>>"$LOG_FILE" || true
            elif command -v rustup &>/dev/null; then
                log "${INFO} Setting up rust toolchain for matugen..."
                rustup default stable &>>"$LOG_FILE" || true
                cargo install matugen &>>"$LOG_FILE" || true
            else
                # Install rust toolchain and try cargo
                log "${INFO} Installing rust toolchain for matugen..."
                install_pkg "rustup"
                if command -v rustup &>/dev/null; then
                    rustup default stable &>>"$LOG_FILE" || true
                    cargo install matugen &>>"$LOG_FILE" || true
                fi
            fi
        fi
        # Final verification
        if command -v matugen &>/dev/null; then
            log "${OK} matugen installed"
        else
            log "${WARN} matugen could not be installed — DMS theme generation will not work"
        fi
    else
        log "${OK} matugen already installed"
    fi

    # Cava (audio visualizer widget in DMS panel - optional)
    if ! command -v cava &>/dev/null; then
        log "${INFO} Installing cava..."
        install_pkg "cava"
    else
        log "${OK} cava already installed"
    fi

    # Power-profiles-daemon (power management integration)
    if ! pkg_installed "power-profiles-daemon"; then
        log "${INFO} Installing power-profiles-daemon..."
        install_pkg "power-profiles-daemon"
    else
        log "${OK} power-profiles-daemon already installed"
    fi
    # Enable the service regardless (may already be installed but not running)
    sudo systemctl enable power-profiles-daemon.service 2>/dev/null || true
    sudo systemctl start power-profiles-daemon.service 2>/dev/null || true

    log "${OK} DMS runtime dependencies installed"
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

# Install runtime dependencies (quickshell, matugen, cava, power-profiles-daemon)
install_dms_dependencies

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
