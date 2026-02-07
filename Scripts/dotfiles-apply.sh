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
        "$HOME/.config/wlogout"
        "$HOME/.config/fastfetch"
        "$HOME/.config/gtk-3.0"
        "$HOME/.config/gtk-4.0"
        "$HOME/.config/qt5ct"
        "$HOME/.config/qt6ct"
        "$HOME/.config/starship"
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
        # Copy standard config dirs into ~/.config/
        for dir in hypr waybar rofi swaync kitty wlogout fastfetch gtk-3.0 gtk-4.0 qt5ct qt6ct starship; do
            if [[ -d "$CONFIGS_DIR/$dir" ]]; then
                mkdir -p "$HOME/.config/$dir"
                cp -r "$CONFIGS_DIR/$dir/"* "$HOME/.config/$dir/"
                log "${INFO} Applied $dir config"
            fi
        done
        
        # Zsh configs go to $HOME (not ~/.config)
        if [[ -d "$CONFIGS_DIR/zsh" ]]; then
            [[ -f "$CONFIGS_DIR/zsh/.zshrc" ]] && cp "$CONFIGS_DIR/zsh/.zshrc" "$HOME/.zshrc"
            [[ -f "$CONFIGS_DIR/zsh/.zprofile" ]] && cp "$CONFIGS_DIR/zsh/.zprofile" "$HOME/.zprofile"
            log "${INFO} Applied zsh config"
        fi
        
        # Make all hypr scripts executable
        if [[ -d "$HOME/.config/hypr/scripts" ]]; then
            chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
            log "${OK} Made hypr scripts executable"
        fi
        
        # Make rofi scripts executable
        if [[ -d "$HOME/.config/rofi/scripts" ]]; then
            chmod +x "$HOME/.config/rofi/scripts/"*.sh 2>/dev/null || true
        fi
        
        # Create wallpaper directory
        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/s4d/wallpapers"
        mkdir -p "$HOME/.cache/s4d"
        
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
    
    # Suppress interactive git prompts and set timeout for clone
    if GIT_TERMINAL_PROMPT=0 timeout 30 git clone --depth 1 "$repo_url" "$tmp_dir" &>/dev/null; then
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
        log "${WARN} Could not clone repository (requires public access or SSH key)"
        log "${INFO} Falling back to minimal configs..."
        create_minimal_configs
    fi
    
    rm -rf "$tmp_dir"
}

#=============================================================================
# CREATE MINIMAL CONFIGS
# Fallback when Configs directory is not available (e.g. remote install)
#=============================================================================
create_minimal_configs() {
    log "${INFO} Creating minimal configurations..."
    
    # Create directory structure
    mkdir -p "$HOME/.config/hypr/"{animations,colors,settings,themes,keybinds,scripts,shaders}
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/rofi"
    mkdir -p "$HOME/.config/swaync"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/wlogout"
    mkdir -p "$HOME/.config/fastfetch"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/s4d/wallpapers"
    mkdir -p "$HOME/.cache/s4d"

    # ── Hyprland main config ──
    cat > "$HOME/.config/hypr/hyprland.conf" << 'HYPRCONF'
# ╔══════════════════════════════════════════════════════════════╗
# ║  s4d Hyprland — Modular Configuration                       ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Monitor ──
monitor = , preferred, auto, auto

# ── Variables ──
$terminal    = kitty
$fileManager = dolphin
$menu        = rofi -show drun
$browser     = firefox
$editor      = code
$mainMod     = SUPER

# ── Autostart ──
exec-once = waybar #BAR_WAYBAR
# exec-once = dms run #BAR_DMS
exec-once = swaync #SWAYNC_LINE
exec-once = swww-daemon && sleep 0.5 && ~/.config/hypr/scripts/wallpaper.sh restore
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 #POLKIT_LINE
exec-once = udiskie &
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = hypridle #HYPRIDLE_LINE

# ── Source Modules ──
source = ~/.config/hypr/colors/catppuccin-mocha.conf
source = ~/.config/hypr/settings/env.conf
source = ~/.config/hypr/settings/input.conf
source = ~/.config/hypr/settings/general.conf
source = ~/.config/hypr/settings/misc.conf
source = ~/.config/hypr/themes/decoration.conf
source = ~/.config/hypr/animations.conf
source = ~/.config/hypr/keybinds/keybinds.conf
source = ~/.config/hypr/keybinds/windowrules.conf
HYPRCONF

    # ── Animation router ──
    cat > "$HOME/.config/hypr/animations.conf" << 'EOF'
# Animation preset — managed by s4d-theme
source = ~/.config/hypr/animations/smooth.conf
EOF

    # ── Smooth animation preset ──
    cat > "$HOME/.config/hypr/animations/smooth.conf" << 'EOF'
animations {
    enabled = true
    bezier = smooth, 0.25, 0.1, 0.25, 1
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1
    bezier = overshot, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 5, overshot, slide
    animation = windowsOut, 1, 4, smoothOut, slide
    animation = windowsMove, 1, 4, smooth
    animation = border, 1, 10, default
    animation = fade, 1, 5, smoothIn
    animation = fadeDim, 1, 5, smoothIn
    animation = workspaces, 1, 5, overshot, slidevert
}
EOF

    # ── Colors ──
    cat > "$HOME/.config/hypr/colors/catppuccin-mocha.conf" << 'EOF'
$rosewater = rgb(f5e0dc)
$flamingo  = rgb(f2cdcd)
$pink      = rgb(f5c2e7)
$mauve     = rgb(cba6f7)
$red       = rgb(f38ba8)
$maroon    = rgb(eba0ac)
$peach     = rgb(fab387)
$yellow    = rgb(f9e2af)
$green     = rgb(a6e3a1)
$teal      = rgb(94e2d5)
$sky       = rgb(89dceb)
$sapphire  = rgb(74c7ec)
$blue      = rgb(89b4fa)
$lavender  = rgb(b4befe)
$text      = rgb(cdd6f4)
$subtext1  = rgb(bac2de)
$subtext0  = rgb(a6adc8)
$overlay2  = rgb(9399b2)
$overlay1  = rgb(7f849c)
$overlay0  = rgb(6c7086)
$surface2  = rgb(585b70)
$surface1  = rgb(45475a)
$surface0  = rgb(313244)
$base      = rgb(1e1e2e)
$mantle    = rgb(181825)
$crust     = rgb(11111b)
EOF

    # ── Env ──
    cat > "$HOME/.config/hypr/settings/env.conf" << 'EOF'
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = XCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_STYLE_OVERRIDE,kvantum-dark
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = GDK_BACKEND,wayland,x11
env = MOZ_ENABLE_WAYLAND,1
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
env = CLUTTER_BACKEND,wayland
EOF

    # ── Input ──
    cat > "$HOME/.config/hypr/settings/input.conf" << 'EOF'
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = false
        tap-to-click = true
        drag_lock = false
        disable_while_typing = true
    }
}
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}
EOF

    # ── General ──
    cat > "$HOME/.config/hypr/settings/general.conf" << 'EOF'
general {
    gaps_in = 4
    gaps_out = 8
    border_size = 2
    col.active_border = $mauve $blue 45deg
    col.inactive_border = $surface0
    layout = dwindle
    allow_tearing = false
}
dwindle {
    pseudotile = true
    preserve_split = true
    smart_split = false
}
master {
    new_status = master
}
EOF

    # ── Misc ──
    cat > "$HOME/.config/hypr/settings/misc.conf" << 'EOF'
misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    disable_splash_rendering = true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
    vfr = true
    vrr = 1
}
binds {
    workspace_back_and_forth = true
    allow_workspace_cycles = true
}
xwayland {
    force_zero_scaling = true
}
cursor {
    no_hardware_cursors = true
}
EOF

    # ── Decoration ──
    cat > "$HOME/.config/hypr/themes/decoration.conf" << 'EOF'
decoration {
    rounding = 10
    active_opacity = 1.0
    inactive_opacity = 0.92
    fullscreen_opacity = 1.0
    blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
        ignore_opacity = true
        xray = false
    }
    shadow {
        enabled = true
        range = 20
        render_power = 3
        color = rgba(00000055)
    }
}
EOF

    # ── Keybinds ──
    cat > "$HOME/.config/hypr/keybinds/keybinds.conf" << 'EOF'
$mainMod = SUPER

# Apps
bind = $mainMod, T, exec, $terminal
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, A, exec, $menu
bind = $mainMod, B, exec, $browser
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, V, togglefloating
bind = $mainMod, F, fullscreen
bind = $mainMod, P, pseudo
bind = $mainMod, J, togglesplit
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, N, exec, swaync-client -t -sw

# Screenshots
bind = , Print, exec, ~/.config/hypr/scripts/screenshot.sh area
bind = SHIFT, Print, exec, ~/.config/hypr/scripts/screenshot.sh full
bind = $mainMod, Print, exec, ~/.config/hypr/scripts/screenshot.sh active

# Volume
bind = , XF86AudioRaiseVolume, exec, ~/.config/hypr/scripts/volume.sh up
bind = , XF86AudioLowerVolume, exec, ~/.config/hypr/scripts/volume.sh down
bind = , XF86AudioMute, exec, ~/.config/hypr/scripts/volume.sh mute

# Brightness
bind = , XF86MonBrightnessUp, exec, ~/.config/hypr/scripts/brightness.sh up
bind = , XF86MonBrightnessDown, exec, ~/.config/hypr/scripts/brightness.sh down

# Media
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspaces
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

# Move to workspace
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

# Mouse
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF

    # ── Window rules ──
    cat > "$HOME/.config/hypr/keybinds/windowrules.conf" << 'EOF'
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, class:^(qt5ct)$
windowrulev2 = float, class:^(qt6ct)$
windowrulev2 = float, title:^(Picture-in-Picture)$
windowrulev2 = float, title:^(Open File)$
windowrulev2 = float, title:^(Save File)$
windowrulev2 = center, floating:1
windowrulev2 = opacity 0.88 0.85, class:^(kitty)$
windowrulev2 = opacity 0.92 0.90, class:^(Code|code|code-oss)$
EOF

    # ── Wallpaper script ──
    cat > "$HOME/.config/hypr/scripts/wallpaper.sh" << 'WALLSCRIPT'
#!/usr/bin/env bash
set -euo pipefail
WALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/s4d/wallpapers"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/s4d/current_wallpaper"
mkdir -p "$(dirname "$CACHE")" "$WALL_DIR"
set_wall() { swww img "$1" --transition-type grow --transition-duration 2 && echo "$1" > "$CACHE"; }
case "${1:-restore}" in
    set) [[ -f "$2" ]] && set_wall "$2" ;;
    random) f=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n1); [[ -n "$f" ]] && set_wall "$f" ;;
    restore) [[ -f "$CACHE" ]] && [[ -f "$(cat "$CACHE")" ]] && set_wall "$(cat "$CACHE")" ;;
    *) echo "Usage: wallpaper.sh {set <path>|random|restore}" ;;
esac
WALLSCRIPT
    chmod +x "$HOME/.config/hypr/scripts/wallpaper.sh"

    # ── Volume script ──
    cat > "$HOME/.config/hypr/scripts/volume.sh" << 'VOLSCRIPT'
#!/usr/bin/env bash
case "${1:-}" in
    up) pamixer -i 5 ;; down) pamixer -d 5 ;; mute) pamixer -t ;;
esac
vol=$(pamixer --get-volume 2>/dev/null || echo 0)
muted=$(pamixer --get-mute 2>/dev/null || echo false)
[[ "$muted" == "true" ]] && icon="audio-volume-muted" || icon="audio-volume-high"
notify-send -h int:value:$vol -h string:x-canonical-private-synchronous:volume -i "$icon" "Volume: ${vol}%" 2>/dev/null || true
VOLSCRIPT
    chmod +x "$HOME/.config/hypr/scripts/volume.sh"

    # ── Brightness script ──
    cat > "$HOME/.config/hypr/scripts/brightness.sh" << 'BRSCRIPT'
#!/usr/bin/env bash
case "${1:-}" in
    up) brightnessctl set +5% ;; down) brightnessctl set 5%- ;;
esac
pct=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
notify-send -h int:value:$pct -h string:x-canonical-private-synchronous:brightness -i display-brightness "Brightness: ${pct}%" 2>/dev/null || true
BRSCRIPT
    chmod +x "$HOME/.config/hypr/scripts/brightness.sh"

    # ── Screenshot script ──
    cat > "$HOME/.config/hypr/scripts/screenshot.sh" << 'SSSCRIPT'
#!/usr/bin/env bash
set -euo pipefail
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"; mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
case "${1:-area}" in
    full) grim "$FILE" ;; area) grim -g "$(slurp)" "$FILE" || exit 0 ;;
    active) geo=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null) && grim -g "$geo" "$FILE" || grim "$FILE" ;;
esac
wl-copy < "$FILE" 2>/dev/null || true
notify-send -i "$FILE" "Screenshot" "Saved & copied" 2>/dev/null || true
SSSCRIPT
    chmod +x "$HOME/.config/hypr/scripts/screenshot.sh"

    # ── Hyprlock ──
    cat > "$HOME/.config/hypr/hyprlock.conf" << 'EOF'
general {
    disable_loading_bar = false
    hide_cursor = true
    grace = 0
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

    # ── Hypridle ──
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

    # ── Kitty ──
    cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
font_family      JetBrainsMono Nerd Font
font_size        11.0
cursor_shape     beam
scrollback_lines 10000
window_padding_width 8 12
hide_window_decorations yes
confirm_os_window_close 0
background_opacity 0.88
tab_bar_style    powerline
enable_audio_bell no
foreground       #CDD6F4
background       #1E1E2E
color0  #45475A
color8  #585B70
color1  #F38BA8
color9  #F38BA8
color2  #A6E3A1
color10 #A6E3A1
color3  #F9E2AF
color11 #F9E2AF
color4  #89B4FA
color12 #89B4FA
color5  #F5C2E7
color13 #F5C2E7
color6  #94E2D5
color14 #94E2D5
color7  #BAC2DE
color15 #A6ADC8
EOF

    # ── Waybar ──
    cat > "$HOME/.config/waybar/config.jsonc" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "margin-top": 5,
    "margin-left": 10,
    "margin-right": 10,
    "spacing": 10,
    "reload_style_on_change": true,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "custom/power"],
    "hyprland/workspaces": { "on-click": "activate", "format": "{name}" },
    "clock": { "format": "{:%H:%M — %b %d}" },
    "pulseaudio": { "format": "{icon} {volume}%", "format-muted": "  muted", "format-icons": { "default": ["", "", ""] }, "on-click": "pamixer -t" },
    "network": { "format-wifi": "  {essid}", "format-disconnected": "󰖪  Offline" },
    "battery": { "format": "{icon} {capacity}%", "format-icons": [" ", " ", " ", " "] },
    "custom/power": { "format": "", "on-click": "wlogout -b 4", "tooltip-format": "Power Menu" }
}
EOF

    cat > "$HOME/.config/waybar/style.css" << 'EOF'
@import "mocha.css";
* { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; min-height: 0; }
window#waybar { background: transparent; color: @text; }
#workspaces button { padding: 0 6px; color: @subtext0; border-radius: 8px; }
#workspaces button.active { background: alpha(@mauve, 0.3); color: @mauve; }
#clock, #pulseaudio, #network, #battery, #custom-power { padding: 0 12px; background: alpha(@base, 0.7); border-radius: 10px; }
EOF

    cat > "$HOME/.config/waybar/mocha.css" << 'EOF'
@define-color base #1e1e2e; @define-color mantle #181825; @define-color crust #11111b;
@define-color text #cdd6f4; @define-color subtext0 #a6adc8; @define-color subtext1 #bac2de;
@define-color surface0 #313244; @define-color surface1 #45475a; @define-color surface2 #585b70;
@define-color overlay0 #6c7086; @define-color mauve #cba6f7; @define-color blue #89b4fa;
@define-color green #a6e3a1; @define-color red #f38ba8; @define-color peach #fab387;
@define-color yellow #f9e2af; @define-color lavender #b4befe; @define-color rosewater #f5e0dc;
EOF

    # ── Rofi ──
    cat > "$HOME/.config/rofi/config.rasi" << 'EOF'
configuration {
    modi: "drun,run,filebrowser";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    font: "JetBrainsMono Nerd Font 11";
    drun-display-format: "{name}";
}
@theme "catppuccin-mocha"
EOF

    cat > "$HOME/.config/rofi/catppuccin-mocha.rasi" << 'EOF'
* { bg: #1e1e2e; bg-alt: #313244; fg: #cdd6f4; accent: #cba6f7; background-color: transparent; text-color: @fg; margin: 0; padding: 0; }
window { width: 600px; border-radius: 12px; background-color: @bg; border: 2px solid; border-color: @accent; }
mainbox { padding: 12px; }
inputbar { background-color: @bg-alt; padding: 10px 12px; border-radius: 8px; margin-bottom: 12px; children: [prompt, entry]; }
prompt { padding: 0 8px 0 0; text-color: @accent; }
entry { placeholder: "Search..."; }
listview { lines: 8; fixed-height: true; scrollbar: false; }
element { padding: 10px 12px; border-radius: 8px; }
element selected { background-color: @bg-alt; text-color: @accent; }
element-icon { size: 24px; margin-right: 12px; }
element-text { vertical-align: 0.5; }
EOF

    # ── SwayNC ──
    cat > "$HOME/.config/swaync/config.json" << 'EOF'
{
    "positionX": "right",
    "positionY": "top",
    "layer": "overlay",
    "control-center-width": 400,
    "notification-window-width": 380,
    "timeout": 8,
    "timeout-low": 4,
    "timeout-critical": 0,
    "keyboard-shortcuts": true,
    "image-visibility": "when-available",
    "transition-time": 200,
    "widgets": ["title", "dnd", "notifications"],
    "widget-config": {
        "title": { "text": "Notifications", "clear-all-button": true, "button-text": "Clear" },
        "dnd": { "text": "Do Not Disturb" }
    }
}
EOF

    # ── Wlogout ──
    cat > "$HOME/.config/wlogout/layout" << 'EOF'
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
{
    "label" : "logout",
    "action" : "hyprctl dispatch exit",
    "text" : "Logout",
    "keybind" : "e"
}
{
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Shutdown",
    "keybind" : "s"
}
{
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Reboot",
    "keybind" : "r"
}
{
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Suspend",
    "keybind" : "u"
}
EOF

    # ── GTK ──
    cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-application-prefer-dark-theme=1
EOF

    log "${OK} Minimal configurations created"
}

#=============================================================================
# CONFIGURE STATUS BAR IN HYPRLAND.CONF
# Uses S4D_STATUS_BAR env var (waybar or dankms) exported from install.sh
#=============================================================================
configure_status_bar() {
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    local bar_choice="${S4D_STATUS_BAR:-waybar}"

    if [[ ! -f "$hypr_conf" ]]; then
        log "${WARN} hyprland.conf not found, skipping bar configuration"
        return
    fi

    log "${INFO} Configuring status bar: $bar_choice"

    if [[ "$bar_choice" == "dankms" ]]; then
        # Enable DMS, disable Waybar
        sed -i 's/^exec-once = waybar.*#BAR_WAYBAR/# exec-once = waybar #BAR_WAYBAR/' "$hypr_conf"
        sed -i 's/^# exec-once = dms run.*#BAR_DMS/exec-once = dms run #BAR_DMS/' "$hypr_conf"

        # DMS replaces swaync, hypridle, and polkit — comment them out
        sed -i 's/^exec-once = swaync.*#SWAYNC_LINE/# exec-once = swaync #SWAYNC_LINE/' "$hypr_conf"
        sed -i 's/^exec-once = hypridle.*#HYPRIDLE_LINE/# exec-once = hypridle #HYPRIDLE_LINE/' "$hypr_conf"
        sed -i 's|^exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1.*#POLKIT_LINE|# exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 #POLKIT_LINE|' "$hypr_conf"

        log "${OK} DankMaterialShell configured (waybar, swaync, hypridle, polkit disabled)"
    else
        # Enable Waybar, disable DMS
        sed -i 's/^# exec-once = waybar.*#BAR_WAYBAR/exec-once = waybar #BAR_WAYBAR/' "$hypr_conf"
        sed -i 's/^exec-once = dms run.*#BAR_DMS/# exec-once = dms run #BAR_DMS/' "$hypr_conf"

        # Ensure swaync, hypridle, polkit are enabled for Waybar setup
        sed -i 's/^# exec-once = swaync.*#SWAYNC_LINE/exec-once = swaync #SWAYNC_LINE/' "$hypr_conf"
        sed -i 's/^# exec-once = hypridle.*#HYPRIDLE_LINE/exec-once = hypridle #HYPRIDLE_LINE/' "$hypr_conf"
        sed -i 's|^# exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1.*#POLKIT_LINE|exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 #POLKIT_LINE|' "$hypr_conf"

        log "${OK} Waybar configured as status bar"
    fi
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

# Configure the status bar based on user choice AFTER dotfiles are in place
configure_status_bar

log "${OK} Dotfiles application complete"
