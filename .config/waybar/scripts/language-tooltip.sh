#!/bin/sh

set -eu

# Sourcing translations
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
    . "$SCRIPT_DIR/i18n.sh"
fi

# Get current layout name/code from Hyprland
layout_name=$(hyprctl devices -j | jq -r '.keyboards[] | select(.name == "at-translated-set-2-keyboard") | .active_keymap' 2>/dev/null || echo "English (US)")

# Map long name to short layout code
case "$layout_name" in
    "Spanish (Latin American)"*)
        short_code="lat"
        ;;
    "Spanish"*)
        short_code="es"
        ;;
    *)
        short_code="us"
        ;;
esac

# Define tooltip based on language
case "$WAYBAR_LANG" in
    "us"|"en")
        tooltip="Press  + Space to change the language"
        ;;
    "es"|*)
        tooltip="Presiona  + Espacio para cambiar el idioma"
        ;;
esac

# Return json
if command -v jq >/dev/null 2>&1; then
    jq -nc --arg text "$short_code" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
else
    printf '{"text":"%s","tooltip":"%s"}\n' "$short_code" "$tooltip"
fi
