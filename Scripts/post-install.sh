#!/bin/bash
#=============================================================================
# POST-INSTALL CONFIGURATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Running post-installation configuration..."

#=============================================================================
# CREATE USER DIRECTORIES
#=============================================================================
setup_directories() {
    log "${INFO} Creating user directories..."
    
    xdg-user-dirs-update 2>/dev/null || true
    
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.cache"
    
    log "${OK} User directories created"
}

#=============================================================================
# CONFIGURE XDG
#=============================================================================
configure_xdg() {
    log "${INFO} Configuring XDG defaults..."
    
    # Set default applications
    xdg-mime default org.kde.dolphin.desktop inode/directory 2>/dev/null || \
    xdg-mime default nemo.desktop inode/directory 2>/dev/null || true
    
    xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true
    
    log "${OK} XDG defaults configured"
}

#=============================================================================
# ADD USER TO GROUPS
#=============================================================================
configure_groups() {
    log "${INFO} Adding user to necessary groups..."
    
    local groups=("video" "audio" "input" "power" "storage" "optical" "lp" "scanner")
    
    for group in "${groups[@]}"; do
        if getent group "$group" &>/dev/null; then
            sudo usermod -aG "$group" "$USER" 2>/dev/null || true
        fi
    done
    
    log "${OK} User added to groups"
}

#=============================================================================
# CONFIGURE ENVIRONMENT
#=============================================================================
setup_environment() {
    log "${INFO} Setting up environment variables..."
    
    # Create profile.d entry for Hyprland
    cat > "$HOME/.config/hypr/env.sh" << 'EOF'
#!/bin/bash
# Hyprland environment variables
# Source this in your shell config if not using UWSM

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export GDK_BACKEND=wayland,x11
export MOZ_ENABLE_WAYLAND=1
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export ELECTRON_OZONE_PLATFORM_HINT=auto
EOF
    
    chmod +x "$HOME/.config/hypr/env.sh"
    
    log "${OK} Environment configured"
}

#=============================================================================
# CREATE HYPRLAND SESSION
#=============================================================================
create_session_file() {
    log "${INFO} Creating Hyprland desktop session..."
    
    # The session file should already exist from hyprland package
    # But we'll make sure it's correct
    
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
    
    log "${OK} Session file verified"
}

#=============================================================================
# CLEANUP
#=============================================================================
cleanup() {
    log "${INFO} Cleaning up..."
    
    # Clear package cache
    if confirm "Clear package cache to save disk space?"; then
        sudo pacman -Sc --noconfirm 2>/dev/null || true
    fi
    
    log "${OK} Cleanup complete"
}

#=============================================================================
# MAIN
#=============================================================================
main() {
    setup_directories
    configure_xdg
    configure_groups
    setup_environment
    create_session_file
    cleanup
    
    log "${OK} Post-installation configuration complete"
}

main
