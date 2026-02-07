#!/bin/bash
#=============================================================================
# POST-INSTALL CONFIGURATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Post-installation setup..."

# XDG directories
xdg-user-dirs-update 2>/dev/null || true
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share"

# XDG defaults
xdg-mime default org.kde.dolphin.desktop inode/directory 2>/dev/null || \
xdg-mime default nemo.desktop inode/directory 2>/dev/null || true
xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true

# User groups
for group in video audio input power storage optical lp scanner; do
    if getent group "$group" &>/dev/null; then
        sudo usermod -aG "$group" "$USER" 2>/dev/null || true
    fi
done

# Hyprland session file
if [[ ! -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
    sudo mkdir -p /usr/share/wayland-sessions
    cat << 'EOF' | sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF
fi

# Ensure ~/.local/bin is in PATH
if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

log "${OK} Post-installation done"
