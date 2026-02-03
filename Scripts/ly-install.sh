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
for dm in gdm sddm lightdm lxdm; do
    if systemctl is-enabled "$dm" &>/dev/null; then
        sudo systemctl disable "$dm" 2>/dev/null
    fi
done

# Enable Ly service (try both possible service names)
if systemctl list-unit-files | grep -q "ly.service"; then
    sudo systemctl enable ly.service
    log "${OK} Ly enabled and configured"
elif [ -f /usr/lib/systemd/system/ly.service ]; then
    sudo systemctl daemon-reload
    sudo systemctl enable ly.service
    log "${OK} Ly enabled and configured"
else
    log "${WARN} Ly service file not found - you may need to enable it manually after reboot"
    log "${INFO} Try: sudo systemctl enable ly.service"
fi
