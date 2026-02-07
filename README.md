# s4d Hyprland

A minimal, bloat-free Hyprland installation script for Arch Linux.

```
╔═══════════════════════════════════════════════════════════════╗
║     _____  ___ _____    _   _                  _              ║
║    /  ___|/ _ \|  _  \ | | | |                | |             ║
║    \ `--.| | | | | | | | |_| |_   _ _ __  _ __| | __ _ _ __   ║
║     `--. \ | | | | | | |  _  | | | | '_ \| '__| |/ _` | '_ \  ║
║    /\__/ / |_| | |/ /  | | | | |_| | |_) | |  | | (_| | | | | ║
║    \____/ \___/|___/   \_| |_/\__, | .__/|_|  |_|\__,_|_| |_| ║
║                                __/ | |                        ║
║                               |___/|_|   Minimal & Clean      ║
╚═══════════════════════════════════════════════════════════════╝
```

## ⚡ Quick Install

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

## 📋 Requirements

- ✅ Fresh Arch Linux installation (base system)
- ✅ Internet connection
- ✅ Non-root user with sudo privileges

```bash
# If you need git and base-devel (script will install git if missing):
sudo pacman -S --needed git base-devel
```

## 🚀 Features

- 🎯 **Bloat-Free**: Only essential packages, no unnecessary software
- 🖥️ **GPU Auto-Detection**: NVIDIA, AMD, Intel - including hybrid laptops
- 🎨 **User Choice**: Select your preferred components interactively
- ⚙️ **Modular Config**: Easy to customize and extend
- 🎮 **ROG Support**: Optional ASUS ROG laptop support
- 🎨 **Catppuccin Theme**: Beautiful Mocha color scheme by default

## 🧩 Components

| Component | Options |
|-----------|---------|
| **Display Manager** | SDDM, Ly, or None (TTY) |
| **Status Bar** | Waybar or DankMaterialShell |
| **Terminal** | Kitty |
| **App Launcher** | Rofi |
| **Notifications** | SwayNC |
| **Wallpaper** | SWWW |
| **Lock Screen** | Hyprlock |
| **Idle Manager** | Hypridle |
| **File Manager** | Dolphin or Nemo |

## 📦 Installation Process

### Step 1: Run the Installer

The script presents an interactive menu to configure your installation:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Configuration Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1. Display Manager: SDDM / Ly / None
 2. Status Bar: Waybar / DankMaterialShell
 3. File Manager: Dolphin / Nemo
 4. Lockscreen: Hyprlock / Both (+ Wlogout)
 5. Dotfiles: Default / Custom / Minimal
 6. Waybar Style: Default / Hollow / Solid / Minimal / Flat / Compact / Floating
 7. ROG Laptop Support: Yes / No
 8. Fonts: Install recommended fonts
 9. Bluetooth: Configure Bluetooth
10. Zsh: Install Zsh + Starship
```

### Step 2: Review & Confirm

After configuration, you'll see a summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Configuration Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Display Manager : sddm
  Status Bar      : waybar
  File Manager    : dolphin
  Lockscreen      : hyprlock
  Dotfiles        : default
  Waybar Style    : default
  ROG Support     : no
  Fonts           : yes
  Bluetooth       : yes
  Zsh             : yes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3: Automatic Installation

The script automatically:

1. **Installs AUR Helper** (yay or paru)
2. **Installs Base Packages** (audio, network, utilities)
3. **Detects & Configures GPU** (NVIDIA/AMD/Intel)
4. **Installs Hyprland & Core Apps** (compositor, terminal, launcher)
5. **Installs Display Manager** (your choice)
6. **Installs Status Bar** (your choice)
7. **Installs File Manager** (your choice)
8. **Installs Lock Screen** (hyprlock, optional wlogout)
9. **Installs Fonts** (JetBrains Mono, Noto, etc.)
10. **Configures Bluetooth** (if selected)
11. **Sets up Zsh** (with Starship prompt)
12. **Installs Themes** (GTK, Qt, cursors, icons)
13. **Applies Dotfiles** (configs to ~/.config)
14. **Sets up Wallpapers**

### Step 4: Reboot

After installation completes:

```bash
sudo reboot
```

You'll be greeted with your selected display manager (or TTY login).
Select **Hyprland** as your session and login!

## ⌨️ Keybindings

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
| `Super + F` | Fullscreen |
| `Super + Shift + F` | Maximize |
| `Super + V` | Toggle Floating |
| `Super + P` | Pseudo-tile |
| `Super + D` | Toggle Split |
| `Super + G` | Toggle Group |

### Navigation
| Key | Action |
|-----|--------|
| `Super + H/J/K/L` | Focus (vim-style) |
| `Super + Shift + H/J/K/L` | Move window (vim-style) |
| `Super + Ctrl + H/J/K/L` | Resize window (vim-style) |
| `Super + Arrow` | Focus direction |
| `Super + Shift + Arrow` | Move window |
| `Super + Ctrl + Arrow` | Resize window |
| `Super + Alt + Arrow` | Swap window |
| `Super + 1-0` | Switch Workspace |
| `Super + Shift + 1-0` | Move to Workspace |
| `Super + S` | Scratchpad |
| `Super + Tab` | Next Workspace |

### System & Utilities
| Key | Action |
|-----|--------|
| `Super + Escape` | Lock Screen |
| `Super + X` | Power Menu (wlogout) |
| `Super + N` | Notification Center |
| `Super + /` | Keybindings Help |
| `Super + W` | Waybar Style (rofi) |
| `Super + Shift + W` | Waybar Next Style |
| `Super + Shift + N` | Wallpaper Select |
| `Super + Alt + W` | Random Wallpaper |
| `Super + Shift + B` | Blue Light Filter |
| `Super + Shift + T` | Toggle Touchpad |
| `Super + Shift + C` | Color Picker |
| `Super + Shift + V` | Clipboard History |

### Screenshots
| Key | Action |
|-----|--------|
| `Print` | Screenshot (area → clipboard) |
| `Shift + Print` | Screenshot (fullscreen → clipboard) |
| `Super + Print` | Screenshot (area → save) |
| `Super + Shift + Print` | Screenshot (area → edit) |

## 📁 Directory Structure

```
s4d_hyprland/
├── install.sh                      # Main installation script
├── README.md
├── Configs/                        # Default configuration files
│   ├── hypr/                      # ── Hyprland (modular) ──
│   │   ├── hyprland.conf          # Main entry — sources all modules
│   │   ├── monitors.conf          # Monitor layout (user-editable)
│   │   ├── userprefs.conf         # Personal overrides
│   │   ├── animations.conf        # Router → animations/<preset>.conf
│   │   ├── hyprlock.conf          # Lock screen config
│   │   ├── hypridle.conf          # Idle manager config
│   │   ├── animations/            # Swappable animation presets
│   │   │   ├── smooth.conf        # Default — smooth & balanced
│   │   │   ├── dynamic.conf       # Bouncy & playful
│   │   │   ├── fast.conf          # Snappy & minimal delay
│   │   │   ├── material.conf      # Material Design inspired
│   │   │   ├── minimal.conf       # Subtle fades only
│   │   │   └── disabled.conf      # No animations
│   │   ├── colors/                # Color palettes
│   │   │   ├── catppuccin-mocha.conf
│   │   │   └── catppuccin-latte.conf
│   │   ├── settings/              # System settings
│   │   │   ├── env.conf           # Environment variables
│   │   │   ├── input.conf         # Keyboard, mouse, touchpad
│   │   │   ├── general.conf       # Gaps, borders, layout
│   │   │   ├── misc.conf          # VFR, VRR, cursor
│   │   │   ├── nvidia.conf        # NVIDIA-specific env vars
│   │   │   ├── amd.conf           # AMD-specific env vars
│   │   │   ├── intel.conf         # Intel-specific env vars
│   │   │   └── rog.conf           # ASUS ROG laptop extras
│   │   ├── themes/
│   │   │   └── decoration.conf    # Rounding, blur, shadows, opacity
│   │   ├── keybinds/
│   │   │   ├── keybinds.conf      # All keybindings (bindd)
│   │   │   └── windowrules.conf   # Float, opacity, workspace rules
│   │   ├── shaders/
│   │   │   ├── blue-light-filter.glsl
│   │   │   └── vibrance.glsl
│   │   └── scripts/               # Utility scripts
│   │       ├── wallpaper.sh       # Set / random / restore wallpaper
│   │       ├── screenshot.sh      # Full / area / active window
│   │       ├── volume.sh          # Volume ± with notification
│   │       ├── brightness.sh      # Brightness ± with notification
│   │       ├── touchpad.sh        # Toggle touchpad on/off
│   │       ├── colorpicker.sh     # Pick color → clipboard
│   │       ├── s4d-theme.sh       # Switch animations / colors
│   │       ├── waybar-style.sh    # Waybar style/layout switcher
│   │       └── keybinds-help.sh   # Display keybindings via rofi
│   ├── waybar/                    # ── Status Bar ──
│   │   ├── config.jsonc           # Pill-style grouped modules
│   │   ├── style.css              # Transparent bar + Catppuccin
│   │   ├── mocha.css              # Color definitions
│   │   ├── styles/                # Swappable bar styles
│   │   │   ├── default.css        # Pill Groups (default)
│   │   │   ├── hollow.css         # Floating Pods with borders
│   │   │   ├── solid.css          # Classic solid bar
│   │   │   ├── minimal.css        # Just text, no frills
│   │   │   ├── flat.css           # Bottom-line accents
│   │   │   ├── compact.css        # Dense, space-efficient
│   │   │   └── floating.css       # Island bar with shadow
│   │   └── layouts/               # Alternative bar layouts
│   │       ├── full.jsonc         # All modules
│   │       ├── minimal.jsonc      # Center-only (clock + battery)
│   │       └── sysmon.jsonc       # System monitor emphasis
│   ├── rofi/                      # ── App Launcher ──
│   │   ├── config.rasi
│   │   ├── catppuccin-mocha.rasi
│   │   └── scripts/power-menu.sh
│   ├── swaync/                    # ── Notifications ──
│   │   ├── config.json
│   │   └── style.css
│   ├── kitty/kitty.conf           # ── Terminal ──
│   ├── wlogout/                   # ── Power Menu ──
│   │   ├── layout
│   │   └── style.css
│   ├── fastfetch/config.jsonc     # ── System Info ──
│   ├── starship/starship.toml     # ── Prompt ──
│   ├── zsh/                       # ── Shell ──
│   │   ├── .zshrc
│   │   └── .zprofile
│   ├── gtk-3.0/settings.ini       # ── GTK Theme ──
│   ├── gtk-4.0/settings.ini
│   ├── qt5ct/qt5ct.conf           # ── Qt Theme ──
│   └── qt6ct/qt6ct.conf
├── Packages/                      # Package lists
│   ├── base.lst
│   ├── hyprland.lst
│   └── fonts.lst
└── Scripts/                       # Installation scripts
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
    ├── nemo-install.sh
    ├── fonts-install.sh
    ├── bluetooth-install.sh
    ├── rog-install.sh
    ├── zsh-install.sh
    └── post-install.sh
```

## 🎨 s4d-theme — Theme Manager CLI

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

## 🎨 Waybar Style Switcher

Change your status bar appearance on the fly with `Super + W`:

```bash
# Via rofi menu (Super + W)
waybar-style.sh rofi

# Set directly
waybar-style.sh set hollow
waybar-style.sh set floating

# Cycle through styles (Super + Shift + W)
waybar-style.sh next
waybar-style.sh prev

# Switch layout
waybar-style.sh layout minimal
waybar-style.sh layout sysmon
```

**Available styles:** default, hollow, solid, minimal, flat, compact, floating
**Available layouts:** default (full), minimal, sysmon

## 🖥️ GPU Support

The installer automatically detects and configures:

- **NVIDIA**: Installs proprietary drivers, configures mkinitcpio, GRUB
- **AMD**: Installs Mesa, Vulkan, and VA-API drivers
- **Intel**: Installs Mesa and Intel Media driver
- **Hybrid**: Supports laptops with multiple GPUs

## 🎨 Custom Dotfiles

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

## 🎨 Theme

The default theme uses **Catppuccin Mocha** color scheme:

- Base: `#1e1e2e`
- Text: `#cdd6f4`
- Accent: `#cba6f7` (Mauve)

## 📝 Logs

Installation logs are saved to:
```
./Logs/install-YYYYMMDD-HHMMSS.log
```

## 🔧 Troubleshooting

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

## 🙏 Credits

- [Hyprland](https://hyprland.org/) — Wayland compositor
- [Catppuccin](https://github.com/catppuccin) — Color scheme
- [BlackNode](https://github.com/Jexxar/BlackNode) — Modular config architecture inspiration
- [HyDE](https://github.com/prasanthrangan/hyprdots) — Shader system & wallbash concepts
- [HyprFlux](https://github.com/Jexxar/HyprFlux) — Animation presets design
- [JaKooLit](https://github.com/JaKooLit) — KooL Hyprland install patterns
- [omarchy](https://github.com/dhh/omarchy) — Clean theme system & starship prompt
- [DankMaterialShell](https://github.com/user/DankMaterialShell) — Desktop shell alternative

## 📄 License

MIT License - feel free to use and modify!

---

Made with 💜 for the Arch + Hyprland community
