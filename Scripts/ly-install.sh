#!/bin/bash
#=============================================================================
# LY (TUI DISPLAY MANAGER) INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Ly display manager..."

# Install Ly
install_pkg "ly"

# Verify Ly actually installed — check every possible binary name/path
LY_BIN=""
for candidate in ly-dm ly; do
    if command -v "$candidate" &>/dev/null; then
        LY_BIN="$(command -v "$candidate")"
        break
    fi
done
[[ -z "$LY_BIN" && -x /usr/bin/ly-dm ]] && LY_BIN="/usr/bin/ly-dm"
[[ -z "$LY_BIN" && -x /usr/bin/ly ]]    && LY_BIN="/usr/bin/ly"

if [[ -z "$LY_BIN" ]]; then
    log "${ERROR} Ly binary not found after installation — aborting Ly setup"
    log "${INFO} You can install Ly manually: yay -S ly"
    return 1 2>/dev/null || exit 1
fi

log "${OK} Ly binary found at: $LY_BIN"

#=============================================================================
# ENSURE HYPRLAND SESSION FILE EXISTS
#=============================================================================
log "${INFO} Ensuring Hyprland session file exists..."

sudo mkdir -p /usr/share/wayland-sessions

# Detect correct Hyprland binary name
HYPR_BIN="Hyprland"
command -v Hyprland &>/dev/null && HYPR_BIN="Hyprland"
command -v hyprland &>/dev/null && HYPR_BIN="hyprland"

cat << DEOF | sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=$HYPR_BIN
Type=Application
DesktopNames=Hyprland
DEOF
sudo chmod 644 /usr/share/wayland-sessions/hyprland.desktop
log "${OK} Created /usr/share/wayland-sessions/hyprland.desktop"

#=============================================================================
# CONFIGURE LY
#=============================================================================
sudo mkdir -p /etc/ly

cat << 'EOF' | sudo tee /etc/ly/config.ini >/dev/null
# Ly configuration
animate = true
animation = 0
bigclock = none
blank_password = false
clear_password = true
clock = %c
default_input = login
hide_borders = false
hide_f1_commands = false
input_len = 255
lang = en
load = true
animation_frame_delay = 10
path = /usr/local/sbin:/usr/local/bin:/usr/bin
restart_cmd = /usr/bin/systemctl reboot
save = true
save_file = /tmp/ly-save
service_name = ly
shutdown_cmd = /usr/bin/systemctl poweroff
sleep_cmd = /usr/bin/systemctl suspend
term_reset_cmd = /usr/bin/tput reset
waylandsessions = /usr/share/wayland-sessions
xsessions = /usr/share/xsessions
initial_info_text = s4d Hyprland
blank_box = true
box_main_color = 6
box_border_color = 6
box_inner_text_color = 7
input_color = 7
EOF

log "${OK} Ly configuration created"

#=============================================================================
# PAM CONFIGURATION — CRITICAL: Ly silently fails without this
#=============================================================================
log "${INFO} Ensuring PAM configuration for Ly..."

# Check if the package installed a PAM file; if not, create one
if [[ ! -f /etc/pam.d/ly ]]; then
    cat << 'PAMEOF' | sudo tee /etc/pam.d/ly >/dev/null
#%PAM-1.0
auth       include    login
account    include    login
password   include    login
session    include    login
PAMEOF
    log "${OK} Created /etc/pam.d/ly (PAM authentication)"
else
    log "${OK} /etc/pam.d/ly already exists"
fi

#=============================================================================
# DISABLE ALL COMPETING DISPLAY MANAGERS
#=============================================================================

for dm in gdm sddm lightdm lxdm greetd; do
    sudo systemctl disable "$dm" 2>/dev/null || true
    sudo systemctl disable "${dm}.service" 2>/dev/null || true
    sudo systemctl stop "$dm" 2>/dev/null || true
done

#=============================================================================
# SET BOOT TARGET
#=============================================================================
sudo systemctl set-default graphical.target
log "${OK} Set default boot target to graphical.target"

#=============================================================================
# DETECT THE LY SERVICE FILE (from installed package)
#=============================================================================
LY_TTY="tty2"

# Discover what service file the package actually provides
LY_SVC_FILE=""
LY_SVC_TYPE=""  # "template" or "simple"

# Check for templated service (ly@.service) — used by upstream and most AUR builds
for path in /usr/lib/systemd/system/ly@.service /etc/systemd/system/ly@.service; do
    if [[ -f "$path" ]]; then
        LY_SVC_FILE="$path"
        LY_SVC_TYPE="template"
        break
    fi
done

# Check for non-templated service (ly.service / ly-dm.service) if no template found
if [[ -z "$LY_SVC_FILE" ]]; then
    for svc in ly.service ly-dm.service; do
        for path in /usr/lib/systemd/system/$svc /etc/systemd/system/$svc; do
            if [[ -f "$path" ]]; then
                LY_SVC_FILE="$path"
                LY_SVC_TYPE="simple"
                break 2
            fi
        done
    done
fi

# Also check via systemctl (in case files are in unusual locations)
if [[ -z "$LY_SVC_FILE" ]]; then
    if systemctl list-unit-files 2>/dev/null | grep -q "ly@\.service"; then
        LY_SVC_TYPE="template"
    elif systemctl list-unit-files 2>/dev/null | grep -q "^ly\.service"; then
        LY_SVC_TYPE="simple"
    elif systemctl list-unit-files 2>/dev/null | grep -q "^ly-dm\.service"; then
        LY_SVC_TYPE="simple"
    fi
fi

log "${INFO} Detected: SVC_FILE=${LY_SVC_FILE:-none} SVC_TYPE=${LY_SVC_TYPE:-none}"

#=============================================================================
# CREATE SERVICE FILE IF NOTHING EXISTS
#=============================================================================
if [[ -z "$LY_SVC_TYPE" ]]; then
    log "${WARN} No Ly service file found — creating ly@.service manually"

    cat << SERVICEEOF | sudo tee /usr/lib/systemd/system/ly@.service >/dev/null
[Unit]
Description=TUI Display Manager (Ly)
After=systemd-user-sessions.service plymouth-quit-wait.service
Conflicts=getty@%i.service
Before=getty@%i.service

[Service]
Type=idle
ExecStartPre=/usr/bin/chvt %I
ExecStart=${LY_BIN}
StandardInput=tty
TTYPath=/dev/%i
TTYReset=yes
TTYVHangup=yes
PAMName=ly
UtmpIdentifier=%I
Restart=always
RestartSec=2

[Install]
WantedBy=graphical.target
Alias=display-manager.service
SERVICEEOF

    LY_SVC_FILE="/usr/lib/systemd/system/ly@.service"
    LY_SVC_TYPE="template"
    log "${OK} Created /usr/lib/systemd/system/ly@.service"
fi

#=============================================================================
# KILL GETTY ON LY'S TTY — NUCLEAR APPROACH
# getty MUST be dead on the target TTY or it will steal the console
#=============================================================================

# 1. Stop immediately
sudo systemctl stop "getty@${LY_TTY}.service" 2>/dev/null || true

# 2. Disable (remove from boot)
sudo systemctl disable "getty@${LY_TTY}.service" 2>/dev/null || true

# 3. Mask (symlink to /dev/null — prevents ANY activation including by logind)
sudo systemctl mask "getty@${LY_TTY}.service" 2>/dev/null || true

# 4. Also mask the autovt instance (systemd-logind auto-spawns these on TTY switch)
sudo systemctl mask "autovt@${LY_TTY}.service" 2>/dev/null || true

# 5. Override autovt for this TTY to point to Ly instead of getty
#    This is the CRITICAL step — logind calls autovt@ttyN.service when switching TTYs
if [[ "$LY_SVC_TYPE" == "template" ]]; then
    sudo mkdir -p /etc/systemd/system
    sudo ln -sf "${LY_SVC_FILE}" "/etc/systemd/system/autovt@${LY_TTY}.service"
    log "${OK} Redirected autovt@${LY_TTY}.service -> ly@.service"
fi

# 6. Reduce NAutoVTs so logind doesn't auto-spawn getty on our TTY
#    TTY2 = index 2, so if NAutoVTs=1, logind only auto-spawns getty on tty1
if [[ -f /etc/systemd/logind.conf ]]; then
    if ! grep -q "^NAutoVTs=" /etc/systemd/logind.conf; then
        # Add NAutoVTs=1 to only auto-spawn getty on tty1
        sudo sed -i 's/^#NAutoVTs=.*/NAutoVTs=1/' /etc/systemd/logind.conf 2>/dev/null || \
        echo "NAutoVTs=1" | sudo tee -a /etc/systemd/logind.conf >/dev/null
        log "${OK} Set NAutoVTs=1 in logind.conf"
    fi
fi

log "${OK} Killed and masked all getty on ${LY_TTY}"

#=============================================================================
# ENABLE LY SERVICE
#=============================================================================
sudo systemctl daemon-reload

if [[ "$LY_SVC_TYPE" == "template" ]]; then
    sudo systemctl enable --force "ly@${LY_TTY}.service"
    log "${OK} Enabled ly@${LY_TTY}.service"
elif [[ "$LY_SVC_TYPE" == "simple" ]]; then
    # For non-templated service, check which name exists
    if systemctl list-unit-files 2>/dev/null | grep -q "^ly-dm\.service"; then
        sudo systemctl enable --force "ly-dm.service"
        log "${OK} Enabled ly-dm.service"
    else
        sudo systemctl enable --force "ly.service"
        log "${OK} Enabled ly.service"
    fi
fi

#=============================================================================
# VERIFY EVERYTHING
#=============================================================================
log "${INFO} Verifying Ly setup..."

VERIFY_OK=true

# Check Ly service is enabled
LY_ENABLED=false
for svc in "ly@${LY_TTY}.service" "ly.service" "ly-dm.service"; do
    if systemctl is-enabled "$svc" &>/dev/null 2>&1; then
        log "${OK} $svc is enabled"
        LY_ENABLED=true
        break
    fi
done
if [[ "$LY_ENABLED" == false ]]; then
    log "${WARN} Ly service is NOT enabled — attempting force enable"
    sudo systemctl enable --force "ly@${LY_TTY}.service" 2>/dev/null || true
    VERIFY_OK=false
fi

# Check getty is masked
GETTY_STATE=$(systemctl is-enabled "getty@${LY_TTY}.service" 2>/dev/null || echo "unknown")
if [[ "$GETTY_STATE" == "masked" || "$GETTY_STATE" == "masked-runtime" ]]; then
    log "${OK} getty@${LY_TTY}.service is masked"
else
    log "${WARN} getty@${LY_TTY}.service state: $GETTY_STATE — re-masking"
    sudo systemctl mask "getty@${LY_TTY}.service" 2>/dev/null || true
    VERIFY_OK=false
fi

# Check boot target
CURRENT_TARGET=$(systemctl get-default 2>/dev/null || echo "unknown")
if [[ "$CURRENT_TARGET" == "graphical.target" ]]; then
    log "${OK} Boot target: graphical.target"
else
    log "${WARN} Boot target is $CURRENT_TARGET, fixing..."
    sudo systemctl set-default graphical.target
    VERIFY_OK=false
fi

# Check Hyprland session
if [[ -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
    log "${OK} Hyprland session file exists"
else
    log "${WARN} Hyprland session file not found!"
    VERIFY_OK=false
fi

# Check Hyprland binary
if command -v Hyprland &>/dev/null || command -v hyprland &>/dev/null; then
    log "${OK} Hyprland binary found"
else
    log "${WARN} Hyprland binary not in PATH (will be available after package install)"
fi

# List sessions for debugging
log "${INFO} Available wayland sessions:"
if [[ -d /usr/share/wayland-sessions ]]; then
    for session in /usr/share/wayland-sessions/*.desktop; do
        if [[ -f "$session" ]]; then
            name=$(grep "^Name=" "$session" | cut -d= -f2)
            log "         - $name ($(basename "$session"))"
        fi
    done
fi

if [[ "$VERIFY_OK" == true ]]; then
    log "${OK} Ly display manager setup: ALL CHECKS PASSED"
else
    log "${WARN} Some checks needed fixing — review the log above"
fi

#=============================================================================
# PATCH EXISTING SERVICE FILE: Ensure chvt + Restart=always
#=============================================================================
# Package-provided service files may lack chvt (causes Ly to fail on TTY grab)
if [[ -n "$LY_SVC_FILE" && -f "$LY_SVC_FILE" ]]; then
    # Add ExecStartPre=chvt if missing
    if ! grep -q "ExecStartPre.*chvt" "$LY_SVC_FILE"; then
        sudo sed -i '/^ExecStart=/i ExecStartPre=/usr/bin/chvt %I' "$LY_SVC_FILE"
        log "${OK} Patched $LY_SVC_FILE: added ExecStartPre=chvt"
    fi
    # Upgrade Restart from on-failure to always
    if grep -q "Restart=on-failure" "$LY_SVC_FILE"; then
        sudo sed -i 's/Restart=on-failure/Restart=always/' "$LY_SVC_FILE"
        log "${OK} Patched $LY_SVC_FILE: Restart=always"
    fi
    sudo systemctl daemon-reload
fi

#=============================================================================
# TTY AUTO-START FALLBACK (safety net if Ly ever fails to launch)
#=============================================================================
# If the user ends up at a raw TTY login on tty1/tty2, auto-start Hyprland
# after login — so they never get stuck at a blank TTY.
log "${INFO} Adding TTY auto-start fallback to .zprofile..."

S4D_ZPROFILE="$HOME/.zprofile"
if [[ -f "$S4D_ZPROFILE" ]] && ! grep -q 'HYPRLAND_TTY_AUTOSTART' "$S4D_ZPROFILE"; then
    cat << 'AUTOEOF' >> "$S4D_ZPROFILE"

# ── Auto-start Hyprland from TTY (fallback if DM fails) ── #HYPRLAND_TTY_AUTOSTART
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]] && [[ "$(tty)" == /dev/tty[12] ]]; then
    echo "Starting Hyprland..."
    exec Hyprland
fi
AUTOEOF
    log "${OK} Added TTY auto-start fallback to .zprofile"
fi

#=============================================================================
# CREATE start-hyprland HELPER
#=============================================================================
mkdir -p "$HOME/.local/bin"

cat << 'HELPEREOF' > "$HOME/.local/bin/start-hyprland"
#!/bin/sh
# Convenience launcher — use if you end up at a raw TTY
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    echo "A graphical session is already running."
    exit 1
fi
exec Hyprland
HELPEREOF
chmod +x "$HOME/.local/bin/start-hyprland"
log "${OK} Created ~/.local/bin/start-hyprland helper"

log "${INFO} Ly will appear on ${LY_TTY} after reboot"
log "${INFO} Select 'Hyprland' from the session list and login"
log "${INFO} If Ly fails, logging in at TTY will auto-start Hyprland"
