#!/bin/bash
#=============================================================================
# WAYBAR INSTALLATION — Install waybar + styles + layouts
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIGS_DIR="$SCRIPT_DIR/../Configs"
WAYBAR_STYLE="${S4D_WAYBAR_STYLE:-default}"

log "${INFO} Installing Waybar..."

install_pkg "waybar"

# Copy all waybar configs
if [[ -d "$CONFIGS_DIR/waybar" ]]; then
    mkdir -p "$HOME/.config/waybar"

    # Copy main config and color palette
    cp -f "$CONFIGS_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc" 2>/dev/null || true
    cp -f "$CONFIGS_DIR/waybar/mocha.css" "$HOME/.config/waybar/mocha.css" 2>/dev/null || true

    # Copy all styles
    if [[ -d "$CONFIGS_DIR/waybar/styles" ]]; then
        mkdir -p "$HOME/.config/waybar/styles"
        cp -rf "$CONFIGS_DIR/waybar/styles/"* "$HOME/.config/waybar/styles/" 2>/dev/null || true
        log "${OK} Waybar styles installed"
    fi

    # Copy all layouts
    if [[ -d "$CONFIGS_DIR/waybar/layouts" ]]; then
        mkdir -p "$HOME/.config/waybar/layouts"
        cp -rf "$CONFIGS_DIR/waybar/layouts/"* "$HOME/.config/waybar/layouts/" 2>/dev/null || true
        log "${OK} Waybar layouts installed"
    fi

    # Save default config for layout switching
    cp -f "$HOME/.config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc.default" 2>/dev/null || true

    # Apply selected style
    if [[ -f "$HOME/.config/waybar/styles/${WAYBAR_STYLE}.css" ]]; then
        cp -f "$HOME/.config/waybar/styles/${WAYBAR_STYLE}.css" "$HOME/.config/waybar/style.css"
        log "${OK} Applied waybar style: $WAYBAR_STYLE"
    elif [[ -f "$CONFIGS_DIR/waybar/styles/default.css" ]]; then
        cp -f "$CONFIGS_DIR/waybar/styles/default.css" "$HOME/.config/waybar/style.css"
        log "${OK} Applied waybar style: default"
    elif [[ -f "$CONFIGS_DIR/waybar/style.css" ]]; then
        cp -f "$CONFIGS_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
    fi

    log "${OK} Waybar configuration installed"
else
    log "${WARN} Waybar configs not found in $CONFIGS_DIR/waybar"
fi

log "${OK} Waybar setup done"
log "${INFO} Switch styles: waybar-style set <style>"
log "${INFO} Available: default, hollow, solid, minimal, flat, compact, floating"
