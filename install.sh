#!/bin/bash
#=============================================================================
# s4d Hyprland — Installation Wizard
# Minimal, Bloat-Free Hyprland Setup for Arch Linux
#=============================================================================

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
# TUI — GRADIENT COLORS
#=============================================================================
GRAD1='\033[38;2;0;255;255m'
GRAD2='\033[38;2;0;210;255m'
GRAD3='\033[38;2;0;170;255m'
GRAD4='\033[38;2;60;130;255m'
GRAD5='\033[38;2;120;90;255m'
GRAD6='\033[38;2;170;60;255m'
DIM='\033[2m'
BWHITE='\033[1;37m'

#=============================================================================
# TUI — HEADER
#=============================================================================
show_header() {
    clear
    echo ""
    echo -e "${GRAD1}    ███████╗  ██╗  ██╗  ██████╗ ${NC}"
    echo -e "${GRAD2}    ██╔════╝  ██║  ██║  ██╔══██╗${NC}"
    echo -e "${GRAD3}    ███████╗  ███████║  ██║  ██║${NC}"
    echo -e "${GRAD4}    ╚════██║  ╚════██║  ██║  ██║${NC}"
    echo -e "${GRAD5}    ███████║       ██║  ██████╔╝${NC}"
    echo -e "${GRAD6}    ╚══════╝       ╚═╝  ╚═════╝ ${NC}"
    echo ""
    echo -e "    ${DIM}Minimal Hyprland  ·  Arch Linux${NC}"
    echo ""
}

#=============================================================================
# TUI — MENU HELPERS
#=============================================================================
CHOICE=""

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    local count=${#options[@]}

    echo -e "\n  ${BWHITE}${prompt}${NC}\n"

    for i in "${!options[@]}"; do
        local num=$((i + 1))
        echo -e "    ${GRAD3}${num}${NC} ${DIM}›${NC} ${options[$i]}"
    done

    echo ""
    while true; do
        echo -en "    ${GRAD4}▸${NC} "
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
            CHOICE=$choice
            return 0
        fi
        echo -e "      ${DIM}Enter 1-${count}${NC}"
    done
}

ask_yn() {
    local prompt="$1"
    local default="${2:-n}"
    local hint="y/N"
    [[ "$default" == "y" ]] && hint="Y/n"

    echo ""
    echo -en "  ${BWHITE}${prompt}${NC} ${DIM}[${hint}]${NC} ${GRAD4}▸${NC} "
    read -r response
    response=${response:-$default}
    [[ "$response" =~ ^[Yy] ]]
}

#=============================================================================
# TUI — SPINNER & STEP RUNNER
#=============================================================================
_SPIN_PID=""

_spin() {
    local msg="$1"
    local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    tput civis 2>/dev/null
    while true; do
        printf "\r  \033[0;36m%s\033[0m %-55s" "${chars:i%${#chars}:1}" "$msg"
        i=$((i + 1))
        sleep 0.08
    done
}

run_step() {
    local msg="$1"
    shift

    S4D_QUIET=true

    _spin "$msg" &
    _SPIN_PID=$!

    "$@" >> "$LOG_FILE" 2>&1
    local ret=$?

    kill "$_SPIN_PID" 2>/dev/null
    wait "$_SPIN_PID" 2>/dev/null
    _SPIN_PID=""

    tput cnorm 2>/dev/null
    S4D_QUIET=false

    if [[ $ret -eq 0 ]]; then
        printf "\r  \033[0;32m●\033[0m %-55s\n" "$msg"
    else
        printf "\r  \033[0;33m●\033[0m %-55s\n" "$msg"
    fi

    return 0
}

#=============================================================================
# CLEANUP TRAP
#=============================================================================
cleanup() {
    tput cnorm 2>/dev/null
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
    [[ -n "${_SPIN_PID:-}" ]] && kill "$_SPIN_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM

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
# CONFIGURATION MENU
#=============================================================================
configuration_menu() {
    show_header

    echo -e "  ${GRAD1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BWHITE}Configure Installation${NC}"
    echo -e "  ${GRAD1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 1. Display Manager
    ask_choice "Display Manager" \
        "SDDM ${DIM}(Feature-rich)${NC}" \
        "Ly ${DIM}(Minimal TUI)${NC}" \
        "None ${DIM}(TTY Login)${NC}"
    case $CHOICE in
        1) USER_CHOICES[display_manager]="sddm" ;;
        2) USER_CHOICES[display_manager]="ly" ;;
        3) USER_CHOICES[display_manager]="none" ;;
    esac

    # 2. Status Bar
    ask_choice "Status Bar" \
        "Waybar ${DIM}(Feature-rich)${NC}" \
        "DankMaterialShell ${DIM}(Modern Desktop Shell)${NC}"
    case $CHOICE in
        1) USER_CHOICES[status_bar]="waybar" ;;
        2) USER_CHOICES[status_bar]="dankms" ;;
    esac

    # 3. File Manager
    ask_choice "File Manager" \
        "Dolphin ${DIM}(KDE)${NC}" \
        "Nemo ${DIM}(GTK, Lightweight)${NC}"
    case $CHOICE in
        1) USER_CHOICES[file_manager]="dolphin" ;;
        2) USER_CHOICES[file_manager]="nemo" ;;
    esac

    # 4. Lockscreen
    ask_choice "Lockscreen" \
        "Hyprlock" \
        "Hyprlock + Wlogout"
    case $CHOICE in
        1) USER_CHOICES[lockscreen]="hyprlock" ;;
        2) USER_CHOICES[lockscreen]="both" ;;
    esac

    # 5. Dotfiles
    ask_choice "Dotfiles" \
        "Default s4d ${DIM}(Recommended)${NC}" \
        "Custom ${DIM}(Git URL)${NC}" \
        "Minimal ${DIM}(Bare essentials)${NC}"
    case $CHOICE in
        1) USER_CHOICES[dotfiles]="default" ;;
        2)
            USER_CHOICES[dotfiles]="custom"
            echo -en "    ${DIM}Git URL:${NC} ${GRAD4}▸${NC} "
            read -r USER_CHOICES[custom_dots_url]
            ;;
        3) USER_CHOICES[dotfiles]="minimal" ;;
    esac

    # 6-9: Yes/No options
    if ask_yn "ASUS ROG Laptop?" "n"; then
        USER_CHOICES[rog_laptop]="yes"
    else
        USER_CHOICES[rog_laptop]="no"
    fi

    if ask_yn "Install Fonts?" "y"; then
        USER_CHOICES[install_fonts]="yes"
    else
        USER_CHOICES[install_fonts]="no"
    fi

    if ask_yn "Bluetooth?" "y"; then
        USER_CHOICES[configure_bluetooth]="yes"
    else
        USER_CHOICES[configure_bluetooth]="no"
    fi

    if ask_yn "Zsh + Starship Prompt?" "y"; then
        USER_CHOICES[configure_zsh]="yes"
    else
        USER_CHOICES[configure_zsh]="no"
    fi

    # Summary
    echo ""
    echo -e "  ${GRAD3}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${DIM}Display Manager     ${NC}${WHITE}${USER_CHOICES[display_manager]}${NC}"
    echo -e "  ${DIM}Status Bar          ${NC}${WHITE}${USER_CHOICES[status_bar]}${NC}"
    echo -e "  ${DIM}File Manager        ${NC}${WHITE}${USER_CHOICES[file_manager]}${NC}"
    echo -e "  ${DIM}Lockscreen          ${NC}${WHITE}${USER_CHOICES[lockscreen]}${NC}"
    echo -e "  ${DIM}Dotfiles            ${NC}${WHITE}${USER_CHOICES[dotfiles]}${NC}"
    echo -e "  ${DIM}ROG Support         ${NC}${WHITE}${USER_CHOICES[rog_laptop]}${NC}"
    echo -e "  ${DIM}Fonts               ${NC}${WHITE}${USER_CHOICES[install_fonts]}${NC}"
    echo -e "  ${DIM}Bluetooth           ${NC}${WHITE}${USER_CHOICES[configure_bluetooth]}${NC}"
    echo -e "  ${DIM}Zsh                 ${NC}${WHITE}${USER_CHOICES[configure_zsh]}${NC}"
    echo ""
    echo -e "  ${GRAD3}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if ! ask_yn "Proceed with installation?" "y"; then
        echo -e "\n  ${DIM}Cancelled.${NC}"
        exit 0
    fi
}

#=============================================================================
# PRE-FLIGHT CHECKS
#=============================================================================
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "  ${RED}●${NC} Do not run as root. Sudo will be used when needed."
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        echo -e "  ${RED}●${NC} This script is for Arch Linux only."
        exit 1
    fi
}

#=============================================================================
# INSTALLATION FUNCTIONS
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
    log_section "Fonts"
    source "$SCRIPTS_DIR/fonts-install.sh"
}

configure_bluetooth() {
    log_section "Bluetooth"
    source "$SCRIPTS_DIR/bluetooth-install.sh"
}

install_rog_support() {
    log_section "ASUS ROG Support"
    source "$SCRIPTS_DIR/rog-install.sh"
}

configure_zsh() {
    log_section "Zsh & Starship"
    source "$SCRIPTS_DIR/zsh-install.sh"
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
        sddm)
            sudo systemctl enable sddm 2>/dev/null || true
            log "${OK} SDDM enabled"
            ;;
        ly)
            # ly-install.sh handles full setup; ensure it's enabled
            sudo systemctl disable "getty@tty2.service" 2>/dev/null || true
            if systemctl list-unit-files 2>/dev/null | grep -q "ly@"; then
                sudo systemctl enable --force "ly@tty2.service" 2>/dev/null || true
            fi
            sudo systemctl set-default graphical.target 2>/dev/null || true
            log "${OK} Ly enabled"
            ;;
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

    configuration_menu

    clear
    show_header

    # Pre-flight: internet
    echo -e "  ${DIM}Checking system...${NC}"
    if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
        echo -e "  ${RED}●${NC} No internet connection"
        exit 1
    fi
    echo -e "  ${GREEN}●${NC} Internet"

    # Authenticate once, keep alive for entire install
    echo -e "  ${DIM}Authenticating...${NC}"
    sudo -v || { echo -e "  ${RED}●${NC} Authentication failed"; exit 1; }
    (while true; do sudo -n true; sleep 50; done 2>/dev/null) &
    SUDO_KEEPALIVE_PID=$!
    echo -e "  ${GREEN}●${NC} Authentication"

    echo ""
    echo -e "  ${BWHITE}Installing${NC}"
    echo ""

    # Core
    run_step "Setting up AUR helper"            install_aur_helper
    run_step "Installing base packages"         install_base_packages
    run_step "Detecting GPU & drivers"          detect_and_install_gpu_drivers
    run_step "Installing Hyprland"              install_hyprland_packages

    # User-selected components
    [[ "${USER_CHOICES[display_manager]}" != "none" ]] && \
        run_step "Setting up display manager"   install_display_manager

    run_step "Installing status bar"            install_status_bar
    run_step "Installing file manager"          install_file_manager
    run_step "Setting up lockscreen"            install_lockscreen

    [[ "${USER_CHOICES[install_fonts]}" == "yes" ]] && \
        run_step "Installing fonts"             install_fonts

    [[ "${USER_CHOICES[configure_bluetooth]}" == "yes" ]] && \
        run_step "Configuring Bluetooth"        configure_bluetooth

    [[ "${USER_CHOICES[rog_laptop]}" == "yes" ]] && \
        run_step "Installing ROG support"       install_rog_support

    [[ "${USER_CHOICES[configure_zsh]}" == "yes" ]] && \
        run_step "Configuring Zsh & Starship"   configure_zsh

    # Theming & configs
    run_step "Installing themes"                install_themes
    run_step "Applying dotfiles"                apply_dotfiles
    run_step "Setting up wallpapers"            setup_wallpapers

    # Post-install
    run_step "Post-install configuration"       run_post_install
    run_step "Enabling services"                enable_services

    echo ""

    # Show failed packages if any
    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}●${NC} ${DIM}Some packages could not be installed:${NC}"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            echo -e "    ${DIM}- $pkg${NC}"
        done
        echo ""
    fi

    # Completion
    echo -e "  ${GRAD1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}${BOLD}Installation Complete${NC}"
    echo -e "  ${GRAD1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${DIM}Keybinds${NC}"
    echo -e "    ${WHITE}Super + T${NC}       ${DIM}Terminal${NC}"
    echo -e "    ${WHITE}Super + A${NC}       ${DIM}App Launcher${NC}"
    echo -e "    ${WHITE}Super + E${NC}       ${DIM}File Manager${NC}"
    echo -e "    ${WHITE}Super + Q${NC}       ${DIM}Close Window${NC}"
    echo -e "    ${WHITE}Super + Esc${NC}     ${DIM}Lock${NC}"
    echo -e "    ${WHITE}Super + /${NC}       ${DIM}All Keybinds${NC}"
    echo ""
    echo -e "  ${DIM}Log: $LOG_FILE${NC}"
    echo ""

    echo -en "  ${BWHITE}Reboot now?${NC} ${DIM}[y/N]${NC} ${GRAD4}▸${NC} "
    read -r rb
    [[ "$rb" =~ ^[Yy] ]] && sudo reboot
}

main "$@"
