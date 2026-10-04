# shellcheck shell=bash
# ------------------------------------------------------------------------------
# Preview + custom color editor helpers for wizard.sh.
# Bash 3.2 compatible. Sourced by wizard.sh; no top-level side effects.
# ------------------------------------------------------------------------------

RESET="${RESET:-\033[0m}"
DIM="${DIM:-\033[2m}"

# Item order must match the theme's custom loop (checked by tests/check-colors.sh).
MDP_ITEMS=(CONNECTOR PATH GIT_BRANCH SUCCESS WARNING ERROR EXEC_TIME TEXT)
# 256-color values (theme non-truecolor branch)
MDP_NIGHT=(240 75 114 114 215 167 176 254)
MDP_MONOKAI=(101 81 148 148 185 197 141 255)
# Truecolor values (theme truecolor branch), without '#'
MDP_NIGHT_HEX=(555555 64b5f6 81c784 81c784 ffb74d e57373 ba68c8 e0e0e0)
MDP_MONOKAI_HEX=(75715e 66d9ef a6e22e a6e22e e6db74 f92672 ae81ff f8f8f2)
# Current custom codes (editor state)
MDP_CUSTOM=("${MDP_NIGHT[@]}")

# Symbols (bash 3.2 has no $'\u'; emit UTF-8 bytes)
printf -v MDP_SYM_DIR_NERD     '\xef\x84\x95'      # U+F115
printf -v MDP_SYM_GIT_NERD     '\xee\x9c\xa5'      # U+E725
printf -v MDP_SYM_CHANGES_NERD '\xef\x85\x9b'      # U+F15B
printf -v MDP_SYM_TIME_NERD    '\xef\x90\xba'      # U+F43A
printf -v MDP_SYM_DIR_PLAIN     '\xf0\x9f\x93\x81' # U+1F4C1
printf -v MDP_SYM_GIT_PLAIN     '\xe2\x8c\xa5'     # U+2325
printf -v MDP_SYM_CHANGES_PLAIN '\xf0\x9f\x93\x84' # U+1F4C4
printf -v MDP_SYM_TIME_PLAIN    '\xf0\x9f\x95\x92' # U+1F552
printf -v MDP_EDGE_L '\xee\x82\xb6'                # U+E0B6
printf -v MDP_EDGE_R '\xee\x82\xb4'                # U+E0B4

# mdp_valid_code <str>: 0 iff 1-3 digits and value <= 255
mdp_valid_code() {
    [[ "$1" =~ ^[0-9]{1,3}$ ]] && [ "$((10#$1))" -le 255 ]
}

# mdp_cycle <current> <1|-1>: echo next code within 0-15 (codes >15 jump to an edge)
mdp_cycle() {
    local cur="$1" dir="$2"
    if [ "$cur" -gt 15 ]; then
        if [ "$dir" -gt 0 ]; then echo 0; else echo 15; fi
    else
        echo $(((cur + dir + 16) % 16))
    fi
}

# mdp_esc <fg|bg> <item-index>: set MDP_E to the SGR escape for the active variant
mdp_esc() {
    local base=38 variant="${VARIANT:-night}" h
    if [ "$1" = bg ]; then base=48; fi
    if [ "$variant" = custom ]; then
        MDP_E="\033[${base};5;${MDP_CUSTOM[$2]}m"
        return 0
    fi
    if [[ "${COLORTERM:-}" == truecolor || "${COLORTERM:-}" == 24bit ]]; then
        if [ "$variant" = monokai ]; then h="${MDP_MONOKAI_HEX[$2]}"; else h="${MDP_NIGHT_HEX[$2]}"; fi
        MDP_E="\033[${base};2;$((16#${h:0:2}));$((16#${h:2:2}));$((16#${h:4:2}))m"
    elif [ "$variant" = monokai ]; then
        MDP_E="\033[${base};5;${MDP_MONOKAI[$2]}m"
    else
        MDP_E="\033[${base};5;${MDP_NIGHT[$2]}m"
    fi
}

# mdp_text_on <code>: set MDP_TEXT_HEX to the capsule text color for a numeric 0-255 background
# (same rule as the theme's _modern_dark_pro_text_on: integer luma < 120 -> light text)
MDP_XTERM_R=(0 205 0 205 0 205 0 229 127 255 0 255 92 255 0 255)
MDP_XTERM_G=(0 0 205 205 0 0 205 229 127 0 255 255 92 0 255 255)
MDP_XTERM_B=(0 0 0 0 238 205 205 229 127 0 0 0 255 255 255 255)
mdp_text_on() {
    local n=$((10#$1)) r g b i
    if [ "$n" -lt 16 ]; then
        r=${MDP_XTERM_R[$n]}; g=${MDP_XTERM_G[$n]}; b=${MDP_XTERM_B[$n]}
    elif [ "$n" -lt 232 ]; then
        i=$((n - 16))
        r=$((i / 36)); g=$(((i / 6) % 6)); b=$((i % 6))
        if [ "$r" -gt 0 ]; then r=$((55 + 40 * r)); fi
        if [ "$g" -gt 0 ]; then g=$((55 + 40 * g)); fi
        if [ "$b" -gt 0 ]; then b=$((55 + 40 * b)); fi
    else
        r=$((8 + 10 * (n - 232))); g=$r; b=$r
    fi
    if [ $(((299 * r + 587 * g + 114 * b) / 1000)) -lt 120 ]; then MDP_TEXT_HEX="#f8f8f2"; else MDP_TEXT_HEX="#111111"; fi
}

# mdp_pill <item-index> <symbol> <text>: append one capsule to MDP_LINE
mdp_pill() {
    local idx="$1" content="$2 $3" fg bg border txt
    if [ -n "$MDP_LINE" ]; then MDP_LINE+=" "; fi
    mdp_esc fg "$idx"; fg="$MDP_E"
    mdp_esc bg "$idx"; bg="$MDP_E"
    case "${PILL_STYLE:-round}" in
        bracket)
            mdp_esc fg 0; border="$MDP_E"
            MDP_LINE+="${border}[ ${fg}${content} ${border}]${RESET}"
            ;;
        none)
            MDP_LINE+=" ${fg}${content}${RESET}"
            ;;
        *)
            if [ "${PILL_COLOR_STYLE:-solid}" = dark ]; then
                MDP_LINE+="\033[38;5;235m${MDP_EDGE_L}\033[48;5;235m${fg} ${content} ${RESET}\033[38;5;235m${MDP_EDGE_R}${RESET}"
            else
                # Dark custom backgrounds get light text (built-in palettes are all bright)
                txt="\033[38;5;233m"
                if [ "${VARIANT:-night}" = custom ]; then
                    mdp_text_on "${MDP_CUSTOM[$idx]}"
                    if [ "$MDP_TEXT_HEX" = "#f8f8f2" ]; then txt="\033[38;5;255m"; fi
                fi
                MDP_LINE+="${fg}${MDP_EDGE_L}${bg}${txt} ${content} ${RESET}${fg}${MDP_EDGE_R}${RESET}"
            fi
            ;;
    esac
}

# render_preview: print a mock prompt using the wizard's current choices
render_preview() {
    local layout="${PROMPT_LAYOUT:-two-line}" nerd="${NERD_FONTS:-true}"
    local show_clock="${SHOW_CLOCK:-true}" clock_pos="${CLOCK_POS:-rprompt}"
    local s_dir s_git s_chg s_time ok con clock="" line1 line2
    if [ "$nerd" = true ]; then
        s_dir="$MDP_SYM_DIR_NERD"; s_git="$MDP_SYM_GIT_NERD"
        s_chg="$MDP_SYM_CHANGES_NERD"; s_time="$MDP_SYM_TIME_NERD"
    else
        s_dir="$MDP_SYM_DIR_PLAIN"; s_git="$MDP_SYM_GIT_PLAIN"
        s_chg="$MDP_SYM_CHANGES_PLAIN"; s_time="$MDP_SYM_TIME_PLAIN"
    fi
    mdp_esc fg 3; ok="$MDP_E"
    mdp_esc fg 0; con="$MDP_E"
    MDP_LINE=""
    mdp_pill 1 "$s_dir" "~/dev/theme"
    mdp_pill 2 "$s_git" "main"
    mdp_pill 7 "$s_chg" "3 +12 -4 ?1"
    mdp_pill 6 "$s_time" "2.5s"
    if [ "$show_clock" = true ]; then clock="  ${con}${s_time} 12:34:56${RESET}"; fi
    case "$layout" in
        single)
            line1="${MDP_LINE} ${ok}❯${RESET}"
            printf '%b\n' "${line1}${clock}"
            ;;
        classic)
            line1="${con}┌─${RESET} ${MDP_LINE}"
            line2="${con}└─${RESET} ${ok}❯${RESET}"
            if [ "$clock_pos" = top ]; then line1="${line1}${clock}"; else line2="${line2}${clock}"; fi
            printf '%b\n%b\n' "$line1" "$line2"
            ;;
        *)
            line1="${MDP_LINE}"
            line2="${ok}❯${RESET}"
            if [ "$clock_pos" = top ]; then line1="${line1}${clock}"; else line2="${line2}${clock}"; fi
            printf '%b\n%b\n' "$line1" "$line2"
            ;;
    esac
}

# mdp_read_key: read one key press into MDP_KEY.
# Tokens: UP DOWN LEFT RIGHT ENTER ESC EOF NONE (unknown/inert sequence), or the literal character.
# Whole escape sequences are consumed so no byte of an arrow/modified key leaks as a command.
mdp_read_key() {
    local c seq=""
    MDP_KEY=""
    if ! IFS= read -rsn1 c; then MDP_KEY=EOF; return 0; fi
    if [ -z "$c" ]; then MDP_KEY=ENTER; return 0; fi
    if [ "$c" != $'\e' ]; then MDP_KEY="$c"; return 0; fi
    if ! IFS= read -rsn1 -t 1 c; then MDP_KEY=ESC; return 0; fi
    if [ "$c" != "[" ] && [ "$c" != "O" ]; then MDP_KEY=NONE; return 0; fi
    # CSI (ESC [ params letter|~) and SS3 (ESC O letter): read up to the final byte
    while IFS= read -rsn1 -t 1 c; do
        seq="${seq}${c}"
        case "$c" in [A-Za-z~]) break ;; esac
    done
    case "${seq: -1}" in
        A) MDP_KEY=UP ;;
        B) MDP_KEY=DOWN ;;
        C) MDP_KEY=RIGHT ;;
        D) MDP_KEY=LEFT ;;
        *) MDP_KEY=NONE ;;
    esac
}

# mdp_exports: print the custom export lines when VARIANT=custom
mdp_exports() {
    local i
    if [ "${VARIANT:-}" != custom ]; then return 0; fi
    for ((i = 0; i < ${#MDP_ITEMS[@]}; i++)); do
        echo "export MODERN_DARK_PRO_COLOR_${MDP_ITEMS[$i]}=\"${MDP_CUSTOM[$i]}\""
    done
}

# mdp_editor_draw <selected-index>: banner, preview, item list, key help
mdp_editor_draw() {
    local sel="$1" i marker sw
    printf '\033[H\033[2J'
    printf '%b\n' "${BOLD}${CYAN}----------------------------------------------------------------------"
    printf '  %s\n' "${T_EDIT_TITLE}"
    printf '%b\n\n' "----------------------------------------------------------------------${RESET}"
    printf '%b\n' "${DIM}${T_PREVIEW:-Preview}${RESET}"
    render_preview
    echo ""
    for ((i = 0; i < ${#MDP_ITEMS[@]}; i++)); do
        mdp_esc fg "$i"; sw="$MDP_E"
        marker="  "
        if [ "$i" -eq "$sel" ]; then marker="> "; fi
        printf '%s%-11s %b■■■%b %3s\n' "$marker" "${MDP_ITEMS[$i]}" "$sw" "$RESET" "${MDP_CUSTOM[$i]}"
    done
    echo ""
    printf '%b\n' "${DIM}${T_EDIT_HELP}${RESET}"
}

# mdp_editor: interactive color editor; no-op when stdin is not a TTY
mdp_editor() {
    if [ ! -t 0 ]; then return 0; fi
    local sel=0 n=${#MDP_ITEMS[@]} code
    while true; do
        mdp_editor_draw "$sel"
        mdp_read_key
        case "$MDP_KEY" in
            ENTER | ESC | EOF) return 0 ;;
            UP) sel=$(((sel + n - 1) % n)) ;;
            DOWN) sel=$(((sel + 1) % n)) ;;
            RIGHT) MDP_CUSTOM[$sel]=$(mdp_cycle "${MDP_CUSTOM[$sel]}" 1) ;;
            LEFT) MDP_CUSTOM[$sel]=$(mdp_cycle "${MDP_CUSTOM[$sel]}" -1) ;;
            a)
                read -e -r -p "${T_EDIT_CODE_PROMPT} " code || code=""
                if mdp_valid_code "$code"; then MDP_CUSTOM[$sel]=$((10#$code)); fi
                ;;
            r) MDP_CUSTOM[$sel]="${MDP_NIGHT[$sel]}" ;;
            c) MDP_CUSTOM=("${MDP_NIGHT[@]}") ;;
        esac
    done
}
