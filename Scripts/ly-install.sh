#!/bin/bash
#=============================================================================
# LY (TUI DISPLAY MANAGER) INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Ly display manager..."

# Install Ly
install_pkg "ly"

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
min_refresh_rate = 10
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
xsessions_d = /usr/share/xsessions
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
    # Also check templated service names
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
# Default TTY is tty2
LY_TTY="tty2"

# Disable getty on the TTY that Ly will use (CRITICAL: they conflict)
sudo systemctl disable "getty@${LY_TTY}.service" 2>/dev/null || true

# Try the templated service name first (ly@tty2.service) - this is what Arch provides
if systemctl list-unit-files 2>/dev/null | grep -q "ly@"; then
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    log "${OK} Ly (ly@${LY_TTY}.service) enabled"
# Fall back to non-templated service name
elif systemctl list-unit-files 2>/dev/null | grep -q "^ly\.service"; then
    sudo systemctl enable --force "ly.service"
    log "${OK} Ly (ly.service) enabled"
elif systemctl list-unit-files 2>/dev/null | grep -q "^ly-dm\.service"; then
    sudo systemctl enable --force "ly-dm.service"
    log "${OK} Ly (ly-dm.service) enabled"
else
    # No service file found at all - create one manually
    log "${WARN} Ly service file not found, creating it..."

    cat << SERVICEEOF | sudo tee /etc/systemd/system/ly@.service >/dev/null
[Unit]
Description=TUI display manager
After=systemd-user-sessions.service plymouth-quit-wait.service
Conflicts=getty@%i.service

[Service]
Type=idle
ExecStart=/usr/bin/ly
StandardInput=tty
TTYPath=/dev/%i
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=graphical.target
Alias=display-manager.service
SERVICEEOF

    sudo systemctl daemon-reload
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    log "${OK} Ly service created and enabled (ly@${LY_TTY}.service)"
fi

#=============================================================================
# VERIFY HYPRLAND IS AVAILABLE AS A SESSION
#=============================================================================
log "${INFO} Verifying Hyprland session availability..."

if [[ -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
    log "${OK} Hyprland session found: /usr/share/wayland-sessions/hyprland.desktop"
else
    log "${WARN} Hyprland session file not found!"
    log "${INFO} This may mean Hyprland is not installed or session file is missing"
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
