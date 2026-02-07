#!/bin/bash
#=============================================================================
# SHARED FUNCTIONS — Single source of truth for all s4d scripts
#=============================================================================

# Guard: only load once
[[ -n "${_S4D_FUNCTIONS_LOADED:-}" ]] && return 0
_S4D_FUNCTIONS_LOADED=1

#=============================================================================
# COLORS & STATUS ICONS
#=============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'

OK="${GREEN}[✓]${NC}"
ERROR="${RED}[✗]${NC}"
INFO="${BLUE}[i]${NC}"
WARN="${YELLOW}[!]${NC}"
ASK="${MAGENTA}[?]${NC}"

# Log file (set by main script, fallback to /tmp)
LOG_FILE="${LOG_FILE:-/tmp/s4d-hyprland-install.log}"

# Track failed packages
FAILED_PACKAGES=()

#=============================================================================
# LOGGING
#=============================================================================
log() {
    echo -e "$1" | tee -a "$LOG_FILE" 2>/dev/null
}

log_section() {
    echo "" | tee -a "$LOG_FILE" 2>/dev/null
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE" 2>/dev/null
    echo -e "${BOLD}${WHITE}  $1${NC}" | tee -a "$LOG_FILE" 2>/dev/null
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE" 2>/dev/null
}

#=============================================================================
# PACKAGE MANAGEMENT — NEVER FATAL
# Always returns 0. Logs warnings for failures. Tracks failed packages.
#=============================================================================
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

    # Try official repos first
    if pacman -Si "$pkg" &>/dev/null 2>&1; then
        if sudo pacman -S --noconfirm --needed "$pkg" &>>"$LOG_FILE"; then
            log "${OK} $pkg installed"
            return 0
        fi
    fi

    # Try AUR via yay
    if command -v yay &>/dev/null; then
        if yay -S --noconfirm --needed --removemake --cleanafter "$pkg" &>>"$LOG_FILE"; then
            log "${OK} $pkg installed (AUR)"
            return 0
        fi
    fi

    # Try AUR via paru
    if command -v paru &>/dev/null; then
        if paru -S --noconfirm --needed "$pkg" &>>"$LOG_FILE"; then
            log "${OK} $pkg installed (AUR)"
            return 0
        fi
    fi

    log "${WARN} Could not install $pkg — skipping"
    FAILED_PACKAGES+=("$pkg")
    return 0  # Never fatal
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
    gpu_info=$(lspci -k 2>/dev/null | grep -EA3 'VGA|3D|Display' || true)

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

is_laptop() {
    [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]
}

#=============================================================================
# FILE OPERATIONS
#=============================================================================
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        log "${INFO} Backed up $file"
    fi
}

safe_copy() {
    local src="$1"
    local dst="$2"
    [[ -f "$dst" ]] && backup_file "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
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
            log "${WARN} Could not enable user service $service"
    else
        sudo systemctl enable --now "$service" 2>/dev/null && \
            log "${OK} System service $service enabled" || \
            log "${WARN} Could not enable system service $service"
    fi
}

#=============================================================================
# SUMMARY
#=============================================================================
show_failed_packages() {
    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        echo ""
        log "${WARN} The following packages could not be installed:"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            log "    - $pkg"
        done
        log "${INFO} You can install them manually later with: yay -S <package>"
        echo ""
    fi
}
