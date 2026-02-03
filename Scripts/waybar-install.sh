#!/bin/bash
#=============================================================================
# WAYBAR INSTALLATION & CONFIGURATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIGS_DIR="$SCRIPT_DIR/../Configs"

log "${INFO} Installing Waybar..."

install_pkg "waybar"

# Create Waybar configuration directory
mkdir -p "$HOME/.config/waybar"

# Copy Waybar configuration if exists, otherwise create default
if [[ -d "$CONFIGS_DIR/waybar" ]]; then
    cp -r "$CONFIGS_DIR/waybar/"* "$HOME/.config/waybar/"
    log "${OK} Waybar configuration copied from templates"
else
    # Create default config
    cat > "$HOME/.config/waybar/config.jsonc" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 35,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬",
            "urgent": "",
            "default": ""
        }
    },
    "hyprland/window": {
        "format": "{}",
        "max-length": 50
    },
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%A, %B %d, %Y}",
        "tooltip-format": "<tt>{calendar}</tt>"
    },
    "cpu": {
        "format": "󰻠 {usage}%",
        "interval": 2
    },
    "memory": {
        "format": "󰍛 {percentage}%",
        "interval": 2
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": "󰂄 {capacity}%",
        "format-plugged": "󰂄 {capacity}%",
        "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    "network": {
        "format-wifi": "󰤨 {signalStrength}%",
        "format-ethernet": "󰈀 Connected",
        "format-disconnected": "󰤭 Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "󰝟",
        "format-icons": {
            "default": ["󰕿", "󰖀", "󰕾"]
        },
        "on-click": "pavucontrol"
    },
    "tray": {
        "spacing": 10
    }
}
EOF

    # Create default style
    cat > "$HOME/.config/waybar/style.css" << 'EOF'
* {
    font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: rgba(30, 30, 46, 0.9);
    color: #cdd6f4;
    border-radius: 0;
}

#workspaces button {
    padding: 0 8px;
    color: #6c7086;
    background: transparent;
    border: none;
    border-radius: 8px;
    margin: 4px 2px;
}

#workspaces button.active {
    color: #cba6f7;
    background: rgba(203, 166, 247, 0.2);
}

#workspaces button:hover {
    background: rgba(203, 166, 247, 0.1);
}

#clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray {
    padding: 0 12px;
    margin: 4px 2px;
    border-radius: 8px;
    background: rgba(69, 71, 90, 0.5);
}

#battery.warning {
    color: #fab387;
}

#battery.critical {
    color: #f38ba8;
}

#network.disconnected {
    color: #f38ba8;
}

#pulseaudio.muted {
    color: #6c7086;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
}
EOF

    log "${OK} Default Waybar configuration created"
fi

log "${OK} Waybar installed and configured"
