#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  s4d Waybar Style Switcher                                   ║
# ║  Cycle styles, layouts, and bar position (top/bottom/left/   ║
# ║  right). Designed to coexist with DankMaterialShell — when   ║
# ║  DMS is active, waybar binds simply aren't loaded.           ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
STYLES_DIR="$WAYBAR_DIR/styles"
LAYOUTS_DIR="$WAYBAR_DIR/layouts"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/s4d-hyprland"
CURRENT_STYLE_FILE="$CACHE_DIR/current_waybar_style"
CURRENT_LAYOUT_FILE="$CACHE_DIR/current_waybar_layout"
CURRENT_POSITION_FILE="$CACHE_DIR/current_waybar_position"

mkdir -p "$CACHE_DIR"

# ── Helpers ──────────────────────────────────────────────────────────────────
notify() { command -v notify-send &>/dev/null && notify-send -t 1500 -a "Waybar" "$@"; }

get_current_style()    { cat "$CURRENT_STYLE_FILE"    2>/dev/null || echo "default"; }
get_current_layout()   { cat "$CURRENT_LAYOUT_FILE"   2>/dev/null || echo "full"; }
get_current_position() { cat "$CURRENT_POSITION_FILE" 2>/dev/null || echo "top"; }

restart_waybar() {
    pkill waybar 2>/dev/null || true
    sleep 0.3
    waybar &>/dev/null &
    disown
}

# ── Enumeration ──────────────────────────────────────────────────────────────
get_all_styles() {
    for f in "$STYLES_DIR"/*.css; do
        [[ -f "$f" ]] && basename "$f" .css
    done
}

get_all_layouts() {
    for f in "$LAYOUTS_DIR"/*.jsonc; do
        [[ -f "$f" ]] && basename "$f" .jsonc
    done
}

POSITIONS=(top bottom left right)

# ── Style Functions ──────────────────────────────────────────────────────────
list_styles() {
    local current; current=$(get_current_style)
    echo "Available styles:"
    while IFS= read -r name; do
        local m=""; [[ "$name" == "$current" ]] && m=" ← active"
        echo "  • $name$m"
    done < <(get_all_styles)
}

set_style() {
    local name="$1"
    local target="$STYLES_DIR/${name}.css"
    if [[ ! -f "$target" ]]; then
        echo "Error: style '$name' not found"; list_styles; return 1
    fi
    cp -f "$target" "$WAYBAR_DIR/style.css"
    # Re-apply vertical override if bar is currently in left/right position
    _sync_vertical_css
    echo "$name" > "$CURRENT_STYLE_FILE"
    restart_waybar
    notify "  Style" "→ $name"
    echo "Style set to: $name"
}

next_style() { _cycle_style 1; }
prev_style() { _cycle_style -1; }

_cycle_style() {
    local dir=$1 current; current=$(get_current_style)
    local -a styles; mapfile -t styles < <(get_all_styles)
    [[ ${#styles[@]} -eq 0 ]] && return 1
    local idx=0
    for i in "${!styles[@]}"; do
        [[ "${styles[$i]}" == "$current" ]] && { idx=$(( (i + dir + ${#styles[@]}) % ${#styles[@]} )); break; }
    done
    set_style "${styles[$idx]}"
}

# ── Layout Functions ─────────────────────────────────────────────────────────
list_layouts() {
    local current; current=$(get_current_layout)
    echo "Available layouts:"
    while IFS= read -r name; do
        local m=""; [[ "$name" == "$current" ]] && m=" ← active"
        echo "  • $name$m"
    done < <(get_all_layouts)
}

set_layout() {
    local name="$1"
    local target="$LAYOUTS_DIR/${name}.jsonc"
    if [[ ! -f "$target" ]]; then
        echo "Error: layout '$name' not found"; list_layouts; return 1
    fi
    cp -f "$target" "$WAYBAR_DIR/config.jsonc"
    echo "$name" > "$CURRENT_LAYOUT_FILE"

    # Re-apply saved position preference onto the new layout
    apply_position "$(get_current_position)"

    restart_waybar
    local pos; pos=$(get_current_position)
    notify "  Layout" "→ $name  ($pos)"
    echo "Layout set to: $name ($pos)"
}

next_layout() { _cycle_layout 1; }
prev_layout() { _cycle_layout -1; }

_cycle_layout() {
    local dir=$1 current; current=$(get_current_layout)
    local -a layouts; mapfile -t layouts < <(get_all_layouts)
    [[ ${#layouts[@]} -eq 0 ]] && return 1
    local idx=0
    for i in "${!layouts[@]}"; do
        [[ "${layouts[$i]}" == "$current" ]] && { idx=$(( (i + dir + ${#layouts[@]}) % ${#layouts[@]} )); break; }
    done
    set_layout "${layouts[$idx]}"
}

# ── Position Functions ───────────────────────────────────────────────────────
# Sync vertical CSS override: concatenate rules directly (CSS @import MUST be
# before all other rules — appending an @import at the end is silently ignored).
_sync_vertical_css() {
    local style_css="$WAYBAR_DIR/style.css"
    local vertical_css="$WAYBAR_DIR/vertical.css"
    local pos; pos=$(get_current_position)

    # Strip any previous vertical block + stale @import line
    sed -i '/@import "vertical.css";/d' "$style_css"
    sed -i '/\/\* __VERTICAL_START__ \*\//,/\/\* __VERTICAL_END__ \*\//d' "$style_css"

    # Append vertical rules directly if in vertical mode
    if [[ "$pos" == "left" || "$pos" == "right" ]] && [[ -f "$vertical_css" ]]; then
        {
            echo '/* __VERTICAL_START__ */'
            # Skip @import lines from vertical.css (mocha.css is already imported)
            grep -v '^@import' "$vertical_css"
            echo '/* __VERTICAL_END__ */'
        } >> "$style_css"
    fi
}

apply_position() {
    local pos="$1"
    local config="$WAYBAR_DIR/config.jsonc"

    # Validate position
    case "$pos" in
        top|bottom|left|right) ;;
        *) echo "Invalid position: $pos"; return 1 ;;
    esac

    # Replace the "position" field in the active config
    if grep -q '"position"' "$config"; then
        sed -i 's/"position":[[:space:]]*"[^"]*"/"position": "'"$pos"'"/' "$config"
    else
        # Insert position after the opening brace
        sed -i '0,/{/a\  "position": "'"$pos"'",' "$config"
    fi

    case "$pos" in
        top|bottom)
            # ── Horizontal bar: use height, remove width ──
            # Swap "width" back to "height" if previously set for vertical
            if grep -q '"width"' "$config"; then
                sed -i 's/"width":[[:space:]]*[0-9]*/"height": 30/' "$config"
            fi
            # Restore group orientations to horizontal
            sed -i 's/"orientation":[[:space:]]*"vertical"/"orientation": "horizontal"/g' "$config"
            # Restore standard spacing
            _set_json_num "$config" "spacing" 15

            # Margins
            _set_json_num "$config" "margin-left"   10
            _set_json_num "$config" "margin-right"  10
            if [[ "$pos" == "top" ]]; then
                _set_json_num "$config" "margin-top"    5
                _set_json_num "$config" "margin-bottom"  0
            else
                _set_json_num "$config" "margin-top"    0
                _set_json_num "$config" "margin-bottom"  5
            fi
            ;;
        left|right)
            # ── Vertical bar: use width, remove height ──
            # Swap "height" to "width" for vertical sidebar
            if grep -q '"height"' "$config"; then
                sed -i 's/"height":[[:space:]]*[0-9]*/"width": 52/' "$config"
            fi
            # Flip all group orientations to vertical
            sed -i 's/"orientation":[[:space:]]*"horizontal"/"orientation": "vertical"/g' "$config"
            # Compact spacing for vertical stacking
            _set_json_num "$config" "spacing" 4

            # Margins
            _set_json_num "$config" "margin-top"    10
            _set_json_num "$config" "margin-bottom" 10
            if [[ "$pos" == "left" ]]; then
                _set_json_num "$config" "margin-left"   5
                _set_json_num "$config" "margin-right"   0
            else
                _set_json_num "$config" "margin-left"   0
                _set_json_num "$config" "margin-right"   5
            fi
            ;;
    esac

    echo "$pos" > "$CURRENT_POSITION_FILE"

    # Toggle vertical CSS override
    _sync_vertical_css
}

_set_json_num() {
    local file="$1" key="$2" val="$3"
    if grep -q "\"$key\"" "$file"; then
        sed -i 's/"'"$key"'":[[:space:]]*[0-9]*/"'"$key"'": '"$val"'/' "$file"
    fi
}

set_position() {
    local pos="$1"
    apply_position "$pos"
    restart_waybar
    notify "  Position" "→ $pos"
    echo "Position set to: $pos"
}

next_position() {
    local current; current=$(get_current_position)
    local count=${#POSITIONS[@]}
    local idx=0
    for i in "${!POSITIONS[@]}"; do
        [[ "${POSITIONS[$i]}" == "$current" ]] && { idx=$(( (i + 1) % count )); break; }
    done
    set_position "${POSITIONS[$idx]}"
}

prev_position() {
    local current; current=$(get_current_position)
    local count=${#POSITIONS[@]}
    local idx=$((count - 1))
    for i in "${!POSITIONS[@]}"; do
        [[ "${POSITIONS[$i]}" == "$current" ]] && { idx=$(( (i - 1 + count) % count )); break; }
    done
    set_position "${POSITIONS[$idx]}"
}

# ── Rofi Menus ───────────────────────────────────────────────────────────────
rofi_select() {
    if ! command -v rofi &>/dev/null; then echo "rofi is not installed"; return 1; fi

    local action
    action=$(printf "  Styles\n  Layouts\n  Position\n  Show Current" | \
        rofi -dmenu -p "  Waybar" -i -theme-str 'window { width: 360px; } listview { lines: 4; }')

    case "$action" in
        *Styles)   _rofi_styles ;;
        *Layouts)  _rofi_layouts ;;
        *Position) _rofi_position ;;
        *Current)  _rofi_current ;;
    esac
}

_rofi_styles() {
    local current; current=$(get_current_style)
    local entries=""
    while IFS= read -r name; do
        local marker=""; [[ "$name" == "$current" ]] && marker=" (active)"
        entries+="${name}${marker}\n"
    done < <(get_all_styles)

    local selected
    selected=$(echo -e "$entries" | rofi -dmenu -p "  Style" -i -theme-str 'window { width: 420px; } listview { lines: 10; }')
    if [[ -n "$selected" ]]; then
        local name; name=$(echo "$selected" | awk '{print $1}')
        set_style "$name"
    fi
}

_rofi_layouts() {
    local current; current=$(get_current_layout)
    local entries=""
    while IFS= read -r name; do
        local marker=""; [[ "$name" == "$current" ]] && marker=" (active)"
        entries+="${name}${marker}\n"
    done < <(get_all_layouts)

    local selected
    selected=$(echo -e "$entries" | rofi -dmenu -p "  Layout" -i -theme-str 'window { width: 420px; } listview { lines: 16; }')
    if [[ -n "$selected" ]]; then
        local name; name=$(echo "$selected" | awk '{print $1}')
        set_layout "$name"
    fi
}

_rofi_position() {
    local current; current=$(get_current_position)
    local entries=""
    for pos in "${POSITIONS[@]}"; do
        local marker=""; [[ "$pos" == "$current" ]] && marker=" (active)"
        entries+="${pos}${marker}\n"
    done

    local selected
    selected=$(echo -e "$entries" | rofi -dmenu -p "  Position" -i -theme-str 'window { width: 340px; } listview { lines: 4; }')
    if [[ -n "$selected" ]]; then
        local pos; pos=$(echo "$selected" | awk '{print $1}')
        set_position "$pos"
    fi
}

_rofi_current() {
    local msg
    msg="Style:    $(get_current_style)\nLayout:   $(get_current_layout)\nPosition: $(get_current_position)"
    rofi -e "$msg" -theme-str 'window { width: 360px; }'
}

# ── Usage ────────────────────────────────────────────────────────────────────
usage() {
    cat <<'EOF'
s4d Waybar Style Switcher

USAGE:
  waybar-style.sh <command> [args]

STYLE:
  next / prev         Cycle CSS styles
  set <name>          Apply a named style
  list                List available styles

LAYOUT:
  layout next         Cycle to next layout
  layout prev         Cycle to previous layout
  layout set <name>   Apply a named layout
  layout list         List available layouts

POSITION (applies to any layout):
  position top        Move bar to top
  position bottom     Move bar to bottom
  position left       Move bar to left edge (vertical)
  position right      Move bar to right edge (vertical)
  position next       Cycle through positions

MENU:
  rofi                Full interactive menu (styles / layouts / position)

INFO:
  current             Show current style, layout, and position

KEYBINDINGS (waybar mode only — no conflict with DMS):
  SUPER + ALT + ←/→   Cycle layouts
  SUPER + ALT + ↑/↓   Cycle wallpapers
  SUPER + W            Cycle styles
  SUPER + SHIFT + W    Rofi style/layout/position menu
EOF
}

# ── Main Dispatch ────────────────────────────────────────────────────────────
case "${1:-help}" in
    # ── Styles (backward compatible) ──
    next)    next_style ;;
    prev)    prev_style ;;
    set)     set_style "${2:?Usage: set <name>}" ;;
    list)    list_styles ;;

    # ── Layouts ──
    layout)
        case "${2:-list}" in
            next)  next_layout ;;
            prev)  prev_layout ;;
            set)   set_layout "${3:?Usage: layout set <name>}" ;;
            list)  list_layouts ;;
            *)     set_layout "$2" ;;   # shortcut: layout <name>
        esac
        ;;
    layout-next) next_layout ;;   # shortcut for keybind
    layout-prev) prev_layout ;;   # shortcut for keybind
    layouts)     list_layouts ;;  # backward compat

    # ── Position ──
    position)
        case "${2:-current}" in
            next)                   next_position ;;
            prev)                   prev_position ;;
            top|bottom|left|right)  set_position "$2" ;;
            current)                echo "Position: $(get_current_position)" ;;
            *)                      echo "Usage: position {top|bottom|left|right|next|prev}" ;;
        esac
        ;;
    position-next) next_position ;;  # shortcut for keybind

    # ── Menu ──
    rofi) rofi_select ;;

    # ── Info ──
    current)
        echo "Style:    $(get_current_style)"
        echo "Layout:   $(get_current_layout)"
        echo "Position: $(get_current_position)"
        ;;

    help|--help|-h) usage ;;

    # ── Fallback: treat arg as style name ──
    *)
        if [[ -f "$STYLES_DIR/${1}.css" ]]; then
            set_style "$1"
        else
            usage
        fi
        ;;
esac
