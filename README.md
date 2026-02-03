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

## Features

- 🚀 **Fast Installation**: Streamlined installation process
- 🎨 **User Choice**: Select your preferred components
- 🖥️ **GPU Support**: Automatic detection for NVIDIA, AMD, and Intel
- 📦 **Bloat-Free**: Only essential packages, no unnecessary software
- ⚙️ **Modular**: Easy to customize and extend
- 🎯 **ROG Support**: Optional ASUS ROG laptop support

## Components

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

## Requirements

- Fresh Arch Linux installation
- Internet connection
- Non-root user with sudo privileges

## Quick Start

```bash
git clone https://github.com/yourusername/s4d_Hyprland.git
cd s4d_Hyprland
chmod +x install.sh
./install.sh
```

## Installation Options

The installer will prompt you to choose:

1. **Display Manager**: SDDM (recommended), Ly (minimal TUI), or None
2. **Status Bar**: Waybar (feature-rich) or DankMaterialShell (modern)
3. **File Manager**: Dolphin (KDE) or Nemo (GTK)
4. **Lock Screen**: Hyprlock only or with Wlogout
5. **Dotfiles**: Default, custom Git repository, or minimal
6. **ROG Support**: For ASUS ROG laptops
7. **Fonts**: Popular Nerd Fonts and system fonts
8. **Bluetooth**: Enable Bluetooth support
9. **Shell**: Zsh with Starship prompt

## Keybindings

| Key | Action |
|-----|--------|
| `Super + T` | Terminal |
| `Super + A` | App Launcher |
| `Super + E` | File Manager |
| `Super + B` | Browser |
| `Super + Q` | Close Window |
| `Super + L` | Lock Screen |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle Floating |
| `Super + 1-0` | Switch Workspace |
| `Super + Shift + 1-0` | Move to Workspace |
| `Super + N` | Notification Center |
| `Print` | Screenshot (region) |

## Directory Structure

```
s4d_Hyprland/
├── install.sh              # Main installation script
├── README.md               # This file
├── Configs/                # Default configuration files
│   ├── hypr/              # Hyprland configs
│   ├── kitty/             # Kitty terminal config
│   ├── rofi/              # Rofi launcher config
│   ├── waybar/            # Waybar config
│   └── swaync/            # SwayNC notification config
├── Packages/              # Package lists
│   ├── base.lst           # Base system packages
│   ├── hyprland.lst       # Hyprland packages
│   └── fonts.lst          # Font packages
└── Scripts/               # Installation scripts
    ├── functions.sh       # Shared functions
    ├── gpu-detect.sh      # GPU detection
    ├── sddm-install.sh    # SDDM installation
    ├── ly-install.sh      # Ly installation
    ├── waybar-install.sh  # Waybar installation
    ├── dankms-install.sh  # DankMaterialShell installation
    ├── dolphin-install.sh # Dolphin installation
    ├── nemo-install.sh    # Nemo installation
    ├── fonts-install.sh   # Fonts installation
    ├── bluetooth-install.sh # Bluetooth setup
    ├── rog-install.sh     # ROG laptop support
    ├── zsh-install.sh     # Zsh setup
    └── dotfiles-apply.sh  # Dotfiles application
```

## GPU Support

The installer automatically detects and configures:

- **NVIDIA**: Installs proprietary drivers, configures mkinitcpio, GRUB
- **AMD**: Installs Mesa, Vulkan, and VA-API drivers
- **Intel**: Installs Mesa and Intel Media driver
- **Hybrid**: Supports laptops with multiple GPUs

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

## Credits

- [Hyprland](https://hyprland.org/) - Wayland compositor
- [Catppuccin](https://github.com/catppuccin) - Color scheme
- [JaKooLit](https://github.com/JaKooLit) - Inspiration from KooL Hyprland
- [HyDE](https://github.com/prasanthrangan/hyprdots) - Inspiration from HyDE project

## License

MIT License - feel free to use and modify!

---

Made with 💜 for the Arch + Hyprland community
