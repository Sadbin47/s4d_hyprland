#!/bin/bash
#=============================================================================
# DOTFILES APPLICATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIGS_DIR="$SCRIPT_DIR/../Configs"
DOTFILES_TYPE="${1:-default}"
CUSTOM_REPO="${2:-}"

log "${INFO} Applying dotfiles: $DOTFILES_TYPE"

#=============================================================================
# BACKUP EXISTING CONFIGS
#=============================================================================
backup_existing_configs() {
    log "${INFO} Backing up existing configurations..."
    
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir"
    
    local configs_to_backup=(
        "$HOME/.config/hypr"
        "$HOME/.config/kitty"
        "$HOME/.config/rofi"
        "$HOME/.config/waybar"
        "$HOME/.config/swaync"
        "$HOME/.config/dunst"
    )
    
    for config in "${configs_to_backup[@]}"; do
        if [[ -d "$config" ]]; then
            mv "$config" "$backup_dir/" 2>/dev/null
            log "${INFO} Backed up $(basename "$config")"
        fi
    done
    
    log "${OK} Existing configs backed up to: $backup_dir"
}

#=============================================================================
# APPLY DEFAULT DOTFILES
#=============================================================================
apply_default_dotfiles() {
    log "${INFO} Applying default s4d dotfiles..."
    
    backup_existing_configs
    
    # Copy all config directories
    if [[ -d "$CONFIGS_DIR" ]]; then
        cp -r "$CONFIGS_DIR/"* "$HOME/.config/" 2>/dev/null
        log "${OK} Default dotfiles applied from local configs"
    else
        log "${WARN} Local config directory not found, creating default configs..."
        create_minimal_configs
    fi
}

#=============================================================================
# APPLY CUSTOM DOTFILES
#=============================================================================
apply_custom_dotfiles() {
    local repo_url="$1"
    
    log "${INFO} Cloning custom dotfiles from: $repo_url"
    
    backup_existing_configs
    
    local tmp_dir=$(mktemp -d)
    
    if git clone --depth 1 "$repo_url" "$tmp_dir"; then
        # Check for common dotfile structures
        if [[ -d "$tmp_dir/.config" ]]; then
            cp -r "$tmp_dir/.config/"* "$HOME/.config/"
        elif [[ -d "$tmp_dir/config" ]]; then
            cp -r "$tmp_dir/config/"* "$HOME/.config/"
        elif [[ -d "$tmp_dir/Configs" ]]; then
            cp -r "$tmp_dir/Configs/"* "$HOME/.config/"
        else
            # Assume root contains config folders
            for dir in hypr kitty rofi waybar swaync; do
                if [[ -d "$tmp_dir/$dir" ]]; then
                    cp -r "$tmp_dir/$dir" "$HOME/.config/"
                fi
            done
        fi
        log "${OK} Custom dotfiles applied"
    else
        log "${ERROR} Failed to clone repository"
        log "${INFO} Falling back to minimal configs..."
        create_minimal_configs
    fi
    
    rm -rf "$tmp_dir"
}

#=============================================================================
# CREATE MINIMAL CONFIGS
#=============================================================================
create_minimal_configs() {
    log "${INFO} Creating minimal configurations..."
    
    # Create directories
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/rofi"
    mkdir -p "$HOME/.config/swaync"
    
    # Hyprland main config
    cat > "$HOME/.config/hypr/hyprland.conf" << 'EOF'
#=============================================================================
# s4d Hyprland Configuration - Minimal & Clean
#=============================================================================

# Monitor configuration (auto-detect)
monitor=,preferred,auto,auto

# Variables
$terminal = kitty
$fileManager = dolphin
$menu = rofi -show drun
$browser = firefox
$editor = code
$mainMod = SUPER

# Startup applications
exec-once = swaync
exec-once = waybar
exec-once = swww init
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = udiskie &
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = hypridle

# Source additional configs
source = ~/.config/hypr/nvidia.conf # Comment if not using NVIDIA
source = ~/.config/hypr/env.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/theme.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/windowrules.conf

# Import ROG config if exists (for ASUS laptops)
# source = ~/.config/hypr/rog.conf
EOF

    # Environment variables
    cat > "$HOME/.config/hypr/env.conf" << 'EOF'
# Environment variables
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = GDK_BACKEND,wayland,x11
env = MOZ_ENABLE_WAYLAND,1
env = CLUTTER_BACKEND,wayland
EOF

    # Input configuration
    cat > "$HOME/.config/hypr/input.conf" << 'EOF'
# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    
    touchpad {
        natural_scroll = false
        tap-to-click = true
        drag_lock = false
    }
}

gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}
EOF

    # Theme/appearance
    cat > "$HOME/.config/hypr/theme.conf" << 'EOF'
# Appearance
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(cba6f7ee) rgba(89b4faee) 45deg
    col.inactive_border = rgba(45475aaa)
    layout = dwindle
    allow_tearing = false
}

decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
        ignore_opacity = true
    }
    
    shadow {
        enabled = true
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = true
    preserve_split = true
}

master {
    new_status = master
}

misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
}
EOF

    # Keybindings
    cat > "$HOME/.config/hypr/keybinds.conf" << 'EOF'
# Keybindings
$mainMod = SUPER

# Application shortcuts
bind = $mainMod, T, exec, $terminal
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, A, exec, $menu
bind = $mainMod, B, exec, $browser
bind = $mainMod, C, exec, $editor

# Window management
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, V, togglefloating
bind = $mainMod, F, fullscreen
bind = $mainMod, P, pseudo
bind = $mainMod, J, togglesplit

# Lock screen
bind = $mainMod, L, exec, hyprlock

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy
bind = $mainMod, Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png

# Volume control
bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86AudioMicMute, exec, pamixer --default-source -t

# Brightness control
bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Media control
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Clipboard
bind = $mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

# Notification center
bind = $mainMod, N, exec, swaync-client -t -sw

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mouse
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF

    # Window rules
    cat > "$HOME/.config/hypr/windowrules.conf" << 'EOF'
# Window rules

# Float certain windows
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, class:^(nwg-look)$
windowrulev2 = float, class:^(qt5ct)$
windowrulev2 = float, class:^(qt6ct)$
windowrulev2 = float, class:^(file-roller)$
windowrulev2 = float, title:^(Picture-in-Picture)$
windowrulev2 = float, title:^(Open File)$
windowrulev2 = float, title:^(Save File)$
windowrulev2 = float, title:^(Confirm to replace files)$

# Center floating windows
windowrulev2 = center, floating:1

# Opacity rules
windowrulev2 = opacity 0.9 0.9, class:^(kitty)$
windowrulev2 = opacity 0.95 0.95, class:^(Code)$
windowrulev2 = opacity 0.95 0.95, class:^(code)$

# Workspace assignments
windowrulev2 = workspace 2 silent, class:^(firefox)$
windowrulev2 = workspace 3 silent, class:^(Code)$
windowrulev2 = workspace 4 silent, class:^(dolphin)$
windowrulev2 = workspace 4 silent, class:^(nemo)$
EOF

    # Hyprlock config
    cat > "$HOME/.config/hypr/hyprlock.conf" << 'EOF'
general {
    disable_loading_bar = false
    hide_cursor = true
    grace = 0
    no_fade_in = false
}

background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
    noise = 0.0117
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

input-field {
    monitor =
    size = 250, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    outer_color = rgb(cba6f7)
    inner_color = rgb(1e1e2e)
    font_color = rgb(cdd6f4)
    fade_on_empty = true
    placeholder_text = <i>Password...</i>
    hide_input = false
    position = 0, -20
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%-I:%M %p")"
    font_size = 90
    font_family = JetBrainsMono Nerd Font
    color = rgb(cdd6f4)
    position = 0, 200
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%A, %B %d")"
    font_size = 20
    font_family = JetBrainsMono Nerd Font
    color = rgb(cdd6f4)
    position = 0, 100
    halign = center
    valign = center
}
EOF

    # Hypridle config
    cat > "$HOME/.config/hypr/hypridle.conf" << 'EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300
    on-timeout = brightnessctl -s set 30
    on-resume = brightnessctl -r
}

listener {
    timeout = 600
    on-timeout = loginctl lock-session
}

listener {
    timeout = 660
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
EOF

    # Kitty config
    cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
# Kitty Configuration - s4d Hyprland

# Font
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.0

# Cursor
cursor_shape          beam
cursor_blink_interval 0.5

# Scrollback
scrollback_lines 10000

# Window
window_padding_width  10
confirm_os_window_close 0
background_opacity    0.9
dynamic_background_opacity yes

# Tab bar
tab_bar_edge         bottom
tab_bar_style        powerline
tab_powerline_style  slanted

# Colors (Catppuccin Mocha)
foreground              #CDD6F4
background              #1E1E2E
selection_foreground    #1E1E2E
selection_background    #F5E0DC

# Black
color0  #45475A
color8  #585B70

# Red
color1  #F38BA8
color9  #F38BA8

# Green
color2  #A6E3A1
color10 #A6E3A1

# Yellow
color3  #F9E2AF
color11 #F9E2AF

# Blue
color4  #89B4FA
color12 #89B4FA

# Magenta
color5  #F5C2E7
color13 #F5C2E7

# Cyan
color6  #94E2D5
color14 #94E2D5

# White
color7  #BAC2DE
color15 #A6ADC8

# Keyboard shortcuts
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+t new_tab_with_cwd
map ctrl+shift+q close_tab
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab
map ctrl+shift+equal change_font_size all +1.0
map ctrl+shift+minus change_font_size all -1.0
EOF

    # Rofi config
    mkdir -p "$HOME/.config/rofi"
    cat > "$HOME/.config/rofi/config.rasi" << 'EOF'
configuration {
    modi: "drun,run,window,filebrowser";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    display-drun: " Apps";
    display-run: " Run";
    display-window: " Windows";
    display-filebrowser: " Files";
    drun-display-format: "{name}";
    window-format: "{w} · {c} · {t}";
    font: "JetBrainsMono Nerd Font 11";
}

@theme "catppuccin-mocha"
EOF

    # Rofi theme (Catppuccin Mocha)
    mkdir -p "$HOME/.config/rofi/themes"
    cat > "$HOME/.config/rofi/catppuccin-mocha.rasi" << 'EOF'
* {
    bg: #1e1e2e;
    bg-alt: #313244;
    fg: #cdd6f4;
    fg-alt: #6c7086;
    accent: #cba6f7;
    
    background-color: transparent;
    text-color: @fg;
    margin: 0;
    padding: 0;
}

window {
    location: center;
    width: 600px;
    border-radius: 12px;
    background-color: @bg;
    border: 2px solid;
    border-color: @accent;
}

mainbox {
    padding: 12px;
}

inputbar {
    background-color: @bg-alt;
    padding: 10px 12px;
    border-radius: 8px;
    margin-bottom: 12px;
    children: [prompt, entry];
}

prompt {
    enabled: true;
    padding: 0 8px 0 0;
    text-color: @accent;
}

entry {
    placeholder: "Search...";
    placeholder-color: @fg-alt;
}

listview {
    lines: 8;
    fixed-height: true;
    scrollbar: false;
}

element {
    padding: 10px 12px;
    border-radius: 8px;
}

element selected {
    background-color: @bg-alt;
    text-color: @accent;
}

element-icon {
    size: 24px;
    margin-right: 12px;
}

element-text {
    vertical-align: 0.5;
}
EOF

    # SwayNC config
    mkdir -p "$HOME/.config/swaync"
    cat > "$HOME/.config/swaync/config.json" << 'EOF'
{
    "$schema": "/etc/xdg/swaync/configSchema.json",
    "positionX": "right",
    "positionY": "top",
    "layer": "overlay",
    "control-center-layer": "top",
    "layer-shell": true,
    "cssPriority": "application",
    "control-center-margin-top": 10,
    "control-center-margin-bottom": 10,
    "control-center-margin-right": 10,
    "control-center-margin-left": 0,
    "notification-2fa-action": true,
    "notification-inline-replies": false,
    "notification-icon-size": 64,
    "notification-body-image-height": 100,
    "notification-body-image-width": 200,
    "timeout": 10,
    "timeout-low": 5,
    "timeout-critical": 0,
    "fit-to-screen": true,
    "control-center-width": 400,
    "control-center-height": 600,
    "notification-window-width": 400,
    "keyboard-shortcuts": true,
    "image-visibility": "when-available",
    "transition-time": 200,
    "hide-on-clear": false,
    "hide-on-action": true,
    "script-fail-notify": true,
    "widgets": [
        "inhibitors",
        "title",
        "dnd",
        "notifications"
    ],
    "widget-config": {
        "inhibitors": {
            "text": "Inhibitors",
            "button-text": "Clear All",
            "clear-all-button": true
        },
        "title": {
            "text": "Notifications",
            "clear-all-button": true,
            "button-text": "Clear All"
        },
        "dnd": {
            "text": "Do Not Disturb"
        }
    }
}
EOF

    log "${OK} Minimal configurations created"
}

#=============================================================================
# MAIN
#=============================================================================
case "$DOTFILES_TYPE" in
    default)
        apply_default_dotfiles
        ;;
    custom)
        if [[ -n "$CUSTOM_REPO" ]]; then
            apply_custom_dotfiles "$CUSTOM_REPO"
        else
            log "${ERROR} No custom repository URL provided"
            create_minimal_configs
        fi
        ;;
    minimal)
        backup_existing_configs
        create_minimal_configs
        ;;
    *)
        log "${WARN} Unknown dotfiles type: $DOTFILES_TYPE"
        create_minimal_configs
        ;;
esac

log "${OK} Dotfiles application complete"
