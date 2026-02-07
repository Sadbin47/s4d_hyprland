#!/bin/bash
#=============================================================================
# DOTFILES APPLICATION
# Usage: source dotfiles-apply.sh {default|custom <url>|minimal}
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIGS_DIR="$SCRIPT_DIR/../Configs"
MODE="${1:-default}"
CUSTOM_URL="${2:-}"
STATUS_BAR="${S4D_STATUS_BAR:-waybar}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"

log "${INFO} Applying dotfiles (mode: $MODE)..."

#=============================================================================
# BACKUP existing configs
#=============================================================================
backup_configs() {
    local dirs_to_backup=(hypr waybar rofi swaync kitty wlogout fastfetch)
    local backed_up=false

    for d in "${dirs_to_backup[@]}"; do
        if [[ -d "$HOME/.config/$d" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$HOME/.config/$d" "$BACKUP_DIR/" 2>/dev/null
            backed_up=true
        fi
    done

    $backed_up && log "${INFO} Existing configs backed up to $BACKUP_DIR"
}

#=============================================================================
# DEFAULT: Copy from Configs/ directory
#=============================================================================
apply_default() {
    log "${INFO} Applying default s4d dotfiles..."

    # These directories from Configs/ go to ~/.config/
    local config_dirs=(hypr waybar rofi swaync kitty wlogout fastfetch)

    for d in "${config_dirs[@]}"; do
        if [[ -d "$CONFIGS_DIR/$d" ]]; then
            mkdir -p "$HOME/.config/$d"
            cp -rf "$CONFIGS_DIR/$d/"* "$HOME/.config/$d/" 2>/dev/null || true
            log "${OK} Applied $d config"
        fi
    done

    # Zsh: .zshrc and .zprofile go to $HOME (not ~/.config/zsh/)
    if [[ -d "$CONFIGS_DIR/zsh" ]]; then
        [[ -f "$CONFIGS_DIR/zsh/.zshrc" ]] && cp -f "$CONFIGS_DIR/zsh/.zshrc" "$HOME/.zshrc" 2>/dev/null && log "${OK} Applied .zshrc"
        [[ -f "$CONFIGS_DIR/zsh/.zprofile" ]] && cp -f "$CONFIGS_DIR/zsh/.zprofile" "$HOME/.zprofile" 2>/dev/null && log "${OK} Applied .zprofile"
    fi

    # Starship: goes directly to ~/.config/starship.toml (not in subdirectory)
    if [[ -f "$CONFIGS_DIR/starship/starship.toml" ]]; then
        cp -f "$CONFIGS_DIR/starship/starship.toml" "$HOME/.config/starship.toml" 2>/dev/null || true
        log "${OK} Applied starship config"
    fi

    # Make scripts executable
    chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true

    configure_status_bar
}

#=============================================================================
# CUSTOM: Clone from git URL
#=============================================================================
apply_custom() {
    local url="$1"

    if [[ -z "$url" ]]; then
        log "${ERROR} No git URL provided"
        apply_minimal
        return
    fi

    log "${INFO} Cloning custom dotfiles from $url..."

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone --depth 1 "$url" "$tmp_dir" 2>/dev/null; then
        # Look for .config directory inside the clone
        local config_src=""
        if [[ -d "$tmp_dir/.config" ]]; then
            config_src="$tmp_dir/.config"
        elif [[ -d "$tmp_dir/config" ]]; then
            config_src="$tmp_dir/config"
        elif [[ -d "$tmp_dir" ]]; then
            config_src="$tmp_dir"
        fi

        if [[ -n "$config_src" ]]; then
            cp -rf "$config_src/"* "$HOME/.config/" 2>/dev/null || true
            log "${OK} Custom dotfiles applied"
        fi
    else
        log "${WARN} Could not clone $url — falling back to minimal"
        rm -rf "$tmp_dir"
        apply_minimal
        return
    fi
    rm -rf "$tmp_dir"

    configure_status_bar
}

#=============================================================================
# MINIMAL: Create bare-essentials configs inline
#=============================================================================
apply_minimal() {
    log "${INFO} Creating minimal Hyprland config..."

    mkdir -p "$HOME/.config/hypr/scripts"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/rofi"

    # Minimal hyprland.conf
    cat > "$HOME/.config/hypr/hyprland.conf" << 'HYPREOF'
# s4d Hyprland — Minimal Config

monitor = ,preferred,auto,auto

$terminal = kitty
$fileManager = dolphin
$menu = rofi -show drun -show-icons
$mainMod = SUPER

# Autostart
exec-once = waybar
exec-once = swaync
exec-once = swww-daemon && wallpaper restore
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = udiskie --automount --notify

# Environment
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Bibata-Modern-Classic
env = QT_QPA_PLATFORMTHEME,qt5ct
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = QT_QPA_PLATFORM,wayland
env = GDK_BACKEND,wayland,x11
env = MOZ_ENABLE_WAYLAND,1

# Look
general {
    gaps_in = 3
    gaps_out = 7
    border_size = 2
    col.active_border = rgb(cba6f7) rgb(89b4fa) 45deg
    col.inactive_border = rgb(45475a)
    layout = dwindle
}

decoration {
    rounding = 10
    active_opacity = 1.0
    inactive_opacity = 0.92
    shadow {
        enabled = true
        range = 8
        render_power = 3
        color = rgba(00000055)
    }
    blur {
        enabled = true
        size = 6
        passes = 3
    }
}

animations {
    enabled = true
    bezier = smooth, 0.25, 0.1, 0.25, 1.0
    animation = windows, 1, 5, smooth, slide
    animation = windowsOut, 1, 5, smooth, slide
    animation = border, 1, 10, default
    animation = fade, 1, 5, smooth
    animation = workspaces, 1, 4, smooth, slide
}

input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = true
        tap_to_click = true
    }
}

dwindle {
    pseudotile = true
    preserve_split = true
}

misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
}

# Keybindings
bind = $mainMod, T, exec, $terminal
bind = $mainMod, Q, killactive,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, A, exec, $menu
bind = $mainMod, V, togglefloating,
bind = $mainMod, F, fullscreen, 0
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, W, exec, ~/.config/hypr/scripts/waybar-style.sh rofi
bind = $mainMod SHIFT, W, exec, wallpaper select
bind = $mainMod, N, exec, swaync-client -t -sw
bind = $mainMod SHIFT, V, exec, cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Copied to clipboard"
bind = SHIFT, Print, exec, grim - | wl-copy && notify-send "Screenshot" "Full screen copied"
bind = $mainMod, Print, exec, grim "$HOME/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png" && notify-send "Screenshot" "Saved"

# Hardware keys
binde = , XF86AudioRaiseVolume, exec, pamixer -i 5
binde = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86AudioMicMute, exec, pamixer --default-source -t
binde = , XF86MonBrightnessUp, exec, brightnessctl set +10%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 10%-
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d
bind = $mainMod, H, movefocus, l
bind = $mainMod, J, movefocus, d
bind = $mainMod, K, movefocus, u
bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, J, movewindow, d
bind = $mainMod SHIFT, K, movewindow, u
bind = $mainMod SHIFT, L, movewindow, r

# Resize
binde = $mainMod CTRL, H, resizeactive, -30 0
binde = $mainMod CTRL, L, resizeactive, 30 0
binde = $mainMod CTRL, K, resizeactive, 0 -30
binde = $mainMod CTRL, J, resizeactive, 0 30

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
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Mouse
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Window rules
windowrule = float, class:^(pavucontrol)$
windowrule = float, class:^(blueman-manager)$
windowrule = float, class:^(nm-connection-editor)$
windowrule = float, title:^(Picture-in-Picture)$
windowrule = float, title:^(Open File)$
windowrule = float, title:^(Save File)$
windowrule = suppress maximize, class:.*
HYPREOF

    # Minimal kitty config
    cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
font_size        12.0
background_opacity 0.92
confirm_os_window_close 0
enable_audio_bell no
window_padding_width 8
background #1e1e2e
foreground #cdd6f4
cursor #f5e0dc
selection_background #585b70
selection_foreground #cdd6f4
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #f5c2e7
color6  #94e2d5
color7  #bac2de
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8
EOF

    # Minimal rofi config
    cat > "$HOME/.config/rofi/config.rasi" << 'EOF'
configuration {
    modi: "drun,run,filebrowser";
    show-icons: true;
    font: "JetBrainsMono Nerd Font 12";
    display-drun: " Apps";
    display-run: " Run";
    display-filebrowser: " Files";
}
@theme "catppuccin-mocha"
EOF

    cat > "$HOME/.config/rofi/catppuccin-mocha.rasi" << 'EOF'
* {
    bg: #1e1e2e;
    bg-alt: #313244;
    fg: #cdd6f4;
    accent: #cba6f7;
    background-color: @bg;
    border: 0;
    margin: 0;
    padding: 0;
    spacing: 0;
}
window {
    width: 35%;
    border: 2px;
    border-color: @accent;
    border-radius: 12px;
}
mainbox { children: [inputbar, listview]; }
inputbar {
    background-color: @bg-alt;
    children: [prompt, entry];
    border-radius: 12px 12px 0 0;
}
prompt {
    background-color: @accent;
    text-color: @bg;
    padding: 12px;
}
entry {
    padding: 12px;
    text-color: @fg;
}
listview {
    lines: 8;
    columns: 1;
    fixed-height: false;
}
element {
    padding: 8px 12px;
    spacing: 12px;
}
element selected {
    background-color: @bg-alt;
    text-color: @accent;
}
element-icon { size: 24px; }
element-text { text-color: inherit; }
EOF

    log "${OK} Minimal dotfiles applied"
    configure_status_bar
}

#=============================================================================
# CONFIGURE STATUS BAR in hyprland autostart
#=============================================================================
configure_status_bar() {
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    [[ ! -f "$hypr_conf" ]] && return

    if [[ "$STATUS_BAR" == "dankms" ]]; then
        # Replace waybar with dms
        sed -i 's/^exec-once = waybar/#exec-once = waybar/' "$hypr_conf"
        sed -i 's/^exec-once = swaync/#exec-once = swaync/' "$hypr_conf"

        if ! grep -q "exec-once = dms run" "$hypr_conf"; then
            echo "" >> "$hypr_conf"
            echo "exec-once = dms run" >> "$hypr_conf"
        fi
        log "${OK} Configured DankMaterialShell as status bar"
    fi
    # Default: waybar is already in the config
}

#=============================================================================
# ENTRY POINT
#=============================================================================
backup_configs

case "$MODE" in
    default) apply_default ;;
    custom)  apply_custom "$CUSTOM_URL" ;;
    minimal) apply_minimal ;;
    *)       apply_default ;;
esac

log "${OK} Dotfiles applied"
