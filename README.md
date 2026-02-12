# s4d Hyprland

A minimal, bloat-free Hyprland installation script for Arch Linux.

```
    ███████╗  ██╗  ██╗  ██████╗
    ██╔════╝  ██║  ██║  ██╔══██╗
    ███████╗  ███████║  ██║  ██║
    ╚════██║  ╚════██║  ██║  ██║
    ███████║       ██║  ██████╔╝
    ╚══════╝       ╚═╝  ╚═════╝

    Minimal Hyprland  ·  Arch Linux
```

## Quick Install

### One-liner (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sadbin47/s4d_hyprland/main/install.sh)
```

> **Note:** The script will automatically clone the repo to `~/s4d_hyprland` and launch the interactive installer.

### Or clone and run manually

```bash
git clone https://github.com/Sadbin47/s4d_hyprland.git
cd s4d_hyprland
./install.sh
```

## Requirements

- Fresh Arch Linux installation (base system)
- Internet connection
- Non-root user with sudo privileges

```bash
# If you need git and base-devel (script will install git if missing):
sudo pacman -S --needed git base-devel
```

## Features

- **Bloat-Free** — Only essential packages, no unnecessary software
- **GPU Auto-Detection** — NVIDIA, AMD, Intel including hybrid laptops
- **Interactive TUI** — Gradient-styled menus with live installation progress
- **Modular Config** — Easy to customize and extend
- **ROG Support** — Optional ASUS ROG laptop support
- **Catppuccin Mocha** — Beautiful dark color scheme by default

## Components

| Component | Options |
|-----------|---------|
| **Display Manager** | SDDM, Ly (TUI), or None (TTY) |
| **Status Bar** | Waybar or DankMaterialShell |
| **Terminal** | Kitty |
| **App Launcher** | Rofi |
| **Notifications** | SwayNC |
| **Wallpaper** | SWWW (smooth transitions) |
| **Lock Screen** | Hyprlock (+ optional Wlogout) |
| **Idle Manager** | Hypridle |
| **File Manager** | Dolphin |

## Installation Process

### Step 1: Run the Installer

The script presents an interactive TUI with gradient-colored menus:

```
    ███████╗  ██╗  ██╗  ██████╗
    ██╔════╝  ██║  ██║  ██╔══██╗
    ███████╗  ███████║  ██║  ██║
    ╚════██║  ╚════██║  ██║  ██║
    ███████║       ██║  ██████╔╝
    ╚══════╝       ╚═╝  ╚═════╝

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Configure Installation
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Display Manager
    1 › SDDM (Feature-rich)
    2 › Ly (Minimal TUI)
    3 › None (TTY Login)

  Status Bar
    1 › Waybar (Feature-rich)
    2 › DankMaterialShell (Modern Desktop Shell)

  Lockscreen
    1 › Hyprlock
    2 › Hyprlock + Wlogout

  ...
```

### Step 2: Review & Confirm

After configuration, you'll see a summary of your choices before proceeding.

### Step 3: Live Installation

The installer shows live progress with status indicators:

```
  Installing

  ● Setting up AUR helper
  ● Installing base packages
  ● Detecting GPU & drivers
  ◌ Installing Hyprland
    [i] Installing hyprland...
```

Each step shows a live sub-line with the current operation. Green `●` = complete, dim `◌` = in progress.

### Step 4: Reboot

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Installation Complete
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Keybinds
    Super + T       Terminal
    Super + A       App Launcher
    Super + E       File Manager
    Super + Q       Close Window
    Super + L       Lock
    Super + X       Power Menu
    Super + /       All Keybinds

  Reboot now? [y/N] ▸
```

## Keybindings

### Applications
| Key | Action |
|-----|--------|
| `Super + T` | Terminal (Kitty) |
| `Super + A` | App Launcher (Rofi) |
| `Super + E` | File Manager |
| `Super + B` | Browser |
| `Super + C` | Editor |

### Window Management
| Key | Action |
|-----|--------|
| `Super + Q` | Close Window |
| `Super + Shift + Q` | Kill Process |
| `Super + F` | Fullscreen |
| `Super + Shift + F` | Maximize |
| `Super + V` | Toggle Floating |
| `Super + P` | Pseudo-tile |
| `Super + D` | Toggle Split |
| `Super + G` | Toggle Group |
| `Super + [ / ]` | Prev / Next in Group |

### Navigation
| Key | Action |
|-----|--------|
| `Super + ←↑↓→` | Focus Window |
| `Super + Shift + ←↑↓→` | Move Window |
| `Super + Ctrl + ←↑↓→` | Resize Window |
| `Super + Alt + Shift + ←↑↓→` | Swap Window |
| `Super + 1-0` | Switch Workspace |
| `Super + Shift + 1-0` | Move to Workspace |
| `Super + Tab / Shift+Tab` | Cycle Workspaces |
| `Super + S` | Scratchpad |
| `Super + Shift + S` | Move to Scratchpad |

### Lock Screen & Power
| Key | Action |
|-----|--------|
| `Super + L` | Lock Screen (blur + dim 30%) |
| `Super + Escape` | Lock Screen |
| `Super + X` | Power Menu (wlogout) |
| `Super + Delete` | Restart Hyprland (reload config) |
| `Ctrl + Alt + Delete` | Exit Hyprland |

### Waybar & Wallpaper (waybar mode only — no conflict with DMS)
| Key | Action |
|-----|--------|
| `Super + Alt + →` | Next Waybar Layout |
| `Super + Alt + ←` | Previous Waybar Layout |
| `Super + Alt + ↑` | Next Wallpaper |
| `Super + Alt + ↓` | Previous Wallpaper |
| `Super + W` | Cycle Waybar CSS Style |
| `Super + Shift + W` | Waybar Menu (rofi — styles/layouts/position) |
| `Super + Alt + P` | Cycle Bar Position (Top → Bottom → Left → Right) |
| `Super + Alt + W` | Random Wallpaper |
| `Super + Shift + N` | Wallpaper Select (rofi) |

### Screenshots
| Key | Action |
|-----|--------|
| `Print` | Screenshot (area to clipboard) |
| `Shift + Print` | Screenshot (fullscreen to clipboard) |
| `Super + Print` | Screenshot (area to file) |
| `Super + Shift + Print` | Screenshot (area to editor) |

### Utilities
| Key | Action |
|-----|--------|
| `Super + N` | Notification Center |
| `Super + Shift + C` | Color Picker |
| `Super + Shift + V` | Clipboard History |
| `Super + Shift + T` | Toggle Touchpad |
| `Super + /` | Keybindings Help |

## Directory Structure

```
s4d_hyprland/
├── install.sh                      # Main installer with TUI
├── README.md
├── Configs/                        # Default configuration files
│   ├── hypr/                      # Hyprland (modular)
│   │   ├── hyprland.conf          # Main entry — sources all modules
│   │   ├── monitors.conf          # Monitor layout (user-editable)
│   │   ├── userprefs.conf         # Personal overrides
│   │   ├── animations.conf        # Router to animation presets
│   │   ├── hyprlock.conf          # Lock screen config
│   │   ├── hypridle.conf          # Idle manager config
│   │   ├── animations/            # Swappable animation presets
│   │   │   ├── smooth.conf
│   │   │   ├── dynamic.conf
│   │   │   ├── fast.conf
│   │   │   ├── material.conf
│   │   │   ├── minimal.conf
│   │   │   └── disabled.conf
│   │   ├── colors/
│   │   │   ├── catppuccin-mocha.conf
│   │   │   └── catppuccin-latte.conf
│   │   ├── settings/
│   │   │   ├── env.conf
│   │   │   ├── input.conf
│   │   │   ├── general.conf
│   │   │   ├── misc.conf
│   │   │   ├── nvidia.conf
│   │   │   ├── amd.conf
│   │   │   ├── intel.conf
│   │   │   └── rog.conf
│   │   ├── themes/
│   │   │   └── decoration.conf
│   │   ├── keybinds/
│   │   │   ├── keybinds.conf
│   │   │   ├── keybinds-bar.conf     # Waybar-only binds (not loaded with DMS)
│   │   │   └── windowrules.conf
│   │   ├── shaders/
│   │   │   ├── blue-light-filter.glsl
│   │   │   └── vibrance.glsl
│   │   └── scripts/
│   │       ├── wallpaper.sh
│   │       ├── screenshot.sh
│   │       ├── volume.sh
│   │       ├── brightness.sh
│   │       ├── touchpad.sh
│   │       ├── colorpicker.sh
│   │       ├── s4d-theme.sh
│   │       ├── waybar-style.sh
│   │       └── keybinds-help.sh
│   ├── waybar/
│   │   ├── config.jsonc
│   │   ├── style.css
│   │   ├── mocha.css
│   │   ├── vertical.css              # Auto-toggled for left/right position
│   │   ├── styles/
│   │   │   ├── default.css
│   │   │   ├── hollow.css
│   │   │   ├── solid.css
│   │   │   ├── minimal.css
│   │   │   ├── flat.css
│   │   │   ├── compact.css
│   │   │   └── floating.css
│   │   └── layouts/
│   │       ├── full.jsonc
│   │       ├── minimal.jsonc
│   │       ├── sysmon.jsonc
│   │       ├── centered.jsonc
│   │       ├── dock.jsonc
│   │       ├── split.jsonc
│   │       ├── powerline.jsonc
│   │       ├── focus.jsonc
│   │       ├── islands.jsonc
│   │       ├── topright.jsonc
│   │       ├── statusline.jsonc
│   │       ├── dashboard.jsonc
│   │       ├── macos.jsonc
│   │       └── kanji.jsonc
│   ├── rofi/
│   │   ├── config.rasi
│   │   ├── catppuccin-mocha.rasi
│   │   └── scripts/power-menu.sh
│   ├── swaync/
│   │   ├── config.json
│   │   └── style.css
│   ├── kitty/kitty.conf
│   ├── wlogout/
│   │   ├── layout
│   │   └── style.css
│   ├── fastfetch/config.jsonc
│   ├── starship/starship.toml
│   ├── zsh/
│   │   ├── .zshrc
│   │   └── .zprofile
│   ├── gtk-3.0/settings.ini
│   ├── gtk-4.0/settings.ini
│   ├── qt5ct/qt5ct.conf
│   └── qt6ct/qt6ct.conf
├── Packages/
│   ├── base.lst
│   ├── hyprland.lst
│   └── fonts.lst
└── Scripts/
    ├── functions.sh
    ├── gpu-detect.sh
    ├── dotfiles-apply.sh
    ├── themes-install.sh
    ├── wallpaper-setup.sh
    ├── sddm-install.sh
    ├── ly-install.sh
    ├── waybar-install.sh
    ├── dankms-install.sh
    ├── dolphin-install.sh
    ├── fonts-install.sh
    ├── bluetooth-install.sh
    ├── rog-install.sh
    ├── zsh-install.sh
    └── post-install.sh
```

## s4d-theme — Theme Manager CLI

Switch animation presets, color palettes, and wallpapers on the fly:

```bash
# List / switch animation presets
s4d-theme animation list
s4d-theme animation set dynamic

# Switch color palette
s4d-theme color set catppuccin-latte

# Wallpaper management
s4d-theme wallpaper random
s4d-theme wallpaper set ~/Pictures/wall.png

# Show current theme
s4d-theme status
```

## Waybar Style Switcher

Change your status bar appearance, layout, and position on the fly:

```bash
# Interactive rofi menu (Super + Shift + W)
waybar-style.sh rofi

# Cycle CSS styles (Super + W)
waybar-style.sh next
waybar-style.sh prev

# Set directly
waybar-style.sh set hollow
waybar-style.sh set floating

# Switch layout (Super + Alt + →/←)
waybar-style.sh layout next
waybar-style.sh layout set centered
waybar-style.sh layout set islands

# Cycle bar position (Super + Alt + P)
waybar-style.sh position next
waybar-style.sh position left
waybar-style.sh position bottom
```

**Available styles (7):** default, compact, flat, floating, hollow, minimal, solid

**Available layouts (14):** full, minimal, sysmon, centered, dock, split, powerline, focus, islands, topright, statusline, dashboard, macos, kanji

**Positions:** top, bottom, left, right — left/right auto-converts to vertical sidebar mode

> **Note:** Waybar keybinds are in `keybinds-bar.conf` and only loaded when waybar is the active bar. When DankMaterialShell is active, these binds stay disabled — zero conflicts.

## GPU Support

The installer automatically detects and configures:

- **NVIDIA** — Installs proprietary drivers, configures mkinitcpio, GRUB
- **AMD** — Installs Mesa, Vulkan, and VA-API drivers
- **Intel** — Installs Mesa and Intel Media driver
- **Hybrid** — Supports laptops with multiple GPUs

## Custom Dotfiles

You can use your own dotfiles:

```bash
./install.sh
# Choose "custom" when prompted for dotfiles
# Enter your git repository URL
```

Your repository should have one of these structures:
- `.config/` folder with configs
- `config/` folder with configs
- Individual folders (hypr, kitty, rofi, etc.)

## Theme

The default theme uses **Catppuccin Mocha** color scheme:

- Base: `#1e1e2e`
- Text: `#cdd6f4`
- Accent: `#cba6f7` (Mauve)

## Logs

Installation logs are saved to:
```
./Logs/install-YYYYMMDD-HHMMSS.log
```

## Troubleshooting

### Hyprland doesn't start
- Check GPU drivers are installed correctly
- For NVIDIA, ensure nvidia modules are in mkinitcpio.conf
- Check logs: `cat ~/.local/share/hyprland/hyprland.log`

### Screen tearing (NVIDIA)
- Ensure `nvidia-drm.modeset=1` is in kernel parameters
- Check `~/.config/hypr/nvidia.conf` is sourced

### No audio
- Ensure pipewire services are running:
  ```bash
  systemctl --user status pipewire pipewire-pulse wireplumber
  ```

### Ly display manager not starting
- Verify the service is enabled: `systemctl is-enabled ly@tty2.service`
- Check getty is masked: `systemctl is-enabled getty@tty2.service`
- Ensure graphical target: `systemctl get-default` should show `graphical.target`

### Dolphin looks wrong (black text, broken theme)
- Ensure Kvantum is installed: `pacman -Q kvantum`
- Check qt5ct style is set: open `qt5ct` and verify style is `kvantum-dark`
- Re-run theme setup: `~/.config/hypr/scripts/s4d-theme.sh`

## Credits

- [Hyprland](https://hyprland.org/) — Wayland compositor
- [Catppuccin](https://github.com/catppuccin) — Color scheme
- [BlackNode](https://github.com/Jexxar/BlackNode) — Modular config architecture inspiration
- [HyDE](https://github.com/prasanthrangan/hyprdots) — Shader system & wallbash concepts
- [HyprFlux](https://github.com/Jexxar/HyprFlux) — Animation presets design
- [JaKooLit](https://github.com/JaKooLit) — KooL Hyprland install patterns
- [omarchy](https://github.com/dhh/omarchy) — Clean theme system & starship prompt
- [DankMaterialShell](https://github.com/user/DankMaterialShell) — Desktop shell alternative

## License

MIT License - feel free to use and modify!

---

Made with love for the Arch + Hyprland community
