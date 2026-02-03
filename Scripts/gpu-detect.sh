#!/bin/bash
#=============================================================================
# GPU DETECTION & DRIVER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log_section() {
    echo -e "\n${CYAN}━━━ $1 ━━━${NC}" | tee -a "$LOG_FILE"
}

#=============================================================================
# GPU DETECTION
#=============================================================================
detect_all_gpus() {
    log "${INFO} Detecting GPU(s)..."
    
    readarray -t GPUS < <(lspci -k | grep -EA3 'VGA|3D|Display' | grep -E 'VGA|3D|Display' | awk -F': ' '{print $NF}')
    
    for i in "${!GPUS[@]}"; do
        log "${OK} GPU $((i+1)): ${GPUS[$i]}"
    done
    
    echo "${GPUS[@]}"
}

has_nvidia() {
    lspci -k | grep -iA2 'VGA\|3D' | grep -qi 'nvidia'
}

has_amd() {
    lspci -k | grep -iA2 'VGA\|3D' | grep -qi 'amd\|radeon'
}

has_intel() {
    lspci -k | grep -iA2 'VGA\|3D' | grep -qi 'intel'
}

is_laptop() {
    [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]
}

#=============================================================================
# NVIDIA DRIVER INSTALLATION
#=============================================================================
install_nvidia_drivers() {
    log_section "Installing NVIDIA Drivers"
    
    # Get current kernel headers
    local kernel_headers
    for krnl in $(cat /usr/lib/modules/*/pkgbase 2>/dev/null); do
        kernel_headers="${krnl}-headers"
        install_pkg "$kernel_headers"
    done
    
    # Core NVIDIA packages
    local nvidia_packages=(
        "nvidia-dkms"
        "nvidia-utils"
        "nvidia-settings"
        "libva"
        "libva-nvidia-driver"
    )
    
    for pkg in "${nvidia_packages[@]}"; do
        install_pkg "$pkg"
    done
    
    # Configure NVIDIA modules for mkinitcpio
    log "${INFO} Configuring NVIDIA modules..."
    
    if ! grep -qE '^MODULES=.*nvidia' /etc/mkinitcpio.conf; then
        sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        log "${OK} NVIDIA modules added to mkinitcpio.conf"
    else
        log "${INFO} NVIDIA modules already in mkinitcpio.conf"
    fi
    
    # Create NVIDIA modprobe config
    if [[ ! -f /etc/modprobe.d/nvidia.conf ]]; then
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
        log "${OK} Created /etc/modprobe.d/nvidia.conf"
    fi
    
    # Configure GRUB if present
    if [[ -f /etc/default/grub ]]; then
        log "${INFO} Configuring GRUB for NVIDIA..."
        
        if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)/\1 nvidia-drm.modeset=1/' /etc/default/grub
            log "${OK} Added nvidia-drm.modeset=1 to GRUB"
        fi
        
        if ! grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)/\1 nvidia_drm.fbdev=1/' /etc/default/grub
            log "${OK} Added nvidia_drm.fbdev=1 to GRUB"
        fi
        
        sudo grub-mkconfig -o /boot/grub/grub.cfg &>>"$LOG_FILE"
        log "${OK} GRUB configuration regenerated"
    fi
    
    # Configure systemd-boot if present
    if [[ -d /boot/loader/entries ]]; then
        log "${INFO} Detected systemd-boot, please add 'nvidia-drm.modeset=1 nvidia_drm.fbdev=1' to your boot entry manually"
    fi
    
    # Rebuild initramfs
    log "${INFO} Rebuilding initramfs..."
    sudo mkinitcpio -P &>>"$LOG_FILE"
    log "${OK} Initramfs rebuilt"
    
    # Create Hyprland NVIDIA config
    mkdir -p "$HOME/.config/hypr"
    cat > "$HOME/.config/hypr/nvidia.conf" << 'EOF'
# NVIDIA-specific Hyprland configuration
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct

cursor {
    no_hardware_cursors = true
}
EOF
    log "${OK} Created NVIDIA Hyprland configuration"
}

#=============================================================================
# AMD DRIVER INSTALLATION
#=============================================================================
install_amd_drivers() {
    log_section "Installing AMD Drivers"
    
    local amd_packages=(
        "mesa"
        "lib32-mesa"
        "vulkan-radeon"
        "lib32-vulkan-radeon"
        "libva-mesa-driver"
        "lib32-libva-mesa-driver"
        "mesa-vdpau"
        "lib32-mesa-vdpau"
        "xf86-video-amdgpu"
    )
    
    # Enable multilib if not enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log "${INFO} Enabling multilib repository..."
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
    
    for pkg in "${amd_packages[@]}"; do
        install_pkg "$pkg"
    done
    
    # Create AMD Hyprland config
    mkdir -p "$HOME/.config/hypr"
    cat > "$HOME/.config/hypr/amd.conf" << 'EOF'
# AMD-specific Hyprland configuration
env = LIBVA_DRIVER_NAME,radeonsi
env = VDPAU_DRIVER,radeonsi
EOF
    log "${OK} Created AMD Hyprland configuration"
}

#=============================================================================
# INTEL DRIVER INSTALLATION
#=============================================================================
install_intel_drivers() {
    log_section "Installing Intel Drivers"
    
    local intel_packages=(
        "mesa"
        "lib32-mesa"
        "vulkan-intel"
        "lib32-vulkan-intel"
        "intel-media-driver"
        "libva-intel-driver"
    )
    
    # Enable multilib if not enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log "${INFO} Enabling multilib repository..."
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
    
    for pkg in "${intel_packages[@]}"; do
        install_pkg "$pkg"
    done
    
    # Create Intel Hyprland config
    mkdir -p "$HOME/.config/hypr"
    cat > "$HOME/.config/hypr/intel.conf" << 'EOF'
# Intel-specific Hyprland configuration
env = LIBVA_DRIVER_NAME,iHD
EOF
    log "${OK} Created Intel Hyprland configuration"
}

#=============================================================================
# MAIN GPU DETECTION & INSTALLATION
#=============================================================================
main() {
    log_section "GPU Detection & Driver Installation"
    
    detect_all_gpus
    
    local gpu_installed=false
    
    # Check for NVIDIA
    if has_nvidia; then
        log "${INFO} NVIDIA GPU detected"
        
        if is_laptop; then
            log "${INFO} Laptop detected - installing NVIDIA with optimus support"
        fi
        
        if confirm "Install NVIDIA proprietary drivers?" "y"; then
            install_nvidia_drivers
            gpu_installed=true
        else
            log "${INFO} Skipping NVIDIA driver installation"
            # Install nouveau as fallback
            install_pkg "xf86-video-nouveau"
        fi
    fi
    
    # Check for AMD
    if has_amd; then
        log "${INFO} AMD GPU detected"
        install_amd_drivers
        gpu_installed=true
    fi
    
    # Check for Intel
    if has_intel; then
        log "${INFO} Intel GPU detected"
        install_intel_drivers
        gpu_installed=true
    fi
    
    if ! $gpu_installed; then
        log "${WARN} No supported GPU detected, installing generic drivers..."
        install_pkg "mesa"
        install_pkg "xf86-video-vesa"
    fi
    
    log "${OK} GPU driver installation complete"
}

# Run main
main
