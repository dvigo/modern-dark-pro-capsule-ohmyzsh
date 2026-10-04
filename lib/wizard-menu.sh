# shellcheck shell=bash
if [ -z "${MDP_ITEMS+x}" ]; then
    # shellcheck source=wizard-colors.sh
    . "$(dirname "${BASH_SOURCE[0]}")/wizard-colors.sh"
fi
# ------------------------------------------------------------------------------
# Single-screen settings menu for wizard.sh: state, ~/.zshrc loading, row logic.
# Requires lib/wizard-colors.sh. Bash 3.2 compatible; no top-level side effects.
# ------------------------------------------------------------------------------

MDP_ROWS=10
MDP_CUSTOM_TOUCHED=false
MDP_SNAP=""

# mdp_defaults: wizard defaults (same as the old step defaults)
mdp_defaults() {
    VARIANT=night
    PILL_STYLE=round
    PILL_COLOR_STYLE=solid
    PROMPT_LAYOUT=two-line
    NERD_FONTS=true
    SHOW_CLOCK=true
    CLOCK_POS=rprompt
    CLICKABLE=true
    MDP_CUSTOM=("${MDP_NIGHT[@]}")
    MDP_CUSTOM_TOUCHED=false
}

# mdp_read_export <file> <NAME>: print the last value of `export MODERN_DARK_PRO_<NAME>=...`
# with one pair of quotes stripped. Never evaluates the file. Prints nothing if absent.
mdp_read_export() {
    local line v
    if [ ! -f "$1" ]; then return 0; fi
    line=$(grep -E "^export MODERN_DARK_PRO_$2=" "$1" | tail -1) || true
    if [ -z "$line" ]; then return 0; fi
    v="${line#*=}"
    v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"
    printf '%s' "$v"
}

# mdp_load_settings <file>: defaults, then whitelisted valid values from the file
mdp_load_settings() {
    local f="$1" v i
    mdp_defaults
    v=$(mdp_read_export "$f" VARIANT);          case "$v" in night | monokai | custom) VARIANT="$v" ;; esac
    v=$(mdp_read_export "$f" PILL_STYLE);       case "$v" in round | bracket | none) PILL_STYLE="$v" ;; esac
    v=$(mdp_read_export "$f" PILL_COLOR_STYLE); case "$v" in solid | dark) PILL_COLOR_STYLE="$v" ;; esac
    v=$(mdp_read_export "$f" PROMPT_LAYOUT);    case "$v" in single | two-line | classic) PROMPT_LAYOUT="$v" ;; esac
    v=$(mdp_read_export "$f" NERD_FONTS);       case "$v" in true | false) NERD_FONTS="$v" ;; esac
    v=$(mdp_read_export "$f" SHOW_CLOCK);       case "$v" in true | false) SHOW_CLOCK="$v" ;; esac
    v=$(mdp_read_export "$f" CLOCK_POSITION);   case "$v" in top | rprompt) CLOCK_POS="$v" ;; esac
    v=$(mdp_read_export "$f" CLICKABLE_PATH);   case "$v" in true | false) CLICKABLE="$v" ;; esac
    for ((i = 0; i < ${#MDP_ITEMS[@]}; i++)); do
        v=$(mdp_read_export "$f" "COLOR_${MDP_ITEMS[$i]}")
        if mdp_valid_code "$v"; then
            MDP_CUSTOM[$i]=$((10#$v))
            MDP_CUSTOM_TOUCHED=true
        fi
    done
    if [ "$VARIANT" = custom ]; then MDP_CUSTOM_TOUCHED=true; fi
    mdp_clock_fix
}

# mdp_next_in <current> <dir> <values...>: print the next value, wrapping; unknown current = first
mdp_next_in() {
    local cur="$1" dir="$2" i n idx=0
    shift 2
    local vals=("$@")
    n=${#vals[@]}
    for ((i = 0; i < n; i++)); do
        if [ "${vals[$i]}" = "$cur" ]; then idx=$i; fi
    done
    echo "${vals[$(((idx + dir + n) % n))]}"
}

# mdp_clock_get / mdp_clock_set: Clock row <-> SHOW_CLOCK + CLOCK_POS
mdp_clock_get() {
    if [ "$SHOW_CLOCK" != true ]; then echo off; else echo "$CLOCK_POS"; fi
}
mdp_clock_set() {
    case "$1" in
        rprompt) SHOW_CLOCK=true; CLOCK_POS=rprompt ;;
        top) SHOW_CLOCK=true; CLOCK_POS=top ;;
        *) SHOW_CLOCK=false; CLOCK_POS=top ;;
    esac
}

# mdp_clock_fix: the single layout has no separate top-line clock (it renders like the right
# prompt), so a visible top-line clock becomes the right prompt there
mdp_clock_fix() {
    if [ "$PROMPT_LAYOUT" = single ] && [ "$SHOW_CLOCK" = true ] && [ "$CLOCK_POS" = top ]; then
        CLOCK_POS=rprompt
    fi
}

# mdp_row_visible <row>: exit 0 unless it is the Capsule fill row of a non-round style
mdp_row_visible() {
    [ "$1" -ne 3 ] || [ "$PILL_STYLE" = round ]
}

# mdp_move <row> <dir>: print the next visible row, wrapping
mdp_move() {
    local r="$1" dir="$2" i
    for ((i = 0; i < MDP_ROWS; i++)); do
        r=$(((r + dir + MDP_ROWS) % MDP_ROWS))
        if mdp_row_visible "$r"; then break; fi
    done
    echo "$r"
}

# mdp_enter_custom: switch to custom; seed the palette from the current variant unless the
# user already loaded or edited one
mdp_enter_custom() {
    if [ "$MDP_CUSTOM_TOUCHED" != true ]; then
        if [ "$VARIANT" = monokai ]; then MDP_CUSTOM=("${MDP_MONOKAI[@]}"); else MDP_CUSTOM=("${MDP_NIGHT[@]}"); fi
    fi
    VARIANT=custom
}

# mdp_change <row> <dir>: step a value row (0,2,3,4,5,6,7); other rows are ignored
mdp_change() {
    local next
    case "$1" in
        0)
            next=$(mdp_next_in "$VARIANT" "$2" night monokai custom)
            if [ "$next" = custom ]; then mdp_enter_custom; else VARIANT="$next"; fi
            ;;
        2) PILL_STYLE=$(mdp_next_in "$PILL_STYLE" "$2" round bracket none) ;;
        3) PILL_COLOR_STYLE=$(mdp_next_in "$PILL_COLOR_STYLE" "$2" solid dark) ;;
        4) PROMPT_LAYOUT=$(mdp_next_in "$PROMPT_LAYOUT" "$2" two-line single classic); mdp_clock_fix ;;
        5) NERD_FONTS=$(mdp_next_in "$NERD_FONTS" "$2" true false) ;;
        6)
            if [ "$PROMPT_LAYOUT" = single ]; then
                mdp_clock_set "$(mdp_next_in "$(mdp_clock_get)" "$2" rprompt off)"
            else
                mdp_clock_set "$(mdp_next_in "$(mdp_clock_get)" "$2" rprompt top off)"
            fi
            ;;
        7) CLICKABLE=$(mdp_next_in "$CLICKABLE" "$2" true false) ;;
    esac
}

# mdp_state: one-line fingerprint of every setting (to detect unsaved changes)
mdp_state() {
    printf '%s|%s|%s|%s|%s|%s|%s|%s|%s' "$VARIANT" "$PILL_STYLE" "$PILL_COLOR_STYLE" \
        "$PROMPT_LAYOUT" "$NERD_FONTS" "$SHOW_CLOCK" "$CLOCK_POS" "$CLICKABLE" "${MDP_CUSTOM[*]}"
}

# --- terminal handling -------------------------------------------------------
MDP_IN_ALT=false

MDP_STTY=""

mdp_term_enter() {
    # bash 3.2 does not undo the tty changes of `read -s` when a trap exits mid-read
    MDP_STTY=$(stty -g 2>/dev/null) || MDP_STTY=""
    printf '\033[?1049h\033[?25l'
    MDP_IN_ALT=true
}

mdp_term_leave() {
    if [ "$MDP_IN_ALT" = true ]; then
        printf '\033[?25h\033[?1049l'
        MDP_IN_ALT=false
        if [ -n "$MDP_STTY" ]; then stty "$MDP_STTY" 2>/dev/null || true; fi
    fi
}

# --- drawing -----------------------------------------------------------------
mdp_row_label() {
    case "$1" in
        0) echo "$T_M_SCHEME" ;;
        1) echo "$T_M_EDIT" ;;
        2) echo "$T_M_STYLE" ;;
        3) echo "$T_M_FILL" ;;
        4) echo "$T_M_LAYOUT" ;;
        5) echo "$T_M_NERD" ;;
        6) echo "$T_M_CLOCK" ;;
        7) echo "$T_M_LINKS" ;;
        8) echo "$T_M_SAVE" ;;
        9) echo "$T_M_QUIT" ;;
    esac
}

mdp_onoff() {
    if [ "$1" = true ]; then echo "$T_V_ON"; else echo "$T_V_OFF"; fi
}

# mdp_row_value <row>: the text shown between < > for value rows
mdp_row_value() {
    case "$1" in
        0) echo "$VARIANT" ;;
        2) echo "$PILL_STYLE" ;;
        3) echo "$PILL_COLOR_STYLE" ;;
        4) echo "$PROMPT_LAYOUT" ;;
        5) mdp_onoff "$NERD_FONTS" ;;
        6)
            case "$(mdp_clock_get)" in
                rprompt) echo "$T_V_RPROMPT" ;;
                top) echo "$T_V_TOP" ;;
                *) echo "$T_V_OFF" ;;
            esac
            ;;
        7) mdp_onoff "$CLICKABLE" ;;
    esac
}

mdp_menu_draw() {
    local cur="$1" r marker val
    printf '\033[H\033[2J'
    printf '%b\n\n' "${BOLD}${CYAN}${T_TITLE}${RESET}  ${DIM}(${LANG_CODE})${RESET}"
    render_preview
    echo ""
    for ((r = 0; r < MDP_ROWS; r++)); do
        if ! mdp_row_visible "$r"; then continue; fi
        marker="  "
        if [ "$r" -eq "$cur" ]; then marker="> "; fi
        case "$r" in
            1) val="${DIM}${T_M_EDIT_HINT}${RESET}" ;;
            8 | 9) val="" ;;
            *) val="< $(mdp_row_value "$r") >" ;;
        esac
        if [ "$r" -eq "$cur" ]; then
            printf '%b%s%-18s %b%b\n' "$BOLD" "$marker" "$(mdp_row_label "$r")" "$val" "$RESET"
        else
            printf '%s%-18s %b\n' "$marker" "$(mdp_row_label "$r")" "$val"
        fi
    done
    echo ""
    printf '%b\n' "${DIM}${T_M_HELP}${RESET}"
}

# --- loop --------------------------------------------------------------------
mdp_edit_colors() {
    if [ "$VARIANT" != custom ]; then mdp_enter_custom; fi
    mdp_editor
    MDP_CUSTOM_TOUCHED=true
}

# mdp_confirm_quit: exit 0 when the menu may close (no changes, or the user answered y)
mdp_confirm_quit() {
    if [ "$(mdp_state)" = "$MDP_SNAP" ]; then return 0; fi
    printf '\n%b ' "${T_M_DISCARD}"
    mdp_read_key
    case "$MDP_KEY" in
        y | Y) return 0 ;;
        *) return 1 ;;
    esac
}

# mdp_menu: run the menu. Return 0 = save, 1 = quit without saving.
mdp_menu() {
    local cur=0
    MDP_SNAP="$(mdp_state)"
    while true; do
        mdp_menu_draw "$cur"
        mdp_read_key
        case "$MDP_KEY" in
            UP) cur=$(mdp_move "$cur" -1) ;;
            DOWN) cur=$(mdp_move "$cur" 1) ;;
            LEFT) mdp_change "$cur" -1 ;;
            RIGHT) mdp_change "$cur" 1 ;;
            ENTER)
                case "$cur" in
                    1) mdp_edit_colors ;;
                    8) return 0 ;;
                    9) if mdp_confirm_quit; then return 1; fi ;;
                    *) mdp_change "$cur" 1 ;;
                esac
                ;;
            s) return 0 ;;
            q | ESC) if mdp_confirm_quit; then return 1; fi ;;
            EOF) return 1 ;;
        esac
    done
}
