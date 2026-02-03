#!/bin/bash
#=============================================================================
# SHARED FUNCTIONS - Common utilities for all scripts
#=============================================================================

# Colors (only define if not already set)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m'

    readonly OK="${GREEN}[✓]${NC}"
    readonly ERROR="${RED}[✗]${NC}"
    readonly INFO="${BLUE}[i]${NC}"
    readonly WARN="${YELLOW}[!]${NC}"
    readonly ASK="${MAGENTA}[?]${NC}"
fi

# Log file (should be set by main script)
LOG_FILE="${LOG_FILE:-/tmp/s4d-hyprland-install.log}"

#=============================================================================
# LOGGING
#=============================================================================
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

#=============================================================================
# PACKAGE MANAGEMENT
#=============================================================================
pkg_installed() {
    pacman -Q "$1" &>/dev/null
}

aur_available() {
    if command -v yay &>/dev/null; then
        yay -Si "$1" &>/dev/null
    elif command -v paru &>/dev/null; then
        paru -Si "$1" &>/dev/null
    else
        return 1
    fi
}

install_pkg() {
    local pkg="$1"
    
    if pkg_installed "$pkg"; then
        log "${OK} $pkg is already installed"
        return 0
    fi
    
    log "${INFO} Installing $pkg..."
    
    # Try pacman first (use tee to show output AND log it - prevents hidden prompts)
    if pacman -Si "$pkg" &>/dev/null; then
        if sudo pacman -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            log "${OK} $pkg installed successfully"
            return 0
        fi
    fi
    
    # Try AUR (show output for compilation progress and potential prompts)
    if command -v yay &>/dev/null; then
        if yay -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            log "${OK} $pkg installed from AUR"
            return 0
        fi
    elif command -v paru &>/dev/null; then
        if paru -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            log "${OK} $pkg installed from AUR"
            return 0
        fi
    fi
    
    log "${WARN} Failed to install $pkg"
    return 1
}

install_pkg_list() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        install_pkg "$pkg"
    done
}

#=============================================================================
# USER INPUT
#=============================================================================
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

#=============================================================================
# GPU DETECTION
#=============================================================================
detect_gpu() {
    local gpu_info
    gpu_info=$(lspci -k | grep -EA3 'VGA|3D|Display')
    
    if echo "$gpu_info" | grep -qi "nvidia"; then
        echo "nvidia"
    elif echo "$gpu_info" | grep -qi "amd\|radeon"; then
        echo "amd"
    elif echo "$gpu_info" | grep -qi "intel"; then
        echo "intel"
    else
        echo "unknown"
    fi
}

detect_gpu_type() {
    # Check if it's a laptop (has battery)
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        echo "laptop"
    else
        echo "desktop"
    fi
}

#=============================================================================
# FILE OPERATIONS
#=============================================================================
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        log "${INFO} Backed up $file to $backup"
    fi
}

safe_copy() {
    local src="$1"
    local dst="$2"
    
    if [[ -f "$dst" ]]; then
        backup_file "$dst"
    fi
    
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
}

safe_link() {
    local src="$1"
    local dst="$2"
    
    if [[ -e "$dst" ]]; then
        backup_file "$dst"
        rm -rf "$dst"
    fi
    
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
}

#=============================================================================
# SYSTEM DETECTION
#=============================================================================
is_asus_rog() {
    if [ -f /sys/class/dmi/id/product_name ]; then
        grep -qi "rog\|republic of gamers\|asus" /sys/class/dmi/id/product_name 2>/dev/null
    else
        return 1
    fi
}

get_kernel_headers() {
    local kernel
    kernel=$(cat /usr/lib/modules/*/pkgbase 2>/dev/null | head -1)
    echo "${kernel}-headers"
}

#=============================================================================
# SERVICE MANAGEMENT
#=============================================================================
enable_service() {
    local service="$1"
    local user="${2:-system}"
    
    if [[ "$user" == "user" ]]; then
        systemctl --user enable --now "$service" 2>/dev/null && \
            log "${OK} User service $service enabled" || \
            log "${WARN} Failed to enable user service $service"
    else
        sudo systemctl enable --now "$service" 2>/dev/null && \
            log "${OK} System service $service enabled" || \
            log "${WARN} Failed to enable system service $service"
    fi
}

disable_service() {
    local service="$1"
    local user="${2:-system}"
    
    if [[ "$user" == "user" ]]; then
        systemctl --user disable --now "$service" 2>/dev/null || true
    else
        sudo systemctl disable --now "$service" 2>/dev/null || true
    fi
}
