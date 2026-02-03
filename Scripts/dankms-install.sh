#!/bin/bash
#=============================================================================
# DANK MATERIAL SHELL INSTALLATION
# Uses official DankMaterialShell installer from https://github.com/AvengeMedia/DankMaterialShell
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing DankMaterialShell..."
log "${INFO} DMS is a complete desktop shell that replaces waybar, notifications, launcher, and more"

# Check if dms is already installed
if command -v dms &>/dev/null; then
    log "${OK} DankMaterialShell is already installed"
    dms --version 2>/dev/null || true
else
    log "${INFO} Running official DankMaterialShell installer..."
    log "${INFO} This will install quickshell, dms core, and all dependencies"
    echo ""
    
    # Use the official DMS installer
    curl -fsSL https://install.danklinux.com | sh
    
    if command -v dms &>/dev/null; then
        log "${OK} DankMaterialShell installed successfully"
    else
        log "${ERROR} DankMaterialShell installation may have failed"
        log "${INFO} You can try installing manually: curl -fsSL https://install.danklinux.com | sh"
    fi
fi

# Configure DMS for Hyprland
DMS_CONFIG_DIR="$HOME/.config/dms"
mkdir -p "$DMS_CONFIG_DIR"

# Create basic DMS config if it doesn't exist
if [[ ! -f "$DMS_CONFIG_DIR/config.toml" ]]; then
    cat > "$DMS_CONFIG_DIR/config.toml" << 'EOF'
# DankMaterialShell Configuration
# See https://danklinux.com/docs for full documentation

[general]
compositor = "hyprland"

[bar]
position = "top"
height = 32

[theme]
# Theme will be auto-generated from wallpaper
auto_theme = true
EOF
    log "${OK} DMS configuration created"
fi

# Update Hyprland config to use DMS instead of waybar
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPR_CONF" ]]; then
    # Comment out waybar if present
    if grep -q "^exec-once = waybar" "$HYPR_CONF"; then
        sed -i 's/^exec-once = waybar/# exec-once = waybar  # Disabled - using DMS/' "$HYPR_CONF"
        log "${INFO} Commented out waybar in hyprland.conf"
    fi
    
    # Add DMS autostart if not present
    if ! grep -q "dms run" "$HYPR_CONF"; then
        echo "" >> "$HYPR_CONF"
        echo "# DankMaterialShell - Modern desktop shell" >> "$HYPR_CONF"
        echo "exec-once = dms run" >> "$HYPR_CONF"
        log "${OK} Added DMS to Hyprland autostart"
    fi
fi

log "${OK} DankMaterialShell setup complete"
log "${INFO} DMS will start automatically with Hyprland"
log "${INFO} Use 'dms run' to start manually, 'dms --help' for more options"
