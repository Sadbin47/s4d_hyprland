#!/bin/bash
#╔═══════════════════════════════════════════════════════════════════════════════╗
#║                        s4d Hyprland Installation Script                       ║
#║                   Minimal, Bloat-Free Hyprland Setup for Arch                 ║
#║                              Author: s4d                                       ║
#╚═══════════════════════════════════════════════════════════════════════════════╝

#=============================================================================
# CURL/REMOTE EXECUTION DETECTION
#=============================================================================
SCRIPT_PATH="${BASH_SOURCE[0]}"
IS_REMOTE=false

if [[ ! -t 0 && -z "$SCRIPT_PATH" ]]; then
    IS_REMOTE=true
elif [[ "$SCRIPT_PATH" == /dev/* ]] || [[ "$SCRIPT_PATH" == /proc/* ]]; then
    IS_REMOTE=true
elif [[ -n "$SCRIPT_PATH" ]] && [[ ! -d "$(dirname "$SCRIPT_PATH")/Scripts" ]]; then
    IS_REMOTE=true
fi

if [[ "$IS_REMOTE" == true ]]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  s4d Hyprland — Remote Installation Detected"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    if ! command -v git &>/dev/null; then
        echo "[i] Installing git..."
        sudo pacman -S --noconfirm git
    fi

    INSTALL_DIR="$HOME/s4d_hyprland"
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "[i] Updating existing installation..."
        cd "$INSTALL_DIR"
        git pull --ff-only 2>/dev/null || {
            cd "$HOME"
            rm -rf "$INSTALL_DIR"
            git clone https://github.com/Sadbin47/s4d_hyprland.git "$INSTALL_DIR"
        }
    else
        git clone https://github.com/Sadbin47/s4d_hyprland.git "$INSTALL_DIR"
    fi

    cd "$INSTALL_DIR"
    chmod +x install.sh
    exec ./install.sh
    exit 0
fi

# NOTE: No "set -e" — we handle errors gracefully per-command

#=============================================================================
# DIRECTORIES
#=============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/Scripts"
CONFIGS_DIR="$SCRIPT_DIR/Configs"
PACKAGES_DIR="$SCRIPT_DIR/Packages"
LOG_DIR="$SCRIPT_DIR/Logs"

mkdir -p "$LOG_DIR"
export LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

#=============================================================================
# LOAD SHARED FUNCTIONS (single source of truth)
#=============================================================================
source "$SCRIPTS_DIR/functions.sh"

#=============================================================================
# USER SELECTIONS
#=============================================================================
declare -A USER_CHOICES
USER_CHOICES=(
    [display_manager]=""
    [status_bar]=""
    [file_manager]=""
    [lockscreen]=""
    [dotfiles]=""
    [custom_dots_url]=""
    [rog_laptop]=""
    [install_fonts]=""
    [configure_bluetooth]=""
    [configure_zsh]=""
)

#=============================================================================
# MENU
#=============================================================================
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
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
EOF
    echo -e "${NC}"
    echo -e "${WHITE}    Bloat-Free Hyprland Installation for Arch Linux${NC}"
    echo ""
}

configuration_menu() {
    show_banner
    log_section "Configuration Menu"

    echo -e "${INFO} Configure your installation:\n"

    # 1. Display Manager
    echo -e "${BOLD}1. Display Manager:${NC}"
    PS3="   Select: "
    select dm in "SDDM (Recommended)" "Ly (Minimal TUI)" "None (TTY Login)"; do
        case $REPLY in
            1) USER_CHOICES[display_manager]="sddm"; break;;
            2) USER_CHOICES[display_manager]="ly"; break;;
            3) USER_CHOICES[display_manager]="none"; break;;
            *) echo "   Enter 1, 2, or 3";;
        esac
    done
    log "${OK} Display Manager: ${USER_CHOICES[display_manager]}"

    # 2. Status Bar
    echo -e "\n${BOLD}2. Status Bar:${NC}"
    PS3="   Select: "
    select bar in "Waybar (Feature-rich)" "DankMaterialShell (Modern Desktop-like)"; do
        case $REPLY in
            1) USER_CHOICES[status_bar]="waybar"; break;;
            2) USER_CHOICES[status_bar]="dankms"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} Status Bar: ${USER_CHOICES[status_bar]}"

    # 3. File Manager
    echo -e "\n${BOLD}3. File Manager:${NC}"
    PS3="   Select: "
    select fm in "Dolphin (KDE)" "Nemo (GTK, Lightweight)"; do
        case $REPLY in
            1) USER_CHOICES[file_manager]="dolphin"; break;;
            2) USER_CHOICES[file_manager]="nemo"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} File Manager: ${USER_CHOICES[file_manager]}"

    # 4. Lockscreen
    echo -e "\n${BOLD}4. Lockscreen:${NC}"
    PS3="   Select: "
    select lock in "Hyprlock" "Hyprlock + Wlogout"; do
        case $REPLY in
            1) USER_CHOICES[lockscreen]="hyprlock"; break;;
            2) USER_CHOICES[lockscreen]="both"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} Lockscreen: ${USER_CHOICES[lockscreen]}"

    # 5. Dotfiles
    echo -e "\n${BOLD}5. Dotfiles:${NC}"
    PS3="   Select: "
    select dots in "Default s4d dotfiles (Recommended)" "Custom (git URL)" "Minimal (bare essentials)"; do
        case $REPLY in
            1) USER_CHOICES[dotfiles]="default"; break;;
            2)
                USER_CHOICES[dotfiles]="custom"
                echo -en "${ASK} Enter git repository URL: "
                read -r USER_CHOICES[custom_dots_url]
                break;;
            3) USER_CHOICES[dotfiles]="minimal"; break;;
            *) echo "   Enter 1, 2, or 3";;
        esac
    done
    log "${OK} Dotfiles: ${USER_CHOICES[dotfiles]}"

    # 6-9: Yes/No options
    echo -e "\n${BOLD}6. ASUS ROG Laptop Support:${NC}"
    PS3="   Select: "
    select rog in "No" "Yes"; do
        case $REPLY in
            1) USER_CHOICES[rog_laptop]="no"; break;;
            2) USER_CHOICES[rog_laptop]="yes"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} ROG Laptop: ${USER_CHOICES[rog_laptop]}"

    echo -e "\n${BOLD}7. Install Fonts:${NC}"
    PS3="   Select: "
    select fonts in "Yes (Recommended)" "No"; do
        case $REPLY in
            1) USER_CHOICES[install_fonts]="yes"; break;;
            2) USER_CHOICES[install_fonts]="no"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} Fonts: ${USER_CHOICES[install_fonts]}"

    echo -e "\n${BOLD}8. Bluetooth:${NC}"
    PS3="   Select: "
    select bt in "Yes" "No"; do
        case $REPLY in
            1) USER_CHOICES[configure_bluetooth]="yes"; break;;
            2) USER_CHOICES[configure_bluetooth]="no"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} Bluetooth: ${USER_CHOICES[configure_bluetooth]}"

    echo -e "\n${BOLD}9. Zsh + Starship Prompt:${NC}"
    PS3="   Select: "
    select zsh in "Yes (Recommended)" "No"; do
        case $REPLY in
            1) USER_CHOICES[configure_zsh]="yes"; break;;
            2) USER_CHOICES[configure_zsh]="no"; break;;
            *) echo "   Enter 1 or 2";;
        esac
    done
    log "${OK} Zsh: ${USER_CHOICES[configure_zsh]}"

    # Summary
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Display Manager : ${GREEN}${USER_CHOICES[display_manager]}${NC}"
    echo -e "  Status Bar      : ${GREEN}${USER_CHOICES[status_bar]}${NC}"
    echo -e "  File Manager    : ${GREEN}${USER_CHOICES[file_manager]}${NC}"
    echo -e "  Lockscreen      : ${GREEN}${USER_CHOICES[lockscreen]}${NC}"
    echo -e "  Dotfiles        : ${GREEN}${USER_CHOICES[dotfiles]}${NC}"
    echo -e "  ROG Support     : ${GREEN}${USER_CHOICES[rog_laptop]}${NC}"
    echo -e "  Fonts           : ${GREEN}${USER_CHOICES[install_fonts]}${NC}"
    echo -e "  Bluetooth       : ${GREEN}${USER_CHOICES[configure_bluetooth]}${NC}"
    echo -e "  Zsh             : ${GREEN}${USER_CHOICES[configure_zsh]}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    PS3="Proceed? "
    select proceed in "Yes, install" "No, cancel"; do
        case $REPLY in
            1) break;;
            2) log "${INFO} Cancelled."; exit 0;;
            *) echo "   Enter 1 or 2";;
        esac
    done
}

#=============================================================================
# PRE-FLIGHT CHECKS
#=============================================================================
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "${ERROR} Do NOT run as root. sudo will be used when needed."
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log "${ERROR} This script is for Arch Linux only."
        exit 1
    fi
}

check_internet() {
    log "${INFO} Checking internet..."
    if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
        log "${ERROR} No internet connection."
        exit 1
    fi
    log "${OK} Internet OK"
}

#=============================================================================
# AUR HELPER
#=============================================================================
install_aur_helper() {
    log_section "AUR Helper"

    if command -v yay &>/dev/null; then
        log "${OK} yay already installed"
        return 0
    fi

    if command -v paru &>/dev/null; then
        log "${OK} paru already installed"
        return 0
    fi

    log "${INFO} Installing yay..."
    sudo pacman -S --noconfirm --needed base-devel git || true

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin" 2>/dev/null; then
        cd "$tmp_dir/yay-bin"
        makepkg -si --noconfirm 2>&1 | tee -a "$LOG_FILE" || true
        cd "$SCRIPT_DIR"
    fi
    rm -rf "$tmp_dir"

    if command -v yay &>/dev/null; then
        log "${OK} yay installed"
    else
        log "${WARN} yay installation failed — AUR packages won't be available"
    fi
}

#=============================================================================
# INSTALLATION FUNCTIONS
#=============================================================================
install_base_packages() {
    log_section "Base Packages"
    source "$PACKAGES_DIR/base.lst"
}

install_hyprland_packages() {
    log_section "Hyprland & Core Components"
    source "$PACKAGES_DIR/hyprland.lst"
}

detect_and_install_gpu_drivers() {
    log_section "GPU Detection & Drivers"
    source "$SCRIPTS_DIR/gpu-detect.sh"
}

install_display_manager() {
    log_section "Display Manager"
    case "${USER_CHOICES[display_manager]}" in
        sddm) source "$SCRIPTS_DIR/sddm-install.sh" ;;
        ly)   source "$SCRIPTS_DIR/ly-install.sh" ;;
        none) log "${INFO} Skipping display manager (TTY login)" ;;
    esac
}

install_status_bar() {
    log_section "Status Bar"
    case "${USER_CHOICES[status_bar]}" in
        waybar)
            source "$SCRIPTS_DIR/waybar-install.sh"
            ;;
        dankms)
            source "$SCRIPTS_DIR/dankms-install.sh"
            ;;
    esac
}

install_file_manager() {
    log_section "File Manager"
    case "${USER_CHOICES[file_manager]}" in
        dolphin) source "$SCRIPTS_DIR/dolphin-install.sh" ;;
        nemo)    source "$SCRIPTS_DIR/nemo-install.sh" ;;
    esac
}

install_lockscreen() {
    log_section "Lockscreen"
    install_pkg hyprlock
    install_pkg hypridle
    install_pkg grim
    if [[ "${USER_CHOICES[lockscreen]}" == "both" ]]; then
        install_pkg wlogout
    fi
}

install_fonts() {
    if [[ "${USER_CHOICES[install_fonts]}" == "yes" ]]; then
        log_section "Fonts"
        source "$SCRIPTS_DIR/fonts-install.sh"
    fi
}

configure_bluetooth() {
    if [[ "${USER_CHOICES[configure_bluetooth]}" == "yes" ]]; then
        log_section "Bluetooth"
        source "$SCRIPTS_DIR/bluetooth-install.sh"
    fi
}

install_rog_support() {
    if [[ "${USER_CHOICES[rog_laptop]}" == "yes" ]]; then
        log_section "ASUS ROG Support"
        source "$SCRIPTS_DIR/rog-install.sh"
    fi
}

configure_zsh() {
    if [[ "${USER_CHOICES[configure_zsh]}" == "yes" ]]; then
        log_section "Zsh & Starship"
        source "$SCRIPTS_DIR/zsh-install.sh"
    fi
}

install_themes() {
    log_section "Themes (GTK, Icons, Cursors)"
    source "$SCRIPTS_DIR/themes-install.sh"
}

apply_dotfiles() {
    log_section "Applying Dotfiles"
    export S4D_STATUS_BAR="${USER_CHOICES[status_bar]}"
    case "${USER_CHOICES[dotfiles]}" in
        default) source "$SCRIPTS_DIR/dotfiles-apply.sh" "default" ;;
        custom)  source "$SCRIPTS_DIR/dotfiles-apply.sh" "custom" "${USER_CHOICES[custom_dots_url]}" ;;
        minimal) source "$SCRIPTS_DIR/dotfiles-apply.sh" "minimal" ;;
    esac
}

setup_wallpapers() {
    log_section "Wallpapers"
    source "$SCRIPTS_DIR/wallpaper-setup.sh"
}

run_post_install() {
    log_section "Post-Installation"
    source "$SCRIPTS_DIR/post-install.sh"
}

enable_services() {
    log_section "Enabling Services"

    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    log "${OK} NetworkManager enabled"

    case "${USER_CHOICES[display_manager]}" in
        sddm) sudo systemctl enable sddm 2>/dev/null || true; log "${OK} SDDM enabled" ;;
        ly)   sudo systemctl enable ly 2>/dev/null || true; log "${OK} Ly enabled" ;;
    esac

    if [[ "${USER_CHOICES[configure_bluetooth]}" == "yes" ]]; then
        sudo systemctl enable --now bluetooth 2>/dev/null || true
        log "${OK} Bluetooth enabled"
    fi

    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
    log "${OK} Pipewire audio enabled"
}

#=============================================================================
# MAIN
#=============================================================================
main() {
    check_root
    check_arch
    check_internet

    show_banner
    configuration_menu

    log_section "Starting Installation"
    log "${INFO} Started at $(date)"
    log "${INFO} Log: $LOG_FILE"

    # Core
    install_aur_helper
    install_base_packages
    detect_and_install_gpu_drivers
    install_hyprland_packages

    # User-selected
    install_display_manager
    install_status_bar
    install_file_manager
    install_lockscreen
    install_fonts
    configure_bluetooth
    install_rog_support
    configure_zsh

    # Theming & configs
    install_themes
    apply_dotfiles
    setup_wallpapers

    # Post-install
    run_post_install
    enable_services

    # Show summary of any issues
    show_failed_packages

    # Done
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           s4d Hyprland Installation Complete!                 ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${INFO} Reboot to start using Hyprland"
    echo ""
    echo -e "${CYAN}  Keybindings:${NC}"
    echo -e "    Super + T       Terminal (Kitty)"
    echo -e "    Super + A       App Launcher (Rofi)"
    echo -e "    Super + E       File Manager"
    echo -e "    Super + Q       Close Window"
    echo -e "    Super + Escape  Lock Screen"
    echo -e "    Super + X       Power Menu"
    echo -e "    Super + Up      Cycle Waybar Style"
    echo -e "    Super + Down    Waybar Style Menu"
    echo -e "    Super + /       Keybindings Help"
    echo ""
    echo -e "${INFO} Log: $LOG_FILE"
    echo ""

    PS3="Reboot now? "
    select rb in "Yes" "No"; do
        case $REPLY in
            1) sudo reboot ;;
            2) break ;;
        esac
    done
}

main "$@"
