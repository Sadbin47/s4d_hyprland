#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  s4d Keybindings Help — Display keybindings via rofi/kitty   ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

KEYBINDS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/keybinds/keybinds.conf"

# Parse keybinds from config file
# bindd lines have format: bindd = MODS, KEY, DESCRIPTION, dispatcher, args
parse_keybinds() {
    if [[ ! -f "$KEYBINDS_FILE" ]]; then
        echo "Keybinds file not found"
        return 1
    fi

    echo "╭──────────────────────────────────────────────────────────╮"
    echo "│           s4d Hyprland — Keybindings                     │"
    echo "╰──────────────────────────────────────────────────────────╯"
    echo ""

    local current_section=""

    while IFS= read -r line; do
        # Section headers (comments starting with ━━━)
        if [[ "$line" =~ ^#\ ━━━\ (.+)\ ━━━ ]]; then
            current_section="${BASH_REMATCH[1]}"
            echo "┌─ $current_section"
            continue
        fi

        # Parse bindd lines (described binds)
        if [[ "$line" =~ ^bindd\ =\ (.+),\ (.+),\ (.+),\ (.+) ]]; then
            local mods key desc
            mods=$(echo "${BASH_REMATCH[1]}" | sed 's/\$mainMod/Super/g' | xargs)
            key=$(echo "${BASH_REMATCH[2]}" | xargs)
            desc=$(echo "${BASH_REMATCH[3]}" | xargs)
            printf "│  %-24s  %s\n" "$mods + $key" "$desc"
            continue
        fi

        # Parse regular bind lines for common ones
        if [[ "$line" =~ ^bind[elm]*\ =\ (.+),\ (.+),\ (workspace|movetoworkspace),\ (.+) ]]; then
            continue  # Skip workspace number bindings (too many)
        fi

        if [[ "$line" =~ ^bind[elm]*\ =\ (.+),\ (.+),\ (movefocus),\ (.+) ]]; then
            local mods key direction
            mods=$(echo "${BASH_REMATCH[1]}" | sed 's/\$mainMod/Super/g' | xargs)
            key=$(echo "${BASH_REMATCH[2]}" | xargs)
            direction="${BASH_REMATCH[4]}"
            printf "│  %-24s  Focus %s\n" "$mods + $key" "$direction"
            continue
        fi
    done < "$KEYBINDS_FILE"

    echo ""
    echo "┌─ Workspaces"
    echo "│  Super + 1-0              Switch workspace 1-10"
    echo "│  Super + Shift + 1-0      Move window to workspace"
    echo "│  Super + Scroll           Cycle workspaces"
    echo "│  Super + Tab              Next workspace"
    echo "│  Super + Shift + Tab      Prev workspace"
    echo ""
    echo "┌─ Mouse"
    echo "│  Super + LMB              Move window"
    echo "│  Super + RMB              Resize window"
    echo ""
    echo "┌─ Navigation (Arrows)"
    echo "│  Super + Arrow             Focus direction"
    echo "│  Super + Shift + Arrow     Move window"
    echo "│  Super + Ctrl + Arrow      Resize window"
    echo ""
    echo "┌─ Navigation (Vim)"
    echo "│  Super + H/J/K/L           Focus direction"
    echo "│  Super + Shift + H/J/K/L   Move window"
    echo "│  Super + Ctrl + H/J/K/L    Resize window"
    echo "│  Super + Alt + H/J/K/L     Swap window"
    echo ""
}

# Display method
case "${1:-rofi}" in
    rofi)
        if command -v rofi &>/dev/null; then
            parse_keybinds | rofi -dmenu -p "⌨ Keybinds" -i -markup-rows \
                -theme-str '
                    window { width: 680px; }
                    listview { lines: 25; scrollbar: true; }
                    element { padding: 4px 8px; }
                    element-text { font: "JetBrainsMono Nerd Font 11"; }
                ' 2>/dev/null || true
        else
            parse_keybinds | less
        fi
        ;;
    terminal|term)
        parse_keybinds | less -R
        ;;
    kitty)
        parse_keybinds | kitty --class floating-help -e less -R
        ;;
    raw)
        parse_keybinds
        ;;
    *)
        echo "Usage: keybinds-help.sh {rofi|terminal|kitty|raw}"
        ;;
esac
