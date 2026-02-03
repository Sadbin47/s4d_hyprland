#!/bin/bash
#=============================================================================
# DANK MATERIAL SHELL (BAR) INSTALLATION
# Installs DankMaterialShell bar for use with Hyprland
# Reference: https://github.com/AvengeMedia/DankMaterialShell
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing DankMaterialShell bar..."

# Install dependencies
DMS_DEPS=(
    "qt6-base"
    "qt6-declarative"
    "qt6-wayland"
    "qt6-svg"
    "qt6-shadertools"
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
)

log "${INFO} Installing dependencies..."
for pkg in "${DMS_DEPS[@]}"; do
    install_pkg "$pkg"
done

# Install quickshell from AUR (required for DMS)
log "${INFO} Installing quickshell..."
if pkg_installed "quickshell-git" || pkg_installed "quickshell"; then
    log "${OK} quickshell is already installed"
else
    # Try binary package first if available
    if yay -Si quickshell &>/dev/null 2>&1; then
        install_pkg "quickshell"
    else
        log "${WARN} Installing quickshell-git from AUR (this may take 10-20 minutes to compile)..."
        install_pkg "quickshell-git"
    fi
fi

# Clone DankMaterialShell
DMS_DIR="$HOME/.local/share/dms"
DMS_SHELL_DIR="$HOME/.config/quickshell"

log "${INFO} Setting up DankMaterialShell..."

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

# Build the dms CLI tool
log "${INFO} Building dms CLI..."
cd "$DMS_DIR/core"
if make build; then
    # Install dms binary to user local bin
    mkdir -p "$HOME/.local/bin"
    cp "$DMS_DIR/core/bin/dms" "$HOME/.local/bin/dms"
    chmod +x "$HOME/.local/bin/dms"
    log "${OK} dms CLI built and installed to ~/.local/bin/dms"
else
    log "${WARN} dms CLI build failed - bar will still work via quickshell"
fi

# Setup quickshell config to use DMS
mkdir -p "$DMS_SHELL_DIR"

# Link or copy the DMS quickshell files
if [[ -d "$DMS_SHELL_DIR/dms" ]]; then
    rm -rf "$DMS_SHELL_DIR/dms"
fi
ln -sf "$DMS_DIR/quickshell" "$DMS_SHELL_DIR/dms"

# Create manifest to use DMS
cat > "$DMS_SHELL_DIR/manifest.conf" << 'EOF'
[Main]
Entry=dms/shell.qml
EOF

log "${OK} DankMaterialShell quickshell config created"

# Update Hyprland config
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPR_CONF" ]]; then
    # Comment out waybar if present
    if grep -q "^exec-once = waybar" "$HYPR_CONF"; then
        sed -i 's/^exec-once = waybar/# exec-once = waybar  # Disabled - using DMS bar/' "$HYPR_CONF"
        log "${INFO} Commented out waybar in hyprland.conf"
    fi
    
    # Add quickshell autostart if not present
    if ! grep -q "quickshell" "$HYPR_CONF"; then
        cat >> "$HYPR_CONF" << 'EOF'

# DankMaterialShell bar
exec-once = quickshell
EOF
        log "${OK} Added DMS bar to Hyprland autostart"
    fi
fi

# Add ~/.local/bin to PATH reminder
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    log "${INFO} Add ~/.local/bin to your PATH for the dms CLI:"
    log "${INFO}   export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

log "${OK} DankMaterialShell bar installation complete"
log "${INFO} Start with: quickshell"
log "${INFO} Or use dms CLI: dms run"
