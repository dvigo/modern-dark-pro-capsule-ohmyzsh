#!/usr/bin/env bash
# Run: bash tests/check-colors.sh   (also run with /bin/bash 3.2 on macOS)
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME="$ROOT/modern-dark-pro-capsule.zsh-theme"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0
ITEMS="CONNECTOR PATH GIT_BRANCH SUCCESS WARNING ERROR EXEC_TIME TEXT"

check() { # name expected actual
    if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected [$2] got [$3]"; FAILS=$((FAILS + 1)); fi
}

# theme_item <ITEM>  (env comes from the caller) -> value of COLOR_<ITEM> after sourcing the theme
theme_item() {
    (cd "$TMP" && zsh -f -c 'source "$1"; eval print -r -- \$COLOR_$2' _ "$THEME" "$1" | tail -1)
}

# ---- tests below ----
for item in $ITEMS; do
    got=$(export "MODERN_DARK_PRO_COLOR_$item=200"; COLORTERM=truecolor MODERN_DARK_PRO_VARIANT=custom theme_item "$item")
    check "custom override $item" 200 "$got"
done

for bad in abc 999 -1 '1;31' '%{x%}' '' ' 5' '$(touch PWNED)'; do
    got=$(COLORTERM=truecolor MODERN_DARK_PRO_VARIANT=custom MODERN_DARK_PRO_COLOR_PATH="$bad" theme_item PATH)
    check "bad value [$bad] falls back to night" "#64b5f6" "$got"
done
check "no command execution" "no" "$([ -e "$TMP/PWNED" ] && echo yes || echo no)"

got=$(COLORTERM= MODERN_DARK_PRO_VARIANT=custom MODERN_DARK_PRO_COLOR_PATH=1 theme_item PATH)
check "custom works in 256-color branch" 1 "$got"
# shellcheck source=../lib/wizard-colors.sh
. "$ROOT/lib/wizard-colors.sh"

check "item list matches theme" "$ITEMS" "${MDP_ITEMS[*]}"

# Base tables must equal what the theme really uses.
for variant in night monokai; do
    if [ "$variant" = night ]; then codes=("${MDP_NIGHT[@]}"); hexes=("${MDP_NIGHT_HEX[@]}")
    else codes=("${MDP_MONOKAI[@]}"); hexes=("${MDP_MONOKAI_HEX[@]}"); fi
    i=0
    for item in $ITEMS; do
        got=$(COLORTERM= MODERN_DARK_PRO_VARIANT=$variant theme_item "$item")
        check "$variant 256 $item" "${codes[$i]}" "$got"
        got=$(COLORTERM=truecolor MODERN_DARK_PRO_VARIANT=$variant theme_item "$item")
        check "$variant hex $item" "#${hexes[$i]}" "$got"
        i=$((i + 1))
    done
done

# Symbols must equal the theme's.
sym() { # NERD NAME -> value from theme
    (cd "$TMP" && MODERN_DARK_PRO_NERD_FONTS="$1" zsh -f -c 'source "$1"; eval print -rn -- \$MODERN_DARK_PRO_$2_SYMBOL' _ "$THEME" "$2")
}
check "sym dir nerd"      "$(sym true DIR)"      "$MDP_SYM_DIR_NERD"
check "sym git nerd"      "$(sym true GIT)"      "$MDP_SYM_GIT_NERD"
check "sym changes nerd"  "$(sym true CHANGES)"  "$MDP_SYM_CHANGES_NERD"
check "sym time nerd"     "$(sym true TIME)"     "$MDP_SYM_TIME_NERD"
check "sym dir plain"     "$(sym false DIR)"     "$MDP_SYM_DIR_PLAIN"
check "sym git plain"     "$(sym false GIT)"     "$MDP_SYM_GIT_PLAIN"
check "sym changes plain" "$(sym false CHANGES)" "$MDP_SYM_CHANGES_PLAIN"
check "sym time plain"    "$(sym false TIME)"    "$MDP_SYM_TIME_PLAIN"

# mdp_valid_code
for good in 0 7 255 007; do
    if mdp_valid_code "$good"; then r=ok; else r=bad; fi
    check "valid code [$good]" ok "$r"
done
for bad in abc 256 999 '' -1 ' 5' '1 2' 0255 00000255 '1;31'; do
    if mdp_valid_code "$bad"; then r=ok; else r=bad; fi
    check "invalid code [$bad]" bad "$r"
done

# mdp_cycle
check "cycle right 0"    1  "$(mdp_cycle 0 1)"
check "cycle right wrap" 0  "$(mdp_cycle 15 1)"
check "cycle left wrap"  15 "$(mdp_cycle 0 -1)"
check "cycle from 200 right" 0  "$(mdp_cycle 200 1)"
check "cycle from 200 left"  15 "$(mdp_cycle 200 -1)"

# render_preview smoke: runs, mentions every layout without error
for layout in single two-line classic; do
    for pill in round bracket none; do
        out=$(PROMPT_LAYOUT=$layout PILL_STYLE=$pill VARIANT=custom render_preview 2>&1)
        if [[ "$out" == *main* ]]; then r=yes; else r=no; fi
        check "preview $layout/$pill has branch" yes "$r"
    done
done
# ---- icon-to-text gap stays a single space (theme) ----
theme_pill() { # style -> rendered capsule text
    (cd "$TMP" && env MODERN_DARK_PRO_NERD_FONTS=true MODERN_DARK_PRO_PILL_STYLE="$1" zsh -f -c 'source "$1"; _modern_dark_pro_make_pill "#fff" "X" "text"; print -r -- "$REPLY"' _ "$THEME" | tail -1)
}
for style in round bracket none; do
    out=$(theme_pill "$style")
    if [[ "$out" == *"X text"* && "$out" != *"X  text"* ]]; then r=yes; else r=no; fi
    check "theme $style pill has 1-space icon gap" yes "$r"
done

# ---- key reader: whole escape sequences are consumed, never leaked as commands ----
keys() { # printf-format input -> space-separated key tokens until EOF
    printf "$1" | bash -c '. "$1"; for _ in 1 2 3 4 5 6 7 8 9 10; do mdp_read_key || break; printf "%s " "$MDP_KEY"; [ "$MDP_KEY" = EOF ] && break; done' _ "$ROOT/lib/wizard-colors.sh"
}
check "key arrows CSI"        "UP DOWN RIGHT LEFT EOF "  "$(keys '\e[A\e[B\e[C\e[D')"
check "key arrows SS3"        "UP DOWN RIGHT LEFT EOF "  "$(keys '\eOA\eOB\eOC\eOD')"
check "key shift+arrow"       "RIGHT UP EOF "            "$(keys '\e[1;2C\e[1;2A')"
check "key ctrl+alt arrow"    "LEFT EOF "                "$(keys '\e[1;7D')"
check "key delete is inert"   "NONE x EOF "              "$(keys '\e[3~x')"
check "key alt+x is inert"    "NONE y EOF "              "$(keys '\exy')"
check "key plain + enter"     "a ENTER c EOF "           "$(keys 'a\nc')"
check "key bare esc"          "ESC EOF "                 "$(keys '\e')"

# preview spacing: one space between pills and after the classic connector
out=$(PILL_STYLE=bracket PROMPT_LAYOUT=classic VARIANT=night NERD_FONTS=false render_preview | sed 's/\x1b\[[0-9;]*m//g' | head -1)
if [[ "$out" == "┌─ [ "* && "$out" == *"] [ "* ]]; then r=yes; else r=no; fi
check "preview classic line has connector + pill gaps" yes "$r"

# ---- wizard menu state (lib/wizard-menu.sh) ----
# shellcheck source=../lib/wizard-menu.sh
. "$ROOT/lib/wizard-menu.sh"

cat > "$TMP/zshrc.sample" <<'EOF'
export MODERN_DARK_PRO_VARIANT="monokai"
export MODERN_DARK_PRO_PILL_STYLE='bracket'
export MODERN_DARK_PRO_PROMPT_LAYOUT=classic
export MODERN_DARK_PRO_PILL_COLOR_STYLE="bogus"
export MODERN_DARK_PRO_NERD_FONTS=true
export MODERN_DARK_PRO_NERD_FONTS=false
export MODERN_DARK_PRO_SHOW_CLOCK="true"
export MODERN_DARK_PRO_CLOCK_POSITION="top"
export MODERN_DARK_PRO_CLICKABLE_PATH="false"
export MODERN_DARK_PRO_COLOR_PATH="1"
export MODERN_DARK_PRO_COLOR_GIT_BRANCH="999"
export MODERN_DARK_PRO_COLOR_ERROR="$(touch PWNED2)"
export MODERN_DARK_PRO_CHAR="λ"
EOF
loaded=$(cd "$TMP" && . "$ROOT/lib/wizard-menu.sh" && mdp_load_settings "$TMP/zshrc.sample" \
    && echo "$VARIANT $PILL_STYLE $PROMPT_LAYOUT $PILL_COLOR_STYLE $NERD_FONTS $(mdp_clock_get) $CLICKABLE ${MDP_CUSTOM[1]} ${MDP_CUSTOM[2]} ${MDP_CUSTOM[5]} $MDP_CUSTOM_TOUCHED")
check "load settings" "monokai bracket classic solid false top false 1 114 167 true" "$loaded"
check "load never evaluates" no "$([ -e "$TMP/PWNED2" ] && echo yes || echo no)"
defaults=$(. "$ROOT/lib/wizard-menu.sh" && mdp_load_settings "$TMP/does-not-exist" \
    && echo "$VARIANT $PILL_STYLE $PILL_COLOR_STYLE $PROMPT_LAYOUT $NERD_FONTS $(mdp_clock_get) $CLICKABLE $MDP_CUSTOM_TOUCHED")
check "load missing file = defaults" "night round solid two-line true rprompt true false" "$defaults"
clockoff=$(. "$ROOT/lib/wizard-menu.sh" && mdp_clock_set off && echo "$SHOW_CLOCK $CLOCK_POS $(mdp_clock_get)")
check "clock off mapping" "false top off" "$clockoff"
clocktop=$(. "$ROOT/lib/wizard-menu.sh" && mdp_clock_set top && echo "$SHOW_CLOCK $CLOCK_POS $(mdp_clock_get)")
check "clock top mapping" "true top top" "$clocktop"

check "next_in forward"  monokai "$(mdp_next_in night 1 night monokai custom)"
check "next_in wrap fwd" night   "$(mdp_next_in custom 1 night monokai custom)"
check "next_in wrap back" custom "$(mdp_next_in night -1 night monokai custom)"
check "next_in unknown value starts at first" monokai "$(mdp_next_in zzz 1 night monokai custom)"

# row movement: Capsule fill (row 3) is hidden unless style=round
mv() { # style row dir
    (. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; PILL_STYLE="$1"; mdp_move "$2" "$3")
}
check "move down onto fill (round)"    3 "$(mv round 2 1)"
check "move down skips fill (bracket)" 4 "$(mv bracket 2 1)"
check "move up skips fill (none)"      2 "$(mv none 4 -1)"
check "move up onto fill (round)"      3 "$(mv round 4 -1)"
check "move wraps down"                0 "$(mv round 9 1)"
check "move wraps up"                  9 "$(mv round 0 -1)"

# changing values
chg() { # row dir [setup]
    (. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; eval "${3:-:}"; mdp_change "$1" "$2"; mdp_state)
}
check "change layout"      "night|round|solid|single|true|true|rprompt|true|${MDP_NIGHT[*]}"   "$(chg 4 1)"
check "change nerd off"    "night|round|solid|two-line|false|true|rprompt|true|${MDP_NIGHT[*]}" "$(chg 5 1)"
check "change clock -> top" "night|round|solid|two-line|true|true|top|true|${MDP_NIGHT[*]}"      "$(chg 6 1)"
check "change links off"   "night|round|solid|two-line|true|true|rprompt|false|${MDP_NIGHT[*]}" "$(chg 7 1)"
check "change fill"        "night|round|dark|two-line|true|true|rprompt|true|${MDP_NIGHT[*]}"   "$(chg 3 1)"

# custom palette seeding
seeded=$(. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; VARIANT=monokai; mdp_change 0 -1 >/dev/null; echo "$VARIANT")
check "monokai <- goes to night" night "$seeded"
seeded=$(. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; VARIANT=monokai; mdp_change 0 1; echo "$VARIANT ${MDP_CUSTOM[1]}")
check "monokai -> custom seeds monokai codes" "custom ${MDP_MONOKAI[1]}" "$seeded"
kept=$(. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; MDP_CUSTOM[1]=200; MDP_CUSTOM_TOUCHED=true; VARIANT=monokai; mdp_change 0 1; echo "$VARIANT ${MDP_CUSTOM[1]}")
check "touched custom palette is kept" "custom 200" "$kept"
reseed=$(. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; mdp_change 0 1; mdp_change 0 1; mdp_change 0 1; mdp_change 0 -1; mdp_change 0 -1; echo "$VARIANT ${MDP_CUSTOM[1]}")  # monokai, custom(seed monokai), night, custom(reseed night), monokai
check "untouched custom reseeds from the variant it was entered from" "monokai ${MDP_NIGHT[1]}" "$reseed"

# ---- capsule text contrast (solid round capsules) ----
pill_txt() { # fg [env assignments...] -> text color used inside a solid round capsule
    (cd "$TMP" && env MODERN_DARK_PRO_PILL_STYLE=round MODERN_DARK_PRO_PILL_COLOR_STYLE=solid MODERN_DARK_PRO_NERD_FONTS=false ${@:2} \
        zsh -f -c 'source "$1"; _modern_dark_pro_make_pill "$2" "X" "text"; print -r -- "$REPLY"' _ "$THEME" "$1" | tail -1 \
        | sed -n 's/.*%F{\(#[0-9a-f]*\)}[^ ]* text.*/\1/p')
}
for c in 0 1 4 5 12 16 17 232 240; do check "text on dark code $c is light" "#f8f8f2" "$(pill_txt $c)"; done
for c in 2 7 8 10 11 14 15 75 114 214 231 250 255; do check "text on bright code $c is dark" "#111111" "$(pill_txt $c)"; done
check "text on hex background stays dark" "#111111" "$(pill_txt '#64b5f6')"
check "user text color overrides contrast" "#ff0000" "$(pill_txt 0 MODERN_DARK_PRO_PILL_TEXT_COLOR=#ff0000)"

# wizard preview rule must equal the theme's for every code
zsh_all=$(cd "$TMP" && zsh -f -c 'source "$1"; for n in {0..255}; do _modern_dark_pro_text_on $n; print -r -- $REPLY; done' _ "$THEME" | tail -256 | tr '\n' ' ')
bash_all=$(for n in $(seq 0 255); do mdp_text_on "$n"; printf '%s ' "$MDP_TEXT_HEX"; done)
check "preview text rule == theme rule for codes 0-255" "$zsh_all" "$bash_all"

# preview capsule text follows the same contrast rule
prev_text() { # custom code -> 233 (dark text) or 255 (light text) used in the preview capsule
    (. "$ROOT/lib/wizard-colors.sh"; VARIANT=custom PILL_STYLE=round PILL_COLOR_STYLE=solid; MDP_CUSTOM[1]="$1"; MDP_LINE=""; mdp_pill 1 X text
     case "$MDP_LINE" in *'38;5;255m'*) echo 255 ;; *'38;5;233m'*) echo 233 ;; *) echo none ;; esac)
}
check "preview text on code 0"  255 "$(prev_text 0)"
check "preview text on code 4"  255 "$(prev_text 4)"
check "preview text on code 75" 233 "$(prev_text 75)"

# ---- single layout has no separate "top line" clock ----
state_after() { # setup-script -> state fingerprint
    (. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; eval "$1"; mdp_state)
}
check "layout -> single normalizes clock top -> rprompt" \
    "night|round|solid|single|true|true|rprompt|true|${MDP_NIGHT[*]}" \
    "$(state_after 'mdp_clock_set top; mdp_change 4 1')"
check "layout -> single keeps clock off" \
    "night|round|solid|single|true|false|top|true|${MDP_NIGHT[*]}" \
    "$(state_after 'mdp_clock_set off; mdp_change 4 1')"
clock_cycle() { # layout steps -> clock values visited going right
    (. "$ROOT/lib/wizard-menu.sh"; mdp_defaults; PROMPT_LAYOUT="$1"; mdp_clock_set rprompt
     for _ in 1 2 3; do mdp_change 6 1; printf '%s ' "$(mdp_clock_get)"; done)
}
check "clock cycle in single: no top line" "off rprompt off " "$(clock_cycle single)"
check "clock cycle in two-line: has top line" "top off rprompt " "$(clock_cycle two-line)"
check "clock cycle in classic: has top line"  "top off rprompt " "$(clock_cycle classic)"
loaded_single=$(. "$ROOT/lib/wizard-menu.sh"; printf '%s\n' 'export MODERN_DARK_PRO_PROMPT_LAYOUT="single"' 'export MODERN_DARK_PRO_CLOCK_POSITION="top"' > "$TMP/zshrc.single"; mdp_load_settings "$TMP/zshrc.single"; echo "$PROMPT_LAYOUT $(mdp_clock_get)")
check "load single + top clock -> rprompt" "single rprompt" "$loaded_single"

# ---- wizard end-to-end (stdin is not a TTY: no UI, settings come from ~/.zshrc) ----
HOME_T="$TMP/home"
mkdir -p "$HOME_T/custom/themes"
seed() { printf '%s\n' 'export ZSH="$HOME/.oh-my-zsh"' 'ZSH_THEME="robbyrussell"' "$@" 'source $ZSH/oh-my-zsh.sh' > "$HOME_T/.zshrc"; }
run_wizard() { # stdin text
    printf "$1" | env HOME="$HOME_T" TERM=xterm ZSH_CUSTOM="$HOME_T/custom" bash "$ROOT/wizard.sh" --lang=en >/dev/null 2>&1
    echo $?
}
count() { grep -c "$1" "$HOME_T/.zshrc" || true; }

seed 'export MODERN_DARK_PRO_VARIANT="custom"' 'export MODERN_DARK_PRO_COLOR_PATH="1"' \
     'export MODERN_DARK_PRO_CHAR="λ"' 'export MODERN_DARK_PRO_PATH_STYLE="shrink"'
check "e2e custom: exit status 0"   0 "$(run_wizard 'Y\nn\n')"
check "e2e custom: variant"         1 "$(count '^export MODERN_DARK_PRO_VARIANT="custom"')"
check "e2e custom: 8 color vars"    8 "$(count '^export MODERN_DARK_PRO_COLOR_')"
check "e2e custom: seeded PATH kept" 1 "$(count '^export MODERN_DARK_PRO_COLOR_PATH="1"')"
check "e2e custom: night default"   1 "$(count '^export MODERN_DARK_PRO_COLOR_GIT_BRANCH="114"')"
check "e2e custom: one ZSH_THEME"   1 "$(count '^ZSH_THEME=')"
check "e2e keeps hand-set CHAR"       1 "$(count '^export MODERN_DARK_PRO_CHAR="λ"')"
check "e2e keeps hand-set PATH_STYLE" 1 "$(count '^export MODERN_DARK_PRO_PATH_STYLE="shrink"')"

seed 'export MODERN_DARK_PRO_VARIANT="night"' 'export MODERN_DARK_PRO_COLOR_PATH="1"'
check "e2e night: exit status 0"      0 "$(run_wizard 'Y\nn\n')"
check "e2e night: variant"            1 "$(count '^export MODERN_DARK_PRO_VARIANT="night"')"
check "e2e night: no color vars"      0 "$(count '^export MODERN_DARK_PRO_COLOR_')"
check "e2e night: one ZSH_THEME"      1 "$(count '^ZSH_THEME=')"

seed 'export MODERN_DARK_PRO_VARIANT="monokai"' 'export MODERN_DARK_PRO_PILL_STYLE="bracket"' \
     'export MODERN_DARK_PRO_SHOW_CLOCK="false"' 'export MODERN_DARK_PRO_CLICKABLE_PATH="false"'
run_wizard 'Y\nn\n' >/dev/null
check "e2e roundtrip monokai"   1 "$(count '^export MODERN_DARK_PRO_VARIANT="monokai"')"
check "e2e roundtrip bracket"   1 "$(count '^export MODERN_DARK_PRO_PILL_STYLE="bracket"')"
check "e2e roundtrip clock off" 1 "$(count '^export MODERN_DARK_PRO_SHOW_CLOCK=false')"
check "e2e roundtrip links off" 2 "$(count '^export MODERN_DARK_PRO_CLICKABLE_.*=false')"

seed
check "e2e 'n' at apply prompt cancels" 0 "$(run_wizard 'n\n')"
check "e2e cancelled writes nothing"    0 "$(count '^export MODERN_DARK_PRO_')"

# ---- language detection: LC_ALL > LC_MESSAGES > LANG, --lang overrides ----
wizard_lang() { # env assignments... -- extra wizard args -> language code shown in the header
    local envs=() args=()
    while [ "$#" -gt 0 ] && [ "$1" != -- ]; do envs+=("$1"); shift; done
    shift
    args=("$@")
    printf '\nn\n' | env -u LANG -u LC_ALL -u LC_MESSAGES ${envs[@]+"${envs[@]}"} HOME="$TMP/langhome" TERM=xterm ZSH_CUSTOM="$TMP/langhome/custom" \
        bash "$ROOT/wizard.sh" ${args[@]+"${args[@]}"} 2>/dev/null | sed -n 's/.*Sprache \/ 语言: \([a-z]*\)).*/\1/p' | head -1
}
mkdir -p "$TMP/langhome/custom/themes"; : > "$TMP/langhome/.zshrc"
check "lang LC_ALL beats LANG"        de "$(wizard_lang LC_ALL=de_DE.UTF-8 LANG=en_US.UTF-8 --)"
check "lang LC_MESSAGES beats LANG"   fr "$(wizard_lang LC_MESSAGES=fr_FR.UTF-8 LANG=en_US.UTF-8 --)"
check "lang LC_ALL beats LC_MESSAGES" de "$(wizard_lang LC_ALL=de_DE.UTF-8 LC_MESSAGES=fr_FR.UTF-8 --)"
check "lang LANG alone"               es "$(wizard_lang LANG=es_ES.UTF-8 --)"
check "lang --lang overrides env"     zh "$(wizard_lang LC_ALL=de_DE.UTF-8 -- --lang=zh)"

# ---- menu via a real pty ----
if command -v python3 >/dev/null 2>&1; then
    pty_out=$(python3 "$ROOT/tests/check-menu.py" 2>&1); pty_rc=$?
    echo "$pty_out"
    if [ "$pty_rc" -eq 0 ]; then r=ok; else r=fail; fi
    check "pty menu session" ok "$r"
fi
# ---- end ----

if [ "$FAILS" -eq 0 ]; then echo "all passed"; else echo "$FAILS failed"; exit 1; fi
