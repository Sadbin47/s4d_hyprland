#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  s4d Waybar Style Switcher                                   ║
# ║  Switch between waybar styles and layouts interactively       ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
STYLES_DIR="$WAYBAR_DIR/styles"
LAYOUTS_DIR="$WAYBAR_DIR/layouts"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/s4d-hyprland"
CURRENT_STYLE_FILE="$CACHE_DIR/current_waybar_style"
CURRENT_LAYOUT_FILE="$CACHE_DIR/current_waybar_layout"

mkdir -p "$CACHE_DIR"

# ── Helpers ──────────────────────────────────────────────────────────────────
notify() { command -v notify-send &>/dev/null && notify-send -a "Waybar" "$@"; }

get_current_style() {
    if [[ -f "$CURRENT_STYLE_FILE" ]]; then
        cat "$CURRENT_STYLE_FILE"
    else
        echo "default"
    fi
}

get_current_layout() {
    if [[ -f "$CURRENT_LAYOUT_FILE" ]]; then
        cat "$CURRENT_LAYOUT_FILE"
    else
        echo "default"
    fi
}

list_styles() {
    local current
    current=$(get_current_style)
    echo "Available styles:"
    for f in "$STYLES_DIR"/*.css; do
        [[ ! -f "$f" ]] && continue
        local name
        name=$(basename "$f" .css)
        local marker=""
        [[ "$name" == "$current" ]] && marker=" ← active"
        echo "  • $name$marker"
    done
}

list_layouts() {
    local current
    current=$(get_current_layout)
    echo "Available layouts:"
    echo "  • default (main config.jsonc)$( [[ "$current" == "default" ]] && echo ' ← active' )"
    for f in "$LAYOUTS_DIR"/*.jsonc; do
        [[ ! -f "$f" ]] && continue
        local name
        name=$(basename "$f" .jsonc)
        local marker=""
        [[ "$name" == "$current" ]] && marker=" ← active"
        echo "  • $name$marker"
    done
}

# ── Set Style ────────────────────────────────────────────────────────────────
set_style() {
    local name="$1"
    local target="$STYLES_DIR/${name}.css"

    if [[ ! -f "$target" ]]; then
        echo "Error: style '$name' not found"
        list_styles
        return 1
    fi

    cp -f "$target" "$WAYBAR_DIR/style.css"
    echo "$name" > "$CURRENT_STYLE_FILE"

    restart_waybar
    notify "Style" "Switched to: $name"
    echo "Waybar style set to: $name"
}

# ── Set Layout ───────────────────────────────────────────────────────────────
set_layout() {
    local name="$1"

    if [[ "$name" == "default" ]]; then
        # Restore original config.jsonc
        if [[ -f "$WAYBAR_DIR/config.jsonc.default" ]]; then
            cp -f "$WAYBAR_DIR/config.jsonc.default" "$WAYBAR_DIR/config.jsonc"
        fi
        echo "default" > "$CURRENT_LAYOUT_FILE"
    else
        local target="$LAYOUTS_DIR/${name}.jsonc"
        if [[ ! -f "$target" ]]; then
            echo "Error: layout '$name' not found"
            list_layouts
            return 1
        fi
        # Backup default config on first layout change
        if [[ ! -f "$WAYBAR_DIR/config.jsonc.default" ]]; then
            cp -f "$WAYBAR_DIR/config.jsonc" "$WAYBAR_DIR/config.jsonc.default"
        fi
        cp -f "$target" "$WAYBAR_DIR/config.jsonc"
        echo "$name" > "$CURRENT_LAYOUT_FILE"
    fi

    restart_waybar
    notify "Layout" "Switched to: $name"
    echo "Waybar layout set to: $name"
}

# ── Cycle Styles ─────────────────────────────────────────────────────────────
next_style() {
    local current
    current=$(get_current_style)
    local styles=()
    for f in "$STYLES_DIR"/*.css; do
        [[ -f "$f" ]] && styles+=("$(basename "$f" .css)")
    done

    [[ ${#styles[@]} -eq 0 ]] && return 1

    local idx=0
    for i in "${!styles[@]}"; do
        if [[ "${styles[$i]}" == "$current" ]]; then
            idx=$(( (i + 1) % ${#styles[@]} ))
            break
        fi
    done

    set_style "${styles[$idx]}"
}

prev_style() {
    local current
    current=$(get_current_style)
    local styles=()
    for f in "$STYLES_DIR"/*.css; do
        [[ -f "$f" ]] && styles+=("$(basename "$f" .css)")
    done

    [[ ${#styles[@]} -eq 0 ]] && return 1

    local count=${#styles[@]}
    local idx=$((count - 1))
    for i in "${!styles[@]}"; do
        if [[ "${styles[$i]}" == "$current" ]]; then
            idx=$(( (i - 1 + count) % count ))
            break
        fi
    done

    set_style "${styles[$idx]}"
}

# ── Rofi Selection ───────────────────────────────────────────────────────────
rofi_select() {
    if ! command -v rofi &>/dev/null; then
        echo "rofi is not installed"
        return 1
    fi

    local current
    current=$(get_current_style)

    # Build style list with descriptions
    local entries=""
    local descriptions=(
        "compact:Dense, space-efficient"
        "default:Pill Groups (default)"
        "flat:Bottom-line accents"
        "floating:Island bar with shadow"
        "hollow:Floating pods with borders"
        "minimal:Just text, no frills"
        "solid:Classic solid bar"
    )

    for f in "$STYLES_DIR"/*.css; do
        [[ ! -f "$f" ]] && continue
        local name
        name=$(basename "$f" .css)
        local desc="$name"
        for d in "${descriptions[@]}"; do
            if [[ "$d" == "$name:"* ]]; then
                desc="${d#*:}"
                break
            fi
        done
        local active=""
        [[ "$name" == "$current" ]] && active=" (active)"
        entries+="${name} — ${desc}${active}\n"
    done

    local selected
    selected=$(echo -e "$entries" | rofi -dmenu -p " Waybar Style" -i -theme-str '
        window { width: 480px; }
        listview { lines: 8; }
    ')

    if [[ -n "$selected" ]]; then
        local style_name
        style_name=$(echo "$selected" | awk '{print $1}')
        set_style "$style_name"
    fi
}

# ── Restart Waybar ───────────────────────────────────────────────────────────
restart_waybar() {
    pkill waybar 2>/dev/null || true
    sleep 0.3
    waybar &>/dev/null &
    disown
}

# ── Usage ────────────────────────────────────────────────────────────────────
usage() {
    cat <<'EOF'
s4d Waybar Style Switcher

USAGE:
  waybar-style.sh <command> [args]

COMMANDS:
  set <name>      Apply a style (default, hollow, solid, minimal, flat, compact, floating)
  next            Cycle to next style
  prev            Cycle to previous style
  list            List available styles
  rofi            Select style via rofi menu
  layout <name>   Switch layout (default, full, minimal, sysmon)
  layouts         List available layouts
  current         Show current style and layout
  help            Show this help

EXAMPLES:
  waybar-style.sh set hollow
  waybar-style.sh next
  waybar-style.sh rofi
  waybar-style.sh layout minimal
EOF
}

# ── Main Dispatch ────────────────────────────────────────────────────────────
case "${1:-help}" in
    set)     set_style "${2:?Usage: waybar-style.sh set <name>}" ;;
    next)    next_style ;;
    prev)    prev_style ;;
    list)    list_styles ;;
    rofi)    rofi_select ;;
    layout)  set_layout "${2:?Usage: waybar-style.sh layout <name>}" ;;
    layouts) list_layouts ;;
    current)
        echo "Style:  $(get_current_style)"
        echo "Layout: $(get_current_layout)"
        ;;
    help|--help|-h)
        usage ;;
    *)
        # If called with a style name directly
        if [[ -f "$STYLES_DIR/${1}.css" ]]; then
            set_style "$1"
        else
            usage
        fi
        ;;
esac
