#!/bin/bash
#=============================================================================
# LY (TUI DISPLAY MANAGER) INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Ly display manager..."

# Install Ly
install_pkg "ly"

# Configure Ly
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

# Disable any other display managers first
for dm in gdm sddm lightdm lxdm greetd; do
    if systemctl is-enabled "$dm" &>/dev/null 2>&1; then
        sudo systemctl disable "$dm" 2>/dev/null || true
    fi
done

# Reload systemd to pick up new service files
sudo systemctl daemon-reload

# Find and enable Ly service - check multiple possible locations and names
LY_SERVICE=""
for service in "ly.service" "ly-dm.service"; do
    if systemctl list-unit-files 2>/dev/null | grep -q "^${service}"; then
        LY_SERVICE="$service"
        break
    fi
done

# If not found in list, check file locations directly
if [[ -z "$LY_SERVICE" ]]; then
    for path in /usr/lib/systemd/system /etc/systemd/system /lib/systemd/system; do
        if [[ -f "$path/ly.service" ]]; then
            LY_SERVICE="ly.service"
            break
        elif [[ -f "$path/ly-dm.service" ]]; then
            LY_SERVICE="ly-dm.service"
            break
        fi
    done
fi

if [[ -n "$LY_SERVICE" ]]; then
    sudo systemctl enable "$LY_SERVICE"
    log "${OK} Ly ($LY_SERVICE) enabled and configured"
else
    # Create the service file manually if it doesn't exist
    log "${WARN} Ly service file not found, creating it..."
    
    cat << 'SERVICEEOF' | sudo tee /etc/systemd/system/ly.service >/dev/null
[Unit]
Description=TUI display manager
After=systemd-user-sessions.service plymouth-quit-wait.service getty@tty2.service
Conflicts=getty@tty2.service

[Service]
Type=idle
ExecStart=/usr/bin/ly
StandardInput=tty
TTYPath=/dev/tty2
TTYReset=yes
TTYVHangup=yes

[Install]
Alias=display-manager.service
SERVICEEOF

    sudo systemctl daemon-reload
    sudo systemctl enable ly.service
    log "${OK} Ly service created and enabled"
fi
