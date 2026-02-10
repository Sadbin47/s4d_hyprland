#!/bin/bash
#=============================================================================
# LY (TUI DISPLAY MANAGER) INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Ly display manager..."

# Install Ly
install_pkg "ly"

# Verify Ly actually installed
LY_BIN=""
if command -v ly-dm &>/dev/null; then
    LY_BIN="$(command -v ly-dm)"
elif command -v ly &>/dev/null; then
    LY_BIN="$(command -v ly)"
elif [[ -x /usr/bin/ly-dm ]]; then
    LY_BIN="/usr/bin/ly-dm"
elif [[ -x /usr/bin/ly ]]; then
    LY_BIN="/usr/bin/ly"
fi

if [[ -z "$LY_BIN" ]]; then
    log "${ERROR} Ly binary not found after installation — aborting Ly setup"
    log "${INFO} You can install Ly manually: yay -S ly"
    return 1 2>/dev/null || exit 1
fi

log "${OK} Ly binary found at: $LY_BIN"

#=============================================================================
# ENSURE HYPRLAND SESSION FILE EXISTS
#=============================================================================
log "${INFO} Ensuring Hyprland session file exists..."

# Create wayland-sessions directory if it doesn't exist
sudo mkdir -p /usr/share/wayland-sessions

# Detect correct Hyprland binary name
HYPR_BIN=""
if command -v Hyprland &>/dev/null; then
    HYPR_BIN="Hyprland"
elif command -v hyprland &>/dev/null; then
    HYPR_BIN="hyprland"
else
    HYPR_BIN="Hyprland"  # Default
fi

# Create/update hyprland.desktop session file
log "${INFO} Creating Hyprland session file (Exec=$HYPR_BIN)..."
cat << DEOF | sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=$HYPR_BIN
Type=Application
DesktopNames=Hyprland
DEOF
log "${OK} Created /usr/share/wayland-sessions/hyprland.desktop"

# Make sure it's readable
sudo chmod 644 /usr/share/wayland-sessions/hyprland.desktop

#=============================================================================
# CONFIGURE LY
#=============================================================================
sudo mkdir -p /etc/ly

# Create custom configuration
cat << 'EOF' | sudo tee /etc/ly/config.ini >/dev/null
# Ly configuration
animate = true
animation = 0
bigclock = none
blank_password = false
clear_password = true
clock = %c
default_input = login
hide_borders = false
hide_f1_commands = false
input_len = 255
lang = en
load = true
animation_frame_delay = 10
path = /usr/local/sbin:/usr/local/bin:/usr/bin
restart_cmd = /usr/bin/systemctl reboot
save = true
save_file = /tmp/ly-save
service_name = ly
shutdown_cmd = /usr/bin/systemctl poweroff
sleep_cmd = /usr/bin/systemctl suspend
term_reset_cmd = /usr/bin/tput reset
waylandsessions = /usr/share/wayland-sessions
xsessions = /usr/share/xsessions
initial_info_text = s4d Hyprland
blank_box = true
box_main_color = 6
box_border_color = 6
box_inner_text_color = 7
input_color = 7
EOF

log "${OK} Ly configuration created"

#=============================================================================
# ENABLE LY SERVICE
#=============================================================================

# Disable any other display managers first
for dm in gdm sddm lightdm lxdm greetd; do
    if systemctl is-enabled "$dm" &>/dev/null 2>&1; then
        sudo systemctl disable "$dm" 2>/dev/null || true
    fi
    if systemctl is-enabled "${dm}.service" &>/dev/null 2>&1; then
        sudo systemctl disable "${dm}.service" 2>/dev/null || true
    fi
done

# Set default boot target to graphical (required for display managers)
sudo systemctl set-default graphical.target
log "${OK} Set default boot target to graphical.target"

# Reload systemd to pick up new service files
sudo systemctl daemon-reload

# Ly on Arch uses a templated service: ly@ttyN.service
LY_TTY="tty2"

# Disable getty on the TTY that Ly will use (CRITICAL: they conflict)
sudo systemctl disable "getty@${LY_TTY}.service" 2>/dev/null || true
sudo systemctl mask "getty@${LY_TTY}.service" 2>/dev/null || true
sudo systemctl stop "getty@${LY_TTY}.service" 2>/dev/null || true
log "${OK} Disabled and masked getty@${LY_TTY}.service"

# Handle systemd-logind autovt (prevents getty from auto-spawning on TTY switch)
# This is critical: systemd-logind can auto-start getty via autovt@.service
if [[ -f /usr/lib/systemd/system/ly@.service ]] || [[ -f /etc/systemd/system/ly@.service ]]; then
    sudo mkdir -p /etc/systemd/system
    sudo ln -sf /usr/lib/systemd/system/ly@.service \
        "/etc/systemd/system/autovt@${LY_TTY}.service" 2>/dev/null || true
    log "${OK} Symlinked autovt@${LY_TTY}.service -> ly@.service"
fi

# Also disable autovt for this TTY to prevent conflicts
if [[ -f /etc/systemd/logind.conf ]]; then
    # Ensure NAutoVTs doesn't include our TTY
    log "${INFO} Note: If Ly still shows TTY login, check /etc/systemd/logind.conf NAutoVTs setting"
fi

# Determine the service file location
LY_SERVICE_FOUND=false

# Check for the templated service provided by the ly package
if [[ -f /usr/lib/systemd/system/ly@.service ]]; then
    log "${INFO} Found system-provided ly@.service"
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    LY_SERVICE_FOUND=true
    log "${OK} Ly (ly@${LY_TTY}.service) enabled"
elif systemctl list-unit-files 2>/dev/null | grep -q "ly@"; then
    log "${INFO} Found ly@ templated service"
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    LY_SERVICE_FOUND=true
    log "${OK} Ly (ly@${LY_TTY}.service) enabled"
elif systemctl list-unit-files 2>/dev/null | grep -q "^ly\.service"; then
    sudo systemctl enable --force "ly.service"
    LY_SERVICE_FOUND=true
    log "${OK} Ly (ly.service) enabled"
elif systemctl list-unit-files 2>/dev/null | grep -q "^ly-dm\.service"; then
    sudo systemctl enable --force "ly-dm.service"
    LY_SERVICE_FOUND=true
    log "${OK} Ly (ly-dm.service) enabled"
fi

if [[ "$LY_SERVICE_FOUND" == false ]]; then
    # No service file found at all - create one manually with correct binary path
    log "${WARN} Ly service file not found, creating it..."

    cat << SERVICEEOF | sudo tee /usr/lib/systemd/system/ly@.service >/dev/null
[Unit]
Description=TUI display manager
After=systemd-user-sessions.service plymouth-quit-wait.service getty@%i.service
Conflicts=getty@%i.service
Before=getty@%i.service

[Service]
Type=idle
ExecStart=${LY_BIN}
StandardInput=tty
TTYPath=/dev/%i
TTYReset=yes
TTYVHangup=yes
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical.target
Alias=display-manager.service
SERVICEEOF

    sudo systemctl daemon-reload
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    log "${OK} Ly service created and enabled (ly@${LY_TTY}.service)"
fi

#=============================================================================
# VERIFY EVERYTHING IS SET UP CORRECTLY
#=============================================================================
log "${INFO} Verifying Ly setup..."

# Verify the service is actually enabled
if systemctl is-enabled "ly@${LY_TTY}.service" &>/dev/null 2>&1; then
    log "${OK} ly@${LY_TTY}.service is enabled"
elif systemctl is-enabled "ly.service" &>/dev/null 2>&1; then
    log "${OK} ly.service is enabled"
else
    log "${WARN} Ly service does not appear to be enabled!"
    log "${INFO} Attempting direct symlink as fallback..."
    # Direct symlink as absolute last resort
    sudo ln -sf /usr/lib/systemd/system/ly@.service \
        /etc/systemd/system/display-manager.service 2>/dev/null || true
    sudo systemctl daemon-reload
    sudo systemctl enable --force "ly@${LY_TTY}.service" 2>/dev/null || true
fi

# Verify getty is not going to conflict
if systemctl is-enabled "getty@${LY_TTY}.service" &>/dev/null 2>&1; then
    log "${WARN} getty@${LY_TTY}.service is still enabled — disabling"
    sudo systemctl disable "getty@${LY_TTY}.service" 2>/dev/null || true
    sudo systemctl mask "getty@${LY_TTY}.service" 2>/dev/null || true
fi

# Verify default target
CURRENT_TARGET=$(systemctl get-default 2>/dev/null)
if [[ "$CURRENT_TARGET" != "graphical.target" ]]; then
    log "${WARN} Default target is $CURRENT_TARGET, setting to graphical.target"
    sudo systemctl set-default graphical.target
fi

# Verify Hyprland session file
if [[ -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
    log "${OK} Hyprland session found: /usr/share/wayland-sessions/hyprland.desktop"
else
    log "${WARN} Hyprland session file not found!"
fi

# Check if Hyprland binary exists
if command -v Hyprland &>/dev/null; then
    log "${OK} Hyprland binary found: $(which Hyprland)"
else
    log "${WARN} Hyprland binary not found in PATH"
    log "${INFO} Make sure Hyprland is installed before rebooting"
fi

# List available sessions for debugging
log "${INFO} Available wayland sessions:"
if [[ -d /usr/share/wayland-sessions ]]; then
    for session in /usr/share/wayland-sessions/*.desktop; do
        if [[ -f "$session" ]]; then
            name=$(grep "^Name=" "$session" | cut -d= -f2)
            log "         - $name ($(basename "$session"))"
        fi
    done
fi

log "${OK} Ly display manager installation complete"
log "${INFO} Ly will appear on ${LY_TTY} after reboot"
log "${INFO} Select 'Hyprland' from the session list and login"
