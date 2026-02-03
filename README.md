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
curl -fsSL https://raw.githubusercontent.com/Sadbin47/s4d_hyprland/main/install.sh | bash
```

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
- ✅ `git` and `base-devel` packages installed

```bash
# If you need git and base-devel:
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
6. ROG Laptop Support: Yes / No
7. Fonts: Install recommended fonts
8. Bluetooth: Configure Bluetooth
9. Zsh: Install Zsh + Starship
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
12. **Applies Dotfiles** (configs to ~/.config)
13. **Sets up Themes** (GTK, QT, cursors, icons)
14. **Downloads Wallpapers**

### Step 4: Reboot

After installation completes:

```bash
sudo reboot
```

You'll be greeted with your selected display manager (or TTY login).
Select **Hyprland** as your session and login!

## ⌨️ Keybindings

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

## 📁 Directory Structure

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

- [Hyprland](https://hyprland.org/) - Wayland compositor
- [Catppuccin](https://github.com/catppuccin) - Color scheme
- [JaKooLit](https://github.com/JaKooLit) - Inspiration from KooL Hyprland
- [HyDE](https://github.com/prasanthrangan/hyprdots) - Inspiration from HyDE project

## 📄 License

MIT License - feel free to use and modify!

---

Made with 💜 for the Arch + Hyprland community
