#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Modern Dark Pro Capsule - Multi-Language Interactive Configuration Wizard
# Supports: English (en), Spanish (es), French (fr), German (de), Chinese (zh)
# Auto-detects system language with CLI flag override (--lang=es)
# ------------------------------------------------------------------------------

set -e

# Terminal ANSI Formatting
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
BLUE="\033[34m"
DIM="\033[2m"
RESET="\033[0m"

ZSHRC="$HOME/.zshrc"
THEME_NAME="modern-dark-pro-capsule"
THEME_FILE="${THEME_NAME}.zsh-theme"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
DEST_DIR="${ZSH_CUSTOM}/themes"
DEST_FILE="${DEST_DIR}/${THEME_FILE}"

# Temp file registry for safe EXIT/INT signal cleanup
TMP_FILES=()
cleanup_tmp() {
    local f
    for f in "${TMP_FILES[@]}"; do
        if [ -f "$f" ]; then rm -f "$f" 2>/dev/null; fi
    done
    return 0
}
trap 'if [ -n "$(type -t mdp_term_leave)" ]; then mdp_term_leave; fi; cleanup_tmp' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Language Auto-Detection
DETECTED_LANG="${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}"
if [[ "$DETECTED_LANG" == "C"* || "$DETECTED_LANG" == "POSIX"* || -z "$DETECTED_LANG" ]]; then
    if command -v defaults &>/dev/null; then
        mac_lang=$(defaults read -g AppleLanguages 2>/dev/null | grep -oE '"[a-z]{2}' | head -n 1 | tr -d '"')
        [[ -n "$mac_lang" ]] && DETECTED_LANG="$mac_lang"
    fi
fi
DETECTED_LANG="${DETECTED_LANG:0:2}"

LANG_CODE="${DETECTED_LANG}"
for arg in "$@"; do
    case "$arg" in
        --lang=*) LANG_CODE="${arg#*=}" ;;
    esac
done

case "$LANG_CODE" in
    es)
        T_TITLE="🎨 Modern Dark Pro Capsule Theme - Asistente de Configuración"
        T_EDIT_TITLE="Colores Personalizados"
        T_EDIT_HELP="↑/↓ elemento  ←/→ color  a: escribir código 0-255  r: restablecer elemento  c: restablecer todo  Enter: listo"
        T_EDIT_CODE_PROMPT="Código de color (0-255):"
        T_PREVIEW="Vista previa"
        T_M_SCHEME="Esquema de color"
        T_M_EDIT="Editar colores"
        T_M_EDIT_HINT="paleta personalizada..."
        T_M_STYLE="Estilo de cápsula"
        T_M_FILL="Relleno de cápsula"
        T_M_LAYOUT="Diseño"
        T_M_NERD="Nerd Fonts"
        T_M_CLOCK="Reloj"
        T_M_LINKS="Enlaces clicables"
        T_M_SAVE="Guardar y salir"
        T_M_QUIT="Salir sin guardar"
        T_M_HELP="↑/↓ mover  ←/→ o Enter cambiar  s guardar  q salir"
        T_M_DISCARD="¿Descartar los cambios? [y/N]"
        T_NEED_TERM="Este asistente necesita un terminal interactivo (TERM no está definido o es 'dumb')."
        T_V_ON="activado"
        T_V_OFF="desactivado"
        T_V_RPROMPT="prompt derecho"
        T_V_TOP="línea superior"
        T_SUMMARY="Resumen de Configuración:"
        T_APPLY_PROMPT="¿Guardar esta configuración en ~/.zshrc? [Y/n]"
        T_CANCELLED="Configuración cancelada."
        T_SAVED="¡Configuración guardada correctamente en ~/.zshrc!"
        T_RELOAD_PROMPT="¿Deseas recargar la sesión de tu terminal ahora (exec zsh)? [Y/n]"
        T_RELOAD_SOURCE_PROMPT="¿Deseas aplicar la configuración ahora (source ~/.zshrc)? [Y/n]"
        T_RELOADING="Recargando sesión del terminal..."
        T_APPLYING="Aplicando configuración..."
        T_MANUAL_NOTE="Para aplicar los cambios manualmente en esta ventana, ejecuta:"
        ;;
    fr)
        T_TITLE="🎨 Modern Dark Pro Capsule Theme - Assistant de Configuration"
        T_EDIT_TITLE="Couleurs Personnalisées"
        T_EDIT_HELP="↑/↓ élément  ←/→ couleur  a : saisir un code 0-255  r : réinitialiser l'élément  c : tout réinitialiser  Entrée : terminé"
        T_EDIT_CODE_PROMPT="Code couleur (0-255) :"
        T_PREVIEW="Aperçu"
        T_M_SCHEME="Palette de couleurs"
        T_M_EDIT="Modifier les couleurs"
        T_M_EDIT_HINT="palette personnalisée..."
        T_M_STYLE="Style des capsules"
        T_M_FILL="Remplissage des capsules"
        T_M_LAYOUT="Disposition"
        T_M_NERD="Nerd Fonts"
        T_M_CLOCK="Horloge"
        T_M_LINKS="Liens cliquables"
        T_M_SAVE="Enregistrer et quitter"
        T_M_QUIT="Quitter sans enregistrer"
        T_M_HELP="↑/↓ déplacer  ←/→ ou Entrée modifier  s enregistrer  q quitter"
        T_M_DISCARD="Abandonner les modifications ? [y/N]"
        T_NEED_TERM="Cet assistant nécessite un terminal interactif (TERM non défini ou « dumb »)."
        T_V_ON="activé"
        T_V_OFF="désactivé"
        T_V_RPROMPT="prompt de droite"
        T_V_TOP="ligne du haut"
        T_SUMMARY="Résumé de la Configuration :"
        T_APPLY_PROMPT="Appliquer ces paramètres dans ~/.zshrc ? [Y/n]"
        T_CANCELLED="Configuration annulée."
        T_SAVED="Configuration enregistrée avec succès dans ~/.zshrc !"
        T_RELOAD_PROMPT="Voulez-vous recharger votre session de terminal maintenant (exec zsh) ? [Y/n]"
        T_RELOAD_SOURCE_PROMPT="Voulez-vous appliquer la configuration maintenant (source ~/.zshrc) ? [Y/n]"
        T_RELOADING="Rechargement de la session..."
        T_APPLYING="Application de la configuration..."
        T_MANUAL_NOTE="Pour appliquer les modifications manuellement, exécutez :"
        ;;
    de)
        T_TITLE="🎨 Modern Dark Pro Capsule Theme - Konfigurationsassistent"
        T_EDIT_TITLE="Eigene Farben"
        T_EDIT_HELP="↑/↓ Element  ←/→ Farbe  a: Code 0-255 eingeben  r: Element zurücksetzen  c: alles zurücksetzen  Enter: fertig"
        T_EDIT_CODE_PROMPT="Farbcode (0-255):"
        T_PREVIEW="Vorschau"
        T_M_SCHEME="Farbschema"
        T_M_EDIT="Farben bearbeiten"
        T_M_EDIT_HINT="eigene Palette..."
        T_M_STYLE="Kapselstil"
        T_M_FILL="Kapselfüllung"
        T_M_LAYOUT="Layout"
        T_M_NERD="Nerd Fonts"
        T_M_CLOCK="Uhr"
        T_M_LINKS="Klickbare Links"
        T_M_SAVE="Speichern und beenden"
        T_M_QUIT="Beenden ohne Speichern"
        T_M_HELP="↑/↓ bewegen  ←/→ oder Enter ändern  s speichern  q beenden"
        T_M_DISCARD="Änderungen verwerfen? [y/N]"
        T_NEED_TERM="Dieser Assistent benötigt ein interaktives Terminal (TERM ist nicht gesetzt oder 'dumb')."
        T_V_ON="an"
        T_V_OFF="aus"
        T_V_RPROMPT="rechter Prompt"
        T_V_TOP="obere Zeile"
        T_SUMMARY="Konfigurationszusammenfassung:"
        T_APPLY_PROMPT="Einstellungen in ~/.zshrc übernehmen? [Y/n]"
        T_CANCELLED="Konfiguration abgebrochen."
        T_SAVED="Konfiguration erfolgreich in ~/.zshrc gespeichert!"
        T_RELOAD_PROMPT="Möchten Sie Ihre Terminal-Sitzung jetzt neu laden (exec zsh)? [Y/n]"
        T_RELOAD_SOURCE_PROMPT="Möchten Sie die Konfiguration jetzt anwenden (source ~/.zshrc)? [Y/n]"
        T_RELOADING="Terminal-Sitzung wird neu geladen..."
        T_APPLYING="Konfiguration wird angewendet..."
        T_MANUAL_NOTE="Um Änderungen manuell zu übernehmen, führen Sie aus:"
        ;;
    zh)
        T_TITLE="🎨 Modern Dark Pro Capsule 主题 - 配置向导"
        T_EDIT_TITLE="自定义颜色"
        T_EDIT_HELP="↑/↓ 选择项目  ←/→ 切换颜色  a：输入 0-255 代码  r：重置当前项  c：全部重置  Enter：完成"
        T_EDIT_CODE_PROMPT="颜色代码 (0-255)："
        T_PREVIEW="预览"
        T_M_SCHEME="配色方案"
        T_M_EDIT="编辑颜色"
        T_M_EDIT_HINT="自定义调色板..."
        T_M_STYLE="胶囊样式"
        T_M_FILL="胶囊填充"
        T_M_LAYOUT="布局"
        T_M_NERD="Nerd 字体"
        T_M_CLOCK="时钟"
        T_M_LINKS="可点击链接"
        T_M_SAVE="保存并退出"
        T_M_QUIT="不保存退出"
        T_M_HELP="↑/↓ 移动  ←/→ 或 Enter 修改  s 保存  q 退出"
        T_M_DISCARD="放弃更改？[y/N]"
        T_NEED_TERM="此向导需要交互式终端（TERM 未设置或为 'dumb'）。"
        T_V_ON="开"
        T_V_OFF="关"
        T_V_RPROMPT="右侧提示符"
        T_V_TOP="顶行"
        T_SUMMARY="配置摘要："
        T_APPLY_PROMPT="是否将这些设置应用到 ~/.zshrc？ [Y/n]"
        T_CANCELLED="配置已取消。"
        T_SAVED="配置已成功保存到 ~/.zshrc！"
        T_RELOAD_PROMPT="是否立即重新加载终端会话 (exec zsh)？ [Y/n]"
        T_RELOAD_SOURCE_PROMPT="是否立即应用配置 (source ~/.zshrc)？ [Y/n]"
        T_RELOADING="正在重新加载终端会话..."
        T_APPLYING="正在应用配置..."
        T_MANUAL_NOTE="如需手动应用更改，请运行："
        ;;
    *) # English (default fallback)
        T_TITLE="🎨 Modern Dark Pro Capsule Theme - Configuration Wizard"
        T_EDIT_TITLE="Custom Colors"
        T_EDIT_HELP="↑/↓ item  ←/→ color  a: type code 0-255  r: reset item  c: reset all  Enter: done"
        T_EDIT_CODE_PROMPT="Color code (0-255):"
        T_PREVIEW="Preview"
        T_M_SCHEME="Color scheme"
        T_M_EDIT="Edit colors"
        T_M_EDIT_HINT="custom palette..."
        T_M_STYLE="Capsule style"
        T_M_FILL="Capsule fill"
        T_M_LAYOUT="Layout"
        T_M_NERD="Nerd Fonts"
        T_M_CLOCK="Clock"
        T_M_LINKS="Clickable links"
        T_M_SAVE="Save and exit"
        T_M_QUIT="Quit without saving"
        T_M_HELP="↑/↓ move  ←/→ or Enter change  s save  q quit"
        T_M_DISCARD="Discard changes? [y/N]"
        T_NEED_TERM="This wizard needs an interactive terminal (TERM is unset or 'dumb')."
        T_V_ON="on"
        T_V_OFF="off"
        T_V_RPROMPT="right prompt"
        T_V_TOP="top line"
        T_SUMMARY="Configuration Summary:"
        T_APPLY_PROMPT="Apply these settings to ~/.zshrc? [Y/n]"
        T_CANCELLED="Configuration cancelled."
        T_SAVED="Configuration successfully saved to ~/.zshrc!"
        T_RELOAD_PROMPT="Would you like to reload your terminal session now (exec zsh)? [Y/n]"
        T_RELOAD_SOURCE_PROMPT="Would you like to apply the configuration now (source ~/.zshrc)? [Y/n]"
        T_RELOADING="Reloading terminal session..."
        T_APPLYING="Applying configuration..."
        T_MANUAL_NOTE="To activate your changes manually in this terminal window, run:"
        ;;
esac

# shellcheck source=lib/wizard-colors.sh
source "${SCRIPT_DIR}/lib/wizard-colors.sh"
# shellcheck source=lib/wizard-menu.sh
source "${SCRIPT_DIR}/lib/wizard-menu.sh"

# Start from the user's current settings (read with grep, never sourced)
mdp_load_settings "$ZSHRC"

if [ -t 0 ]; then
    case "${TERM:-dumb}" in
        dumb)
            echo "${T_NEED_TERM}" >&2
            exit 1
            ;;
    esac
    mdp_term_enter
    if mdp_menu; then menu_saved=true; else menu_saved=false; fi
    mdp_term_leave
    if [ "$menu_saved" != true ]; then
        echo "${T_CANCELLED}"
        exit 0
    fi
fi

# --- Summary of Choices ---
echo -e "${BOLD}${CYAN}"
echo "----------------------------------------------------------------------"
echo "  ${T_TITLE}"
echo "----------------------------------------------------------------------"
echo -e "${RESET}"
echo -e "${DIM}(Language / Idioma / Langue / Sprache / 语言: ${LANG_CODE})${RESET}"
echo -e "${BOLD}📋 ${T_SUMMARY}${RESET}"
echo -e "  • ZSH_THEME:                      ${GREEN}${THEME_NAME}${RESET}"
echo -e "  • MODERN_DARK_PRO_VARIANT:        ${YELLOW}${VARIANT}${RESET}"
if [ "$VARIANT" = custom ]; then
    for ((i = 0; i < ${#MDP_ITEMS[@]}; i++)); do
        echo -e "  • MODERN_DARK_PRO_COLOR_${MDP_ITEMS[$i]}: ${YELLOW}${MDP_CUSTOM[$i]}${RESET}"
    done
fi
echo -e "  • MODERN_DARK_PRO_PILL_STYLE:     ${YELLOW}${PILL_STYLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_PILL_COLOR_STYLE: ${YELLOW}${PILL_COLOR_STYLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_PROMPT_LAYOUT:  ${YELLOW}${PROMPT_LAYOUT}${RESET}"
echo -e "  • MODERN_DARK_PRO_NERD_FONTS:     ${YELLOW}${NERD_FONTS}${RESET}"
echo -e "  • MODERN_DARK_PRO_SHOW_CLOCK:     ${YELLOW}${SHOW_CLOCK}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLOCK_POSITION: ${YELLOW}${CLOCK_POS}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLICKABLE_PATH: ${YELLOW}${CLICKABLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLICKABLE_GIT:  ${YELLOW}${CLICKABLE}${RESET}"
echo -e "${BOLD}${CYAN}----------------------------------------------------------------------${RESET}"

read -e -p "${T_APPLY_PROMPT} " choice_confirm
if [[ "$choice_confirm" =~ ^[Nn]$ ]]; then
    echo "${T_CANCELLED}"
    exit 0
fi

# Ensure ~/.zshrc exists
touch "$ZSHRC"

# Backup ~/.zshrc
cp "$ZSHRC" "${ZSHRC}.bak.$(date +%Y%m%d%H%M%S)"
echo -e "${DIM}💾 Backup created at ${ZSHRC}.bak...${RESET}"

# Write config block into a temp file
cfg_file=$(mktemp)
TMP_FILES+=("$cfg_file")
cat << CONFIG_EOF > "$cfg_file"
# Modern Dark Pro Capsule Theme Config
ZSH_THEME="${THEME_NAME}"
export MODERN_DARK_PRO_VARIANT="${VARIANT}"
export MODERN_DARK_PRO_PILL_STYLE="${PILL_STYLE}"
export MODERN_DARK_PRO_PILL_COLOR_STYLE="${PILL_COLOR_STYLE}"
export MODERN_DARK_PRO_PROMPT_LAYOUT="${PROMPT_LAYOUT}"
export MODERN_DARK_PRO_NERD_FONTS=${NERD_FONTS}
export MODERN_DARK_PRO_SHOW_CLOCK=${SHOW_CLOCK}
export MODERN_DARK_PRO_CLOCK_POSITION="${CLOCK_POS}"
export MODERN_DARK_PRO_CLICKABLE_PATH=${CLICKABLE}
export MODERN_DARK_PRO_CLICKABLE_GIT=${CLICKABLE}

CONFIG_EOF
mdp_exports >> "$cfg_file"

# Filter existing theme lines from ~/.zshrc into temp file
cleaned_zshrc=$(mktemp)
TMP_FILES+=("$cleaned_zshrc")
grep -v "^ZSH_THEME=" "$ZSHRC" | grep -v -E '^export MODERN_DARK_PRO_(VARIANT|PILL_STYLE|PILL_COLOR_STYLE|PROMPT_LAYOUT|NERD_FONTS|SHOW_CLOCK|CLOCK_POSITION|CLICKABLE_PATH|CLICKABLE_GIT|COLOR_[A-Z_]+)=' | grep -v "^# Modern Dark Pro" > "$cleaned_zshrc" || true

tmp_file=$(mktemp)
TMP_FILES+=("$tmp_file")

# Insert cfg_file before "source $ZSH/oh-my-zsh.sh"
if grep -q "source \$ZSH/oh-my-zsh.sh" "$cleaned_zshrc"; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ source\ \$ZSH/oh-my-zsh\.sh ]]; then
            cat "$cfg_file" >> "$tmp_file"
        fi
        echo "$line" >> "$tmp_file"
    done < "$cleaned_zshrc"
else
    cat "$cfg_file" >> "$tmp_file"
    cat "$cleaned_zshrc" >> "$tmp_file"
fi

rm -f "$cfg_file" "$cleaned_zshrc"
mv "$tmp_file" "$ZSHRC"

echo ""
echo -e "${BOLD}${GREEN}✅ ${T_SAVED}${RESET}"
echo ""

# Ask to apply changes immediately
if [[ "${ZSH_EVAL_CONTEXT:-}" == *"toplevel"* ]] || [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # Script was sourced directly
    read -e -p "🔄 ${T_RELOAD_SOURCE_PROMPT} " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${GREEN}${T_APPLYING}${RESET}"
        source "$ZSHRC"
    fi
else
    # Script was executed as a subprocess
    read -e -p "🔄 ${T_RELOAD_PROMPT} " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${DIM}${T_RELOADING}${RESET}"
        exec zsh
    else
        echo -e "${T_MANUAL_NOTE}"
        echo -e "  ${BOLD}${CYAN}source ~/.zshrc${RESET}"
        echo ""
    fi
fi
