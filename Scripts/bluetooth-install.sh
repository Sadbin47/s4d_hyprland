#!/bin/bash
#=============================================================================
# BLUETOOTH CONFIGURATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Bluetooth packages..."

BLUETOOTH_PACKAGES=(
    "bluez"
    "bluez-utils"
    "blueman"
)

for pkg in "${BLUETOOTH_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Enable Bluetooth service
sudo systemctl enable --now bluetooth

# Configure Bluetooth
sudo mkdir -p /etc/bluetooth

# Enable auto-power on
if [[ -f /etc/bluetooth/main.conf ]]; then
    if ! grep -q "AutoEnable=true" /etc/bluetooth/main.conf; then
        sudo sed -i 's/^#AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
        if ! grep -q "AutoEnable=true" /etc/bluetooth/main.conf; then
            echo "AutoEnable=true" | sudo tee -a /etc/bluetooth/main.conf >/dev/null
        fi
    fi
fi

log "${OK} Bluetooth installed and configured"
log "${INFO} Blueman applet will start with your session"
