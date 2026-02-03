#!/bin/bash
#=============================================================================
# DANK MATERIAL SHELL INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing DankMaterialShell (Quickshell-based desktop shell)..."

# Install dependencies
DANKMS_DEPS=(
    "quickshell-git"
    "qt6-base"
    "qt6-declarative"
    "qt6-wayland"
    "qt6-svg"
    "pipewire"
    "libpulse"
    "pam"
)

# Install quickshell from AUR
for pkg in "${DANKMS_DEPS[@]}"; do
    install_pkg "$pkg"
done

# Clone DankMaterialShell
DANKMS_DIR="$HOME/.local/share/quickshell/dankms"
mkdir -p "$(dirname "$DANKMS_DIR")"

if [[ -d "$DANKMS_DIR" ]]; then
    log "${INFO} DankMaterialShell already exists, updating..."
    cd "$DANKMS_DIR" && git pull
else
    log "${INFO} Cloning DankMaterialShell..."
    git clone https://github.com/end-4/dots-hyprland.git "$DANKMS_DIR" --depth 1
fi

# Create quickshell config
mkdir -p "$HOME/.config/quickshell"

cat > "$HOME/.config/quickshell/manifest.conf" << 'EOF'
[Main]
Entry=shell.qml
EOF

log "${OK} DankMaterialShell installed"
log "${INFO} To use DankMaterialShell, add 'exec-once = quickshell' to your Hyprland config"
log "${INFO} And comment out/remove the waybar exec line"

# Add to hyprland autostart
if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
    if ! grep -q "quickshell" "$HOME/.config/hypr/hyprland.conf"; then
        echo "" >> "$HOME/.config/hypr/hyprland.conf"
        echo "# DankMaterialShell (uncomment to use instead of waybar)" >> "$HOME/.config/hypr/hyprland.conf"
        echo "# exec-once = quickshell" >> "$HOME/.config/hypr/hyprland.conf"
    fi
fi

log "${OK} DankMaterialShell setup complete"
