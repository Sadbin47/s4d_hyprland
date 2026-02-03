#!/bin/bash
#╔═══════════════════════════════════════════════════════════════════════════════╗
#║                        s4d Hyprland Installation Script                       ║
#║                   Minimal, Bloat-Free Hyprland Setup for Arch                 ║
#║                              Author: s4d                                       ║
#╚═══════════════════════════════════════════════════════════════════════════════╝

#=============================================================================
# CURL DETECTION - If running via curl, clone and re-execute
#=============================================================================
if [[ ! -t 0 ]] || [[ "${BASH_SOURCE[0]}" == "" ]] || [[ ! -f "${BASH_SOURCE[0]}" ]]; then
    echo "Detected curl pipe execution. Cloning repository first..."
    
    # Ensure git is installed
    if ! command -v git &>/dev/null; then
        echo "Installing git..."
        sudo pacman -S --noconfirm git
    fi
    
    # Clone to home directory
    INSTALL_DIR="$HOME/s4d_hyprland"
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "Removing existing $INSTALL_DIR..."
        rm -rf "$INSTALL_DIR"
    fi
    
    echo "Cloning s4d_hyprland to $INSTALL_DIR..."
    git clone https://github.com/Sadbin47/s4d_hyprland.git "$INSTALL_DIR"
    
    echo "Starting installation..."
    cd "$INSTALL_DIR"
    chmod +x install.sh
    exec ./install.sh
    exit 0
fi

set -e

#=============================================================================
# COLORS & STYLING
#=============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

readonly OK="${GREEN}[✓]${NC}"
readonly ERROR="${RED}[✗]${NC}"
readonly INFO="${BLUE}[i]${NC}"
readonly WARN="${YELLOW}[!]${NC}"
readonly ASK="${MAGENTA}[?]${NC}"

#=============================================================================
# DIRECTORIES
#=============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/Scripts"
CONFIGS_DIR="$SCRIPT_DIR/Configs"
PACKAGES_DIR="$SCRIPT_DIR/Packages"
LOG_DIR="$SCRIPT_DIR/Logs"
CACHE_DIR="$HOME/.cache/s4d-hyprland"

mkdir -p "$LOG_DIR" "$CACHE_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

#=============================================================================
# USER SELECTIONS (will be set by menu)
#=============================================================================
declare -A USER_CHOICES
USER_CHOICES=(
    [display_manager]=""
    [status_bar]=""
    [file_manager]=""
    [lockscreen]=""
    [custom_dots]=""
    [custom_dots_url]=""
    [rog_laptop]=""
    [install_fonts]=""
    [configure_bluetooth]=""
    [configure_zsh]=""
)

#=============================================================================
# LOGGING FUNCTIONS
#=============================================================================
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
    echo -e "${BOLD}${WHITE}  $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
}

#=============================================================================
# HELPER FUNCTIONS
#=============================================================================
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "${ERROR} This script should NOT be run as root!"
        log "${INFO} Please run as a normal user. sudo will be used when needed."
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log "${ERROR} This script is designed for Arch Linux only!"
        exit 1
    fi
}

check_internet() {
    log "${INFO} Checking internet connection..."
    if ! ping -c 1 archlinux.org &>/dev/null; then
        log "${ERROR} No internet connection detected!"
        exit 1
    fi
    log "${OK} Internet connection available"
}

pkg_installed() {
    pacman -Q "$1" &>/dev/null
}

install_pkg() {
    local pkg="$1"
    if pkg_installed "$pkg"; then
        log "${OK} $pkg is already installed"
        return 0
    fi
    
    log "${INFO} Installing $pkg..."
    if sudo pacman -S --noconfirm --needed "$pkg" &>>"$LOG_FILE"; then
        log "${OK} $pkg installed successfully"
        return 0
    else
        # Try AUR
        if command -v yay &>/dev/null; then
            if yay -S --noconfirm --needed "$pkg" &>>"$LOG_FILE"; then
                log "${OK} $pkg installed from AUR"
                return 0
            fi
        elif command -v paru &>/dev/null; then
            if paru -S --noconfirm --needed "$pkg" &>>"$LOG_FILE"; then
                log "${OK} $pkg installed from AUR"
                return 0
            fi
        fi
        log "${WARN} Failed to install $pkg"
        return 1
    fi
}

install_aur_helper() {
    log_section "Installing AUR Helper"
    
    if command -v yay &>/dev/null; then
        log "${OK} yay is already installed"
        return 0
    fi
    
    if command -v paru &>/dev/null; then
        log "${OK} paru is already installed"
        return 0
    fi
    
    log "${INFO} Installing yay..."
    
    # Install base-devel if not installed
    if ! pacman -Qg base-devel &>/dev/null; then
        sudo pacman -S --noconfirm --needed base-devel git
    fi
    
    local tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
    cd "$tmp_dir/yay-bin"
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf "$tmp_dir"
    
    log "${OK} yay installed successfully"
}

#=============================================================================
# MENU FUNCTIONS
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

select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local key=""
    
    echo -e "\n${ASK} ${BOLD}$prompt${NC}"
    echo ""
    
    while true; do
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${GREEN}▶ ${options[$i]}${NC}"
            else
                echo -e "    ${options[$i]}"
            fi
        done
        
        read -rsn1 key
        
        case "$key" in
            A) # Up arrow
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1))
                ;;
            B) # Down arrow
                ((selected++))
                [[ $selected -ge ${#options[@]} ]] && selected=0
                ;;
            "") # Enter
                echo "${options[$selected]}"
                return $selected
                ;;
        esac
        
        # Move cursor up to redraw
        echo -en "\033[${#options[@]}A"
    done
}

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        echo -en "${ASK} $prompt [Y/n]: "
    else
        echo -en "${ASK} $prompt [y/N]: "
    fi
    
    read -r response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy] ]]
}

configuration_menu() {
    show_banner
    log_section "Configuration Menu"
    
    echo -e "${INFO} Please configure your installation preferences:\n"
    
    # Display Manager
    echo -e "${BOLD}1. Display Manager:${NC}"
    PS3="Select display manager: "
    select dm in "SDDM (Recommended)" "Ly (Minimal TUI)" "None (TTY Login)"; do
        case $REPLY in
            1) USER_CHOICES[display_manager]="sddm"; break;;
            2) USER_CHOICES[display_manager]="ly"; break;;
            3) USER_CHOICES[display_manager]="none"; break;;
        esac
    done
    log "${OK} Display Manager: ${USER_CHOICES[display_manager]}"
    
    # Status Bar
    echo -e "\n${BOLD}2. Status Bar:${NC}"
    PS3="Select status bar: "
    select bar in "Waybar (Feature-rich)" "DankMaterialShell (Modern Desktop-like)"; do
        case $REPLY in
            1) USER_CHOICES[status_bar]="waybar"; break;;
            2) USER_CHOICES[status_bar]="dankms"; break;;
        esac
    done
    log "${OK} Status Bar: ${USER_CHOICES[status_bar]}"
    
    # File Manager
    echo -e "\n${BOLD}3. File Manager:${NC}"
    PS3="Select file manager: "
    select fm in "Dolphin (KDE, Feature-rich)" "Nemo (GTK, Lightweight)"; do
        case $REPLY in
            1) USER_CHOICES[file_manager]="dolphin"; break;;
            2) USER_CHOICES[file_manager]="nemo"; break;;
        esac
    done
    log "${OK} File Manager: ${USER_CHOICES[file_manager]}"
    
    # Lockscreen
    echo -e "\n${BOLD}4. Lockscreen:${NC}"
    PS3="Select lockscreen: "
    select lock in "Hyprlock (Native Hyprland)" "Both Hyprlock + Wlogout"; do
        case $REPLY in
            1) USER_CHOICES[lockscreen]="hyprlock"; break;;
            2) USER_CHOICES[lockscreen]="both"; break;;
        esac
    done
    log "${OK} Lockscreen: ${USER_CHOICES[lockscreen]}"
    
    # Custom Dotfiles
    echo -e "\n${BOLD}5. Dotfiles Configuration:${NC}"
    if confirm "Use default s4d dotfiles?"; then
        USER_CHOICES[custom_dots]="default"
    else
        if confirm "Do you want to provide a custom dotfiles git URL?"; then
            USER_CHOICES[custom_dots]="custom"
            echo -en "${ASK} Enter git repository URL: "
            read -r USER_CHOICES[custom_dots_url]
        else
            USER_CHOICES[custom_dots]="minimal"
        fi
    fi
    log "${OK} Dotfiles: ${USER_CHOICES[custom_dots]}"
    
    # ROG Laptop
    echo -e "\n${BOLD}6. ASUS ROG Laptop Support:${NC}"
    if confirm "Are you installing on an ASUS ROG laptop?"; then
        USER_CHOICES[rog_laptop]="yes"
    else
        USER_CHOICES[rog_laptop]="no"
    fi
    log "${OK} ROG Laptop: ${USER_CHOICES[rog_laptop]}"
    
    # Fonts
    echo -e "\n${BOLD}7. Font Installation:${NC}"
    if confirm "Install recommended fonts (JetBrains Mono, Noto, etc.)?" "y"; then
        USER_CHOICES[install_fonts]="yes"
    else
        USER_CHOICES[install_fonts]="no"
    fi
    log "${OK} Install Fonts: ${USER_CHOICES[install_fonts]}"
    
    # Bluetooth
    echo -e "\n${BOLD}8. Bluetooth:${NC}"
    if confirm "Configure Bluetooth support?" "y"; then
        USER_CHOICES[configure_bluetooth]="yes"
    else
        USER_CHOICES[configure_bluetooth]="no"
    fi
    log "${OK} Bluetooth: ${USER_CHOICES[configure_bluetooth]}"
    
    # Zsh
    echo -e "\n${BOLD}9. Shell:${NC}"
    if confirm "Install and configure Zsh with Starship prompt?" "y"; then
        USER_CHOICES[configure_zsh]="yes"
    else
        USER_CHOICES[configure_zsh]="no"
    fi
    log "${OK} Zsh: ${USER_CHOICES[configure_zsh]}"
    
    # Confirmation
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Display Manager : ${GREEN}${USER_CHOICES[display_manager]}${NC}"
    echo -e "  Status Bar      : ${GREEN}${USER_CHOICES[status_bar]}${NC}"
    echo -e "  File Manager    : ${GREEN}${USER_CHOICES[file_manager]}${NC}"
    echo -e "  Lockscreen      : ${GREEN}${USER_CHOICES[lockscreen]}${NC}"
    echo -e "  Dotfiles        : ${GREEN}${USER_CHOICES[custom_dots]}${NC}"
    echo -e "  ROG Support     : ${GREEN}${USER_CHOICES[rog_laptop]}${NC}"
    echo -e "  Fonts           : ${GREEN}${USER_CHOICES[install_fonts]}${NC}"
    echo -e "  Bluetooth       : ${GREEN}${USER_CHOICES[configure_bluetooth]}${NC}"
    echo -e "  Zsh             : ${GREEN}${USER_CHOICES[configure_zsh]}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if ! confirm "Proceed with installation?" "y"; then
        log "${INFO} Installation cancelled by user."
        exit 0
    fi
}

#=============================================================================
# INSTALLATION FUNCTIONS
#=============================================================================
install_base_packages() {
    log_section "Installing Base Packages"
    source "$PACKAGES_DIR/base.lst"
}

install_hyprland_packages() {
    log_section "Installing Hyprland & Core Components"
    source "$PACKAGES_DIR/hyprland.lst"
}

detect_and_install_gpu_drivers() {
    log_section "Detecting & Installing GPU Drivers"
    source "$SCRIPTS_DIR/gpu-detect.sh"
}

install_display_manager() {
    log_section "Installing Display Manager"
    
    case "${USER_CHOICES[display_manager]}" in
        sddm)
            source "$SCRIPTS_DIR/sddm-install.sh"
            ;;
        ly)
            source "$SCRIPTS_DIR/ly-install.sh"
            ;;
        none)
            log "${INFO} Skipping display manager installation (TTY login)"
            ;;
    esac
}

install_status_bar() {
    log_section "Installing Status Bar"
    
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
    log_section "Installing File Manager"
    
    case "${USER_CHOICES[file_manager]}" in
        dolphin)
            source "$SCRIPTS_DIR/dolphin-install.sh"
            ;;
        nemo)
            source "$SCRIPTS_DIR/nemo-install.sh"
            ;;
    esac
}

install_lockscreen() {
    log_section "Installing Lockscreen"
    
    install_pkg hyprlock
    install_pkg hypridle
    
    if [[ "${USER_CHOICES[lockscreen]}" == "both" ]]; then
        install_pkg wlogout
    fi
}

install_fonts() {
    if [[ "${USER_CHOICES[install_fonts]}" == "yes" ]]; then
        log_section "Installing Fonts"
        source "$SCRIPTS_DIR/fonts-install.sh"
    fi
}

configure_bluetooth() {
    if [[ "${USER_CHOICES[configure_bluetooth]}" == "yes" ]]; then
        log_section "Configuring Bluetooth"
        source "$SCRIPTS_DIR/bluetooth-install.sh"
    fi
}

install_rog_support() {
    if [[ "${USER_CHOICES[rog_laptop]}" == "yes" ]]; then
        log_section "Installing ASUS ROG Support"
        source "$SCRIPTS_DIR/rog-install.sh"
    fi
}

configure_zsh() {
    if [[ "${USER_CHOICES[configure_zsh]}" == "yes" ]]; then
        log_section "Configuring Zsh"
        source "$SCRIPTS_DIR/zsh-install.sh"
    fi
}

apply_dotfiles() {
    log_section "Applying Dotfiles"
    
    case "${USER_CHOICES[custom_dots]}" in
        default)
            source "$SCRIPTS_DIR/dotfiles-apply.sh" "default"
            ;;
        custom)
            source "$SCRIPTS_DIR/dotfiles-apply.sh" "custom" "${USER_CHOICES[custom_dots_url]}"
            ;;
        minimal)
            source "$SCRIPTS_DIR/dotfiles-apply.sh" "minimal"
            ;;
    esac
}

install_themes() {
    log_section "Installing Themes"
    source "$SCRIPTS_DIR/themes-install.sh"
}

setup_wallpapers() {
    log_section "Setting Up Wallpapers"
    source "$SCRIPTS_DIR/wallpaper-setup.sh"
}

run_post_install() {
    log_section "Post-Installation Configuration"
    source "$SCRIPTS_DIR/post-install.sh"
}

enable_services() {
    log_section "Enabling System Services"
    
    log "${INFO} Enabling essential services..."
    
    # Network Manager
    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    log "${OK} NetworkManager enabled"
    
    # Display Manager
    case "${USER_CHOICES[display_manager]}" in
        sddm)
            sudo systemctl enable sddm 2>/dev/null || true
            log "${OK} SDDM enabled"
            ;;
        ly)
            sudo systemctl enable ly 2>/dev/null || true
            log "${OK} Ly enabled"
            ;;
    esac
    
    # Bluetooth
    if [[ "${USER_CHOICES[configure_bluetooth]}" == "yes" ]]; then
        sudo systemctl enable --now bluetooth 2>/dev/null || true
        log "${OK} Bluetooth enabled"
    fi
    
    # Pipewire
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
    log "${OK} Pipewire audio enabled"
}

#=============================================================================
# MAIN INSTALLATION FLOW
#=============================================================================
main() {
    # Pre-flight checks
    check_root
    check_arch
    check_internet
    
    # Show banner and configuration menu
    show_banner
    configuration_menu
    
    # Start installation
    log_section "Starting Installation"
    log "${INFO} Installation started at $(date)"
    log "${INFO} Log file: $LOG_FILE"
    
    # Core installation
    install_aur_helper
    install_base_packages
    detect_and_install_gpu_drivers
    install_hyprland_packages
    
    # User-selected components
    install_display_manager
    install_status_bar
    install_file_manager
    install_lockscreen
    install_fonts
    configure_bluetooth
    install_rog_support
    configure_zsh
    
    # Install themes
    install_themes
    
    # Apply configurations
    apply_dotfiles
    
    # Setup wallpapers
    setup_wallpapers
    
    # Post-installation
    run_post_install
    
    # Enable services
    enable_services
    
    # Completion
    log_section "Installation Complete!"
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           s4d Hyprland Installation Complete!                 ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${INFO} Please reboot your system to start using Hyprland"
    echo -e "${INFO} After reboot, select Hyprland from your display manager"
    echo ""
    echo -e "${WARN} Default Keybindings:"
    echo -e "    ${CYAN}Super + T${NC}      : Terminal (Kitty)"
    echo -e "    ${CYAN}Super + A${NC}      : App Launcher (Rofi)"
    echo -e "    ${CYAN}Super + E${NC}      : File Manager"
    echo -e "    ${CYAN}Super + Q${NC}      : Close Window"
    echo -e "    ${CYAN}Super + L${NC}      : Lock Screen"
    echo -e "    ${CYAN}Super + /${NC}      : Keybindings Help"
    echo ""
    echo -e "${INFO} Log file saved: $LOG_FILE"
    echo ""
    
    if confirm "Reboot now?"; then
        sudo reboot
    fi
}

# Run main function
main "$@"
