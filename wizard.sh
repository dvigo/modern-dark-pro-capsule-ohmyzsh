#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Modern Dark Pro Capsule - Interactive Configuration Wizard
# Interactive setup tool to configure Zsh theme options in ~/.zshrc
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

echo -e "${BOLD}${CYAN}"
echo "----------------------------------------------------------------------"
echo "  🎨 Modern Dark Pro Capsule Theme - Configuration Wizard"
echo "----------------------------------------------------------------------"
echo -e "${RESET}"
echo "Welcome! This wizard will help you configure your terminal prompt style."
echo ""

# Ensure theme file is symlinked to Oh My Zsh custom themes
if [ -d "$ZSH_CUSTOM" ]; then
    mkdir -p "$DEST_DIR"
    if [ ! -e "$DEST_FILE" ]; then
        echo -e "${DIM}🔗 Creating theme symlink at $DEST_FILE...${RESET}"
        ln -sf "${SCRIPT_DIR}/${THEME_FILE}" "$DEST_FILE"
    fi
fi

# Function to display step header
step_header() {
    local current="$1"
    local total="$2"
    local title="$3"
    echo ""
    echo -e "${BOLD}${MAGENTA}[${current}/${total}] ${title}${RESET}"
}

# --- Step 1: Color Variant ---
step_header 1 7 "Color Variant"
echo "Choose your base color scheme:"
echo -e "  ${BOLD}1)${RESET} ${CYAN}Night${RESET} (Soft pastel tones on dark background) ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${YELLOW}Monokai${RESET} (Vibrant classic Monokai colors)"
read -p "Select option [1-2, default: 1]: " choice_variant
case "$choice_variant" in
    2) VARIANT="monokai" ;;
    *) VARIANT="night" ;;
esac

# --- Step 2: Capsule Style ---
step_header 2 7 "Capsule Container Style"
echo "Choose how status segments (directory, git, runtimes) are framed:"
echo -e "  ${BOLD}1)${RESET} ${BLUE}Round${RESET} (Powerline solid rounded pills  pill ) ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${CYAN}Bracket${RESET} (Sleek bracket containers [ pill ])"
echo -e "  ${BOLD}3)${RESET} ${DIM}None${RESET} (Minimalist text without containers)"
read -p "Select option [1-3, default: 1]: " choice_pill
case "$choice_pill" in
    2) PILL_STYLE="bracket" ;;
    3) PILL_STYLE="none" ;;
    *) PILL_STYLE="round" ;;
esac

# --- Step 3: Capsule Color Style (if round) ---
PILL_COLOR_STYLE="solid"
if [ "$PILL_STYLE" = "round" ]; then
    step_header 3 7 "Capsule Color Style"
    echo "Choose coloring for rounded pills:"
    echo -e "  ${BOLD}1)${RESET} ${GREEN}Solid${RESET} (Vibrant segment background with dark readable text) ${GREEN}[Default]${RESET}"
    echo -e "  ${BOLD}2)${RESET} ${DIM}Dark${RESET} (Dark gray #282828 background with colored text)"
    read -p "Select option [1-2, default: 1]: " choice_color_style
    case "$choice_color_style" in
        2) PILL_COLOR_STYLE="dark" ;;
        *) PILL_COLOR_STYLE="solid" ;;
    esac
fi

# --- Step 4: Prompt Layout ---
step_header 4 7 "Prompt Layout"
echo "Choose your prompt line structure:"
echo -e "  ${BOLD}1)${RESET} ${CYAN}Two-Line${RESET} (Line 1: Status capsules + clock, Line 2: Input ❯) ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${BLUE}Single-Line${RESET} (Status capsules + input ❯ on single line)"
echo -e "  ${BOLD}3)${RESET} ${YELLOW}Classic${RESET} (Status capsules with guide connectors ┌─ and └─)"
read -p "Select option [1-3, default: 1]: " choice_layout
case "$choice_layout" in
    2) PROMPT_LAYOUT="single" ;;
    3) PROMPT_LAYOUT="classic" ;;
    *) PROMPT_LAYOUT="two-line" ;;
esac

# --- Step 5: Developer Icons (Nerd Fonts) ---
step_header 5 7 "Developer Icons (Nerd Fonts)"
echo "Do you have a Nerd Font installed and enabled in your terminal?"
echo -e "  ${BOLD}1)${RESET} ${GREEN}Yes${RESET} (Enable icons:  folder,  git,  clock,  lock) ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${DIM}No${RESET} (Use standard Unicode fallback: 📁, ⌥, 🕒, 🔒)"
read -p "Select option [1-2, default: 1]: " choice_nerd
case "$choice_nerd" in
    2) NERD_FONTS="false" ;;
    *) NERD_FONTS="true" ;;
esac

# --- Step 6: Clock Position & Display ---
step_header 6 7 "System Clock Position"
echo "Where would you like the clock (HH:MM:SS) to be placed?"
echo -e "  ${BOLD}1)${RESET} ${CYAN}Right Prompt Line (RPROMPT)${RESET} (Natively aligned to far right margin) ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${BLUE}Top Line Right${RESET} (Space-aligned on top capsule line)"
echo -e "  ${BOLD}3)${RESET} ${DIM}Disabled${RESET} (Hide clock completely)"
read -p "Select option [1-3, default: 1]: " choice_clock
case "$choice_clock" in
    2) SHOW_CLOCK="true"; CLOCK_POS="top" ;;
    3) SHOW_CLOCK="false"; CLOCK_POS="top" ;;
    *) SHOW_CLOCK="true"; CLOCK_POS="rprompt" ;;
esac

# --- Step 7: Clickable Hyperlinks (OSC 8) ---
step_header 7 7 "Clickable Path & Git Links (OSC 8)"
echo "Enable clickable terminal links (Cmd/Ctrl+Click to open folder in Finder/Explorer or Git branch on GitHub)?"
echo -e "  ${BOLD}1)${RESET} ${GREEN}Enabled${RESET} ${GREEN}[Default]${RESET}"
echo -e "  ${BOLD}2)${RESET} ${DIM}Disabled${RESET}"
read -p "Select option [1-2, default: 1]: " choice_links
case "$choice_links" in
    2) CLICKABLE="false" ;;
    *) CLICKABLE="true" ;;
esac

# --- Summary of Choices ---
echo ""
echo -e "${BOLD}${CYAN}----------------------------------------------------------------------${RESET}"
echo -e "${BOLD}📋 Configuration Summary:${RESET}"
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

read -p "Apply these settings to ~/.zshrc? [Y/n] " choice_confirm
if [[ "$choice_confirm" =~ ^[Nn]$ ]]; then
    echo "Configuration cancelled."
    exit 0
fi

# Ensure ~/.zshrc exists
touch "$ZSHRC"

# Backup ~/.zshrc
cp "$ZSHRC" "${ZSHRC}.bak.$(date +%Y%m%d%H%M%S)"
echo -e "${DIM}💾 Backup created at ${ZSHRC}.bak...${RESET}"

# Write config block into a temp file
cfg_file=$(mktemp)
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
grep -v "^ZSH_THEME=" "$ZSHRC" | grep -v "^export MODERN_DARK_PRO_" | grep -v "^# Modern Dark Pro" "$ZSHRC" > "$cleaned_zshrc" || true

tmp_file=$(mktemp)

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
echo -e "${BOLD}${GREEN}✅ Configuration successfully saved to ~/.zshrc!${RESET}"
echo ""

# Ask to apply changes immediately
if [[ "${ZSH_EVAL_CONTEXT:-}" == *"toplevel"* ]] || [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # Script was sourced directly
    read -p "🔄 Would you like to apply the configuration now (source ~/.zshrc)? [Y/n] " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${GREEN}Applying configuration...${RESET}"
        source "$ZSHRC"
    fi
else
    # Script was executed as a subprocess
    read -p "🔄 Would you like to reload your terminal session now (exec zsh)? [Y/n] " choice_reload
    if [[ "$choice_reload" =~ ^[Yy]$ ]] || [[ -z "$choice_reload" ]]; then
        echo -e "${DIM}Reloading terminal session...${RESET}"
        exec zsh
    else
        echo -e "To activate your changes manually in this terminal window, run:"
        echo -e "  ${BOLD}${CYAN}source ~/.zshrc${RESET}"
        echo ""
    fi
fi
