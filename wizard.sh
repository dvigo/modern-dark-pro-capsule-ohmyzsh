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
    for f in "${TMP_FILES[@]}"; do
        [ -f "$f" ] && rm -f "$f" 2>/dev/null
    done
}
trap cleanup_tmp EXIT INT TERM

# Language Auto-Detection
DETECTED_LANG="${LANG:-${LC_ALL:-${LC_MESSAGES:-en}}}"
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
        T_SUBTITLE="¡Bienvenido! Este asistente te guiará para personalizar tu terminal."
        T_STEP1_TITLE="Variante de Color"
        T_STEP1_DESC="Elige tu paleta de colores base:"
        T_STEP1_OPT1="Night (Tonos pastel suaves en fondo oscuro)"
        T_STEP1_OPT2="Monokai (Colores clásicos Monokai de alto contraste)"
        T_STEP2_TITLE="Estilo de Contenedor de Cápsula"
        T_STEP2_DESC="Elige cómo se enmarcan los segmentos de estado (directorio, git, runtimes):"
        T_STEP2_OPT1="Redondeado (Cápsulas sólidas Powerline  pill )"
        T_STEP2_OPT2="Corchetes (Contenedores finos [ pill ])"
        T_STEP2_OPT3="Ninguno (Texto minimalista sin contenedores)"
        T_STEP3_TITLE="Estilo de Color de Cápsulas"
        T_STEP3_DESC="Elige la combinación de colores para cápsulas redondeadas:"
        T_STEP3_OPT1="Sólido (Fondo de color con texto oscuro de alta legibilidad)"
        T_STEP3_OPT2="Oscuro (Fondo gris oscuro #282828 con texto de color)"
        T_STEP4_TITLE="Estructura del Prompt"
        T_STEP4_DESC="Elige la disposición de la línea del prompt:"
        T_STEP4_OPT1="Dos Líneas (Línea 1: Cápsulas + reloj, Línea 2: Entrada ❯)"
        T_STEP4_OPT2="Una Línea (Cápsulas + entrada ❯ en una línea)"
        T_STEP4_OPT3="Clásico (Cápsulas con líneas guía ┌─ y └─)"
        T_STEP5_TITLE="Iconos de Desarrollador (Nerd Fonts)"
        T_STEP5_DESC="¿Tienes una tipografía Nerd Font instalada y activa en tu terminal?"
        T_STEP5_OPT1="Sí (Activar iconos:  carpeta,  git,  reloj,  candado)"
        T_STEP5_OPT2="No (Usar iconos Unicode estándar: 📁, ⌥, 🕒, 🔒)"
        T_STEP6_TITLE="Posición del Reloj"
        T_STEP6_DESC="¿Dónde deseas ubicar el reloj de sistema (HH:MM:SS)?"
        T_STEP6_OPT1="Línea del Prompt Derecha (RPROMPT) (Alineado al margen derecho)"
        T_STEP6_OPT2="Línea Superior Derecha (Alineado con espacios en línea 1)"
        T_STEP6_OPT3="Deshabilitado (Ocultar reloj)"
        T_STEP7_TITLE="Hipervínculos Clicables (OSC 8)"
        T_STEP7_DESC="¿Activar enlaces clicables (Cmd/Ctrl+Clic para abrir carpeta o rama Git)?"
        T_STEP7_OPT1="Activado"
        T_STEP7_OPT2="Desactivado"
        T_PROMPT_SELECT="Selecciona una opción"
        T_DEFAULT="Por defecto"
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
        T_SUBTITLE="Bienvenue ! Cet assistant vous guidera pour configurer votre terminal."
        T_STEP1_TITLE="Variante de Couleur"
        T_STEP1_DESC="Choisissez votre palette de couleurs de base :"
        T_STEP1_OPT1="Night (Tons pastel doux sur fond sombre)"
        T_STEP1_OPT2="Monokai (Couleurs Monokai classiques à fort contraste)"
        T_STEP2_TITLE="Style de Conteneur de Capsule"
        T_STEP2_DESC="Choisissez le cadrage des segments d'état (dossier, git, environnements) :"
        T_STEP2_OPT1="Arrondi (Capsules solides Powerline  pill )"
        T_STEP2_OPT2="Crochets (Conteneurs fins [ pill ])"
        T_STEP2_OPT3="Aucun (Texte minimaliste sans conteneur)"
        T_STEP3_TITLE="Style de Couleur des Capsules"
        T_STEP3_DESC="Choisissez la couleur des capsules arrondies :"
        T_STEP3_OPT1="Solide (Fond de couleur avec texte sombre lisible)"
        T_STEP3_OPT2="Sombre (Fond gris sombre #282828 avec texte coloré)"
        T_STEP4_TITLE="Disposition de l'Invite"
        T_STEP4_DESC="Choisissez la structure de la ligne d'invite :"
        T_STEP4_OPT1="Deux Lignes (Ligne 1 : Capsules + horloge, Ligne 2 : Invite ❯)"
        T_STEP4_OPT2="Une Ligne (Capsules + invite ❯ sur une seule ligne)"
        T_STEP4_OPT3="Classique (Capsules avec connecteurs ┌─ et └─)"
        T_STEP5_TITLE="Icônes de Développeur (Nerd Fonts)"
        T_STEP5_DESC="Avez-vous une police Nerd Font installée et activée ?"
        T_STEP5_OPT1="Oui (Activer les icônes :  dossier,  git,  horloge,  cadenas)"
        T_STEP5_OPT2="Non (Utiliser le repli Unicode : 📁, ⌥, 🕒, 🔒)"
        T_STEP6_TITLE="Position de l'Horloge"
        T_STEP6_DESC="Où souhaitez-vous placer l'horloge système (HH:MM:SS) ?"
        T_STEP6_OPT1="Ligne d'Invite Droite (RPROMPT) (Alignée à la marge droite)"
        T_STEP6_OPT2="Ligne Supérieure Droite (Alignée avec des espaces)"
        T_STEP6_OPT3="Désactivée (Masquer l'horloge)"
        T_STEP7_TITLE="Liens Cliquables (OSC 8)"
        T_STEP7_DESC="Activer les liens cliquables (Cmd/Ctrl+Clic pour ouvrir le dossier ou la branche Git) ?"
        T_STEP7_OPT1="Activé"
        T_STEP7_OPT2="Désactivé"
        T_PROMPT_SELECT="Sélectionnez une option"
        T_DEFAULT="Par défaut"
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
        T_SUBTITLE="Willkommen! Dieser Assistent hilft Ihnen beim Konfigurieren Ihres Terminal-Prompts."
        T_STEP1_TITLE="Farbvariante"
        T_STEP1_DESC="Wählen Sie Ihr Farbschema:"
        T_STEP1_OPT1="Night (Sanfte Pastelltöne auf dunklem Hintergrund)"
        T_STEP1_OPT2="Monokai (Klassische kontrastreiche Monokai-Farben)"
        T_STEP2_TITLE="Kapsel-Stil"
        T_STEP2_DESC="Wählen Sie die Umrandung der Statussegmente (Ordner, Git, Runtimes):"
        T_STEP2_OPT1="Rund (Powerline solide abgerundete Kapseln  pill )"
        T_STEP2_OPT2="Eckige Klammern (Schlanke Klammer-Container [ pill ])"
        T_STEP2_OPT3="Keine (Minimalistischer Text ohne Container)"
        T_STEP3_TITLE="Kapsel-Farbgestaltung"
        T_STEP3_DESC="Wählen Sie die Farbgebung der abgerundeten Kapseln:"
        T_STEP3_OPT1="Solide (Farblicher Hintergrund mit dunklem lesbarem Text)"
        T_STEP3_OPT2="Dunkel (Dunkelgrauer #282828 Hintergrund mit farbigem Text)"
        T_STEP4_TITLE="Prompt-Layout"
        T_STEP4_DESC="Wählen Sie die Struktur der Prompt-Zeile:"
        T_STEP4_OPT1="Zweizeilig (Zeile 1: Kapseln + Uhr, Zeile 2: Eingabe ❯)"
        T_STEP4_OPT2="Einzeilig (Kapseln + Eingabe ❯ auf einer Zeile)"
        T_STEP4_OPT3="Klassisch (Kapseln mit Verbindungslinien ┌─ und └─)"
        T_STEP5_TITLE="Entwickler-Icons (Nerd Fonts)"
        T_STEP5_DESC="Haben Sie eine Nerd-Font-Schriftart installiert und aktiviert?"
        T_STEP5_OPT1="Ja (Icons aktivieren:  Ordner,  Git,  Uhr,  Schloss)"
        T_STEP5_OPT2="Nein (Standard-Unicode verwenden: 📁, ⌥, 🕒, 🔒)"
        T_STEP6_TITLE="Uhrzeit-Position"
        T_STEP6_DESC="Wo soll die System-Uhrzeit (HH:MM:SS) platziert werden?"
        T_STEP6_OPT1="Rechte Prompt-Zeile (RPROMPT) (Am rechten Rand ausgerichtet)"
        T_STEP6_OPT2="Obere Zeile Rechts (Mit Leerzeichen ausgerichtet)"
        T_STEP6_OPT3="Deaktiviert (Uhr ausblenden)"
        T_STEP7_TITLE="Klickbare Links (OSC 8)"
        T_STEP7_DESC="Klickbare Terminal-Links aktivieren (Cmd/Ctrl+Klick zum Öffnen von Ordner oder Git-Branch)?"
        T_STEP7_OPT1="Aktiviert"
        T_STEP7_OPT2="Deaktiviert"
        T_PROMPT_SELECT="Wählen Sie eine Option"
        T_DEFAULT="Standard"
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
        T_SUBTITLE="欢迎！此向导将帮助您配置终端 Prompt 样式。"
        T_STEP1_TITLE="颜色主题变体"
        T_STEP1_DESC="选择您的基础配色方案："
        T_STEP1_OPT1="Night (深色背景上的柔和粉彩配色)"
        T_STEP1_OPT2="Monokai (高对比度经典 Monokai 配色)"
        T_STEP2_TITLE="胶囊容器样式"
        T_STEP2_DESC="选择状态分段（目录、Git、运行环境）的包裹样式："
        T_STEP2_OPT1="圆角胶囊 (Powerline 实心圆角胶囊  pill )"
        T_STEP2_OPT2="方括号 (精美方括号容器 [ pill ])"
        T_STEP2_OPT3="无 (无容器的极简文本)"
        T_STEP3_TITLE="胶囊色彩样式"
        T_STEP3_DESC="选择圆角胶囊的配色模式："
        T_STEP3_OPT1="实心 (彩色背景配合清晰深色文字)"
        T_STEP3_OPT2="深灰 (深灰色 #282828 背景配合彩色文字)"
        T_STEP4_TITLE="Prompt 布局"
        T_STEP4_DESC="选择 Prompt 结构风格："
        T_STEP4_OPT1="双行 (第1行：状态胶囊+时钟，第2行：输入符 ❯)"
        T_STEP4_OPT2="单行 (状态胶囊+输入符 ❯ 在同一行)"
        T_STEP4_OPT3="经典 (使用连接线 ┌─ 和 └─ 的胶囊)"
        T_STEP5_TITLE="开发者图标 (Nerd Fonts)"
        T_STEP5_DESC="您的终端是否已安装并启用 Nerd Fonts 图标字体？"
        T_STEP5_OPT1="是 (启用图标： 文件夹,  Git,  时钟,  锁)"
        T_STEP5_OPT2="否 (使用标准 Unicode 图标：📁, ⌥, 🕒, 🔒)"
        T_STEP6_TITLE="时钟显示位置"
        T_STEP6_DESC="您希望时钟 (HH:MM:SS) 显示在哪里？"
        T_STEP6_OPT1="右侧 Prompt 行 (RPROMPT) (靠最右侧边界对齐)"
        T_STEP6_OPT2="顶行靠右对齐 (使用空格对齐)"
        T_STEP6_OPT3="禁用时钟 (不显示)"
        T_STEP7_TITLE="可点击超链接 (OSC 8)"
        T_STEP7_DESC="是否启用终端可点击链接 (Cmd/Ctrl+点击打开文件夹或 Git 分支)？"
        T_STEP7_OPT1="已启用"
        T_STEP7_OPT2="已禁用"
        T_PROMPT_SELECT="请选择选项"
        T_DEFAULT="默认"
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
        T_SUBTITLE="Welcome! This wizard will help you configure your terminal prompt style."
        T_STEP1_TITLE="Color Variant"
        T_STEP1_DESC="Choose your base color scheme:"
        T_STEP1_OPT1="Night (Soft pastel tones on dark background)"
        T_STEP1_OPT2="Monokai (Vibrant classic Monokai colors)"
        T_STEP2_TITLE="Capsule Container Style"
        T_STEP2_DESC="Choose how status segments (directory, git, runtimes) are framed:"
        T_STEP2_OPT1="Round (Powerline solid rounded pills  pill )"
        T_STEP2_OPT2="Bracket (Sleek bracket containers [ pill ])"
        T_STEP2_OPT3="None (Minimalist text without containers)"
        T_STEP3_TITLE="Capsule Color Style"
        T_STEP3_DESC="Choose coloring for rounded pills:"
        T_STEP3_OPT1="Solid (Vibrant segment background with dark readable text)"
        T_STEP3_OPT2="Dark (Dark gray #282828 background with colored text)"
        T_STEP4_TITLE="Prompt Layout"
        T_STEP4_DESC="Choose your prompt line structure:"
        T_STEP4_OPT1="Two-Line (Line 1: Status capsules + clock, Line 2: Input ❯)"
        T_STEP4_OPT2="Single-Line (Status capsules + input ❯ on single line)"
        T_STEP4_OPT3="Classic (Status capsules with guide connectors ┌─ and └─)"
        T_STEP5_TITLE="Developer Icons (Nerd Fonts)"
        T_STEP5_DESC="Do you have a Nerd Font installed and enabled in your terminal?"
        T_STEP5_OPT1="Yes (Enable icons:  folder,  git,  clock,  lock)"
        T_STEP5_OPT2="No (Use standard Unicode fallback: 📁, ⌥, 🕒, 🔒)"
        T_STEP6_TITLE="System Clock Position"
        T_STEP6_DESC="Where would you like the clock (HH:MM:SS) to be placed?"
        T_STEP6_OPT1="Right Prompt Line (RPROMPT) (Natively aligned to far right margin)"
        T_STEP6_OPT2="Top Line Right (Space-aligned on top capsule line)"
        T_STEP6_OPT3="Disabled (Hide clock completely)"
        T_STEP7_TITLE="Clickable Hyperlinks (OSC 8)"
        T_STEP7_DESC="Enable clickable terminal links (Cmd/Ctrl+Click to open folder or Git branch)?"
        T_STEP7_OPT1="Enabled"
        T_STEP7_OPT2="Disabled"
        T_PROMPT_SELECT="Select option"
        T_DEFAULT="Default"
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

# Function to display step header with clear screen
step_header() {
    local current="$1"
    local total="$2"
    local title="$3"
    clear
    echo -e "${BOLD}${CYAN}"
    echo "----------------------------------------------------------------------"
    echo "  ${T_TITLE}"
    echo "----------------------------------------------------------------------"
    echo -e "${RESET}"
    echo "${T_SUBTITLE}"
    echo -e "${DIM}(Language / Idioma / Langue / Sprache / 语言: ${LANG_CODE})${RESET}"
    echo ""
    echo -e "${BOLD}${MAGENTA}[${current}/${total}] ${title}${RESET}"
}

# --- Step 1: Color Variant ---
step_header 1 7 "${T_STEP1_TITLE}"
echo "${T_STEP1_DESC}"
echo -e "  ${BOLD}1)${RESET} ${CYAN}${T_STEP1_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${YELLOW}${T_STEP1_OPT2}${RESET}"
read -p "${T_PROMPT_SELECT} [1-2, default: 1]: " choice_variant
case "$choice_variant" in
    2) VARIANT="monokai" ;;
    *) VARIANT="night" ;;
esac

# --- Step 2: Capsule Style ---
step_header 2 7 "${T_STEP2_TITLE}"
echo "${T_STEP2_DESC}"
echo -e "  ${BOLD}1)${RESET} ${BLUE}${T_STEP2_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${CYAN}${T_STEP2_OPT2}${RESET}"
echo -e "  ${BOLD}3)${RESET} ${DIM}${T_STEP2_OPT3}${RESET}"
read -p "${T_PROMPT_SELECT} [1-3, default: 1]: " choice_pill
case "$choice_pill" in
    2) PILL_STYLE="bracket" ;;
    3) PILL_STYLE="none" ;;
    *) PILL_STYLE="round" ;;
esac

# --- Step 3: Capsule Color Style (if round) ---
PILL_COLOR_STYLE="solid"
if [ "$PILL_STYLE" = "round" ]; then
    step_header 3 7 "${T_STEP3_TITLE}"
    echo "${T_STEP3_DESC}"
    echo -e "  ${BOLD}1)${RESET} ${GREEN}${T_STEP3_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
    echo -e "  ${BOLD}2)${RESET} ${DIM}${T_STEP3_OPT2}${RESET}"
    read -p "${T_PROMPT_SELECT} [1-2, default: 1]: " choice_color_style
    case "$choice_color_style" in
        2) PILL_COLOR_STYLE="dark" ;;
        *) PILL_COLOR_STYLE="solid" ;;
    esac
fi

# --- Step 4: Prompt Layout ---
step_header 4 7 "${T_STEP4_TITLE}"
echo "${T_STEP4_DESC}"
echo -e "  ${BOLD}1)${RESET} ${CYAN}${T_STEP4_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${BLUE}${T_STEP4_OPT2}${RESET}"
echo -e "  ${BOLD}3)${RESET} ${YELLOW}${T_STEP4_OPT3}${RESET}"
read -p "${T_PROMPT_SELECT} [1-3, default: 1]: " choice_layout
case "$choice_layout" in
    2) PROMPT_LAYOUT="single" ;;
    3) PROMPT_LAYOUT="classic" ;;
    *) PROMPT_LAYOUT="two-line" ;;
esac

# --- Step 5: Developer Icons (Nerd Fonts) ---
step_header 5 7 "${T_STEP5_TITLE}"
echo "${T_STEP5_DESC}"
echo -e "  ${BOLD}1)${RESET} ${GREEN}${T_STEP5_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${DIM}${T_STEP5_OPT2}${RESET}"
read -p "${T_PROMPT_SELECT} [1-2, default: 1]: " choice_nerd
case "$choice_nerd" in
    2) NERD_FONTS="false" ;;
    *) NERD_FONTS="true" ;;
esac

# --- Step 6: Clock Position & Display ---
step_header 6 7 "${T_STEP6_TITLE}"
echo "${T_STEP6_DESC}"
echo -e "  ${BOLD}1)${RESET} ${CYAN}${T_STEP6_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${BLUE}${T_STEP6_OPT2}${RESET}"
echo -e "  ${BOLD}3)${RESET} ${DIM}${T_STEP6_OPT3}${RESET}"
read -p "${T_PROMPT_SELECT} [1-3, default: 1]: " choice_clock
case "$choice_clock" in
    2) SHOW_CLOCK="true"; CLOCK_POS="top" ;;
    3) SHOW_CLOCK="false"; CLOCK_POS="top" ;;
    *) SHOW_CLOCK="true"; CLOCK_POS="rprompt" ;;
esac

# --- Step 7: Clickable Hyperlinks (OSC 8) ---
step_header 7 7 "${T_STEP7_TITLE}"
echo "${T_STEP7_DESC}"
echo -e "  ${BOLD}1)${RESET} ${GREEN}${T_STEP7_OPT1}${RESET} ${GREEN}[${T_DEFAULT}]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${DIM}${T_STEP7_OPT2}${RESET}"
read -p "${T_PROMPT_SELECT} [1-2, default: 1]: " choice_links
case "$choice_links" in
    2) CLICKABLE="false" ;;
    *) CLICKABLE="true" ;;
esac

# --- Summary of Choices ---
clear 2>/dev/null || true
echo -e "${BOLD}${CYAN}"
echo "----------------------------------------------------------------------"
echo "  ${T_TITLE}"
echo "----------------------------------------------------------------------"
echo -e "${RESET}"
echo -e "${BOLD}📋 ${T_SUMMARY}${RESET}"
echo -e "  • ZSH_THEME:                      ${GREEN}${THEME_NAME}${RESET}"
echo -e "  • MODERN_DARK_PRO_VARIANT:        ${YELLOW}${VARIANT}${RESET}"
echo -e "  • MODERN_DARK_PRO_PILL_STYLE:     ${YELLOW}${PILL_STYLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_PILL_COLOR_STYLE: ${YELLOW}${PILL_COLOR_STYLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_PROMPT_LAYOUT:  ${YELLOW}${PROMPT_LAYOUT}${RESET}"
echo -e "  • MODERN_DARK_PRO_NERD_FONTS:     ${YELLOW}${NERD_FONTS}${RESET}"
echo -e "  • MODERN_DARK_PRO_SHOW_CLOCK:     ${YELLOW}${SHOW_CLOCK}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLOCK_POSITION: ${YELLOW}${CLOCK_POS}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLICKABLE_PATH: ${YELLOW}${CLICKABLE}${RESET}"
echo -e "  • MODERN_DARK_PRO_CLICKABLE_GIT:  ${YELLOW}${CLICKABLE}${RESET}"
echo -e "${BOLD}${CYAN}----------------------------------------------------------------------${RESET}"

read -p "${T_APPLY_PROMPT} " choice_confirm
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

# Filter existing theme lines from ~/.zshrc into temp file
cleaned_zshrc=$(mktemp)
TMP_FILES+=("$cleaned_zshrc")
grep -v "^ZSH_THEME=" "$ZSHRC" | grep -v "^export MODERN_DARK_PRO_" | grep -v "^# Modern Dark Pro" "$ZSHRC" > "$cleaned_zshrc" || true

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
    read -p "🔄 ${T_RELOAD_SOURCE_PROMPT} " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${GREEN}${T_APPLYING}${RESET}"
        source "$ZSHRC"
    fi
else
    # Script was executed as a subprocess
    read -p "🔄 ${T_RELOAD_PROMPT} " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${DIM}${T_RELOADING}${RESET}"
        exec zsh
    else
        echo -e "${T_MANUAL_NOTE}"
        echo -e "  ${BOLD}${CYAN}source ~/.zshrc${RESET}"
        echo ""
    fi
fi
