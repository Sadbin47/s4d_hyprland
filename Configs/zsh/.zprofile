# ── s4d Zsh Environment ──
# Sourced before .zshrc on login

# ── XDG Base Directories ──
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Default Programs ──
export EDITOR="nano"
export VISUAL="nano"
export TERMINAL="kitty"
export BROWSER="firefox"

# ── Path ──
typeset -U path PATH
path=(~/.local/bin $path)
export PATH

# ── Wayland / Hyprland ──
export GDK_BACKEND="wayland,x11"
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_STYLE_OVERRIDE="kvantum-dark"
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export SDL_VIDEODRIVER="wayland"
export CLUTTER_BACKEND="wayland"
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
export XDG_CURRENT_DESKTOP="Hyprland"
export XDG_SESSION_TYPE="wayland"
export XDG_SESSION_DESKTOP="Hyprland"

# ── Theme ──
export GTK_THEME="Catppuccin-Mocha-Standard-Mauve-Dark"
export XCURSOR_THEME="Bibata-Modern-Classic"
export XCURSOR_SIZE=24
export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export HYPRCURSOR_SIZE=24

# ── Misc ──
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
export LESSHISTFILE=-
