#!/bin/bash
#=============================================================================
# GPU DETECTION & DRIVER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

has_nvidia() { lspci -k 2>/dev/null | grep -iA2 'VGA\|3D' | grep -qi 'nvidia'; }
has_amd()    { lspci -k 2>/dev/null | grep -iA2 'VGA\|3D' | grep -qi 'amd\|radeon'; }
has_intel()  { lspci -k 2>/dev/null | grep -iA2 'VGA\|3D' | grep -qi 'intel'; }

install_nvidia_drivers() {
    log "${INFO} Installing NVIDIA drivers..."

    for krnl in $(cat /usr/lib/modules/*/pkgbase 2>/dev/null); do
        install_pkg "${krnl}-headers"
    done

    for pkg in nvidia-dkms nvidia-utils nvidia-settings libva libva-nvidia-driver; do
        install_pkg "$pkg"
    done

    # mkinitcpio modules
    if [[ -f /etc/mkinitcpio.conf ]] && ! grep -qE '^MODULES=.*nvidia' /etc/mkinitcpio.conf; then
        sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        log "${OK} NVIDIA modules added to mkinitcpio"
    fi

    # modprobe
    if [[ ! -f /etc/modprobe.d/nvidia.conf ]]; then
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    fi

    # GRUB
    if [[ -f /etc/default/grub ]]; then
        if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)/\1 nvidia-drm.modeset=1 nvidia_drm.fbdev=1/' /etc/default/grub
            sudo grub-mkconfig -o /boot/grub/grub.cfg &>>"$LOG_FILE" || true
        fi
    fi

    sudo mkinitcpio -P &>>"$LOG_FILE" || true

    mkdir -p "$HOME/.config/hypr/settings"
    cat > "$HOME/.config/hypr/settings/nvidia.conf" << 'EOF'
# ── NVIDIA-specific Configuration ─────────────────────────────────────────────
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

cursor {
    no_hardware_cursors = 1
}
EOF

    # Enable nvidia config in hyprland.conf
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hypr_conf" ]]; then
        sed -i 's|^# source = ~/.config/hypr/settings/nvidia.conf|source = ~/.config/hypr/settings/nvidia.conf|' "$hypr_conf"
    fi

    log "${OK} NVIDIA drivers installed"
}

install_amd_drivers() {
    log "${INFO} Installing AMD drivers..."

    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf 2>/dev/null || true
        sudo pacman -Sy &>/dev/null || true
    fi

    for pkg in mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver xf86-video-amdgpu; do
        install_pkg "$pkg"
    done

    mkdir -p "$HOME/.config/hypr/settings"
    cat > "$HOME/.config/hypr/settings/amd.conf" << 'EOF'
# ── AMD-specific Configuration ────────────────────────────────────────────────
env = LIBVA_DRIVER_NAME,radeonsi
env = VDPAU_DRIVER,radeonsi
EOF

    # Enable amd config in hyprland.conf
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hypr_conf" ]]; then
        sed -i 's|^# source = ~/.config/hypr/settings/amd.conf|source = ~/.config/hypr/settings/amd.conf|' "$hypr_conf"
    fi

    log "${OK} AMD drivers installed"
}

install_intel_drivers() {
    log "${INFO} Installing Intel drivers..."

    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf 2>/dev/null || true
        sudo pacman -Sy &>/dev/null || true
    fi

    for pkg in mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver; do
        install_pkg "$pkg"
    done

    mkdir -p "$HOME/.config/hypr/settings"
    cat > "$HOME/.config/hypr/settings/intel.conf" << 'EOF'
# ── Intel-specific Configuration ──────────────────────────────────────────────
env = LIBVA_DRIVER_NAME,iHD
EOF

    # Enable intel config in hyprland.conf
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hypr_conf" ]]; then
        sed -i 's|^# source = ~/.config/hypr/settings/intel.conf|source = ~/.config/hypr/settings/intel.conf|' "$hypr_conf"
    fi

    log "${OK} Intel drivers installed"
}

# Main — auto-detect, no interactive prompts
log_section "GPU Detection"

gpu_found=false

if has_nvidia; then
    log "${INFO} NVIDIA GPU detected"
    install_nvidia_drivers
    gpu_found=true
fi

if has_amd; then
    log "${INFO} AMD GPU detected"
    install_amd_drivers
    gpu_found=true
fi

if has_intel; then
    log "${INFO} Intel GPU detected"
    install_intel_drivers
    gpu_found=true
fi

if ! $gpu_found; then
    log "${WARN} No recognized GPU — installing generic mesa"
    install_pkg "mesa"
fi

log "${OK} GPU driver setup done"
