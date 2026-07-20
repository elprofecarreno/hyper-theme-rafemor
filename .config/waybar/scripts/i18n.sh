#!/bin/sh

# Default language
WAYBAR_LANG="us"

# Load user configuration
CONF_FILE="$HOME/.config/waybar/config.sh"
if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE"
fi

case "$WAYBAR_LANG" in
    "us"|"en")
        # Power Menu
        TXT_LOCK="Lock"
        TXT_SUSPEND="Suspend"
        TXT_HIBERNATE="Hibernate"
        TXT_REBOOT="Reboot"
        TXT_LOGOUT="Log Out"
        TXT_SHUTDOWN="Power Off"
        TXT_POWER_MENU_TITLE="Power"

        # CPU/System Popup
        TXT_CORE="core"
        TXT_RAM="ram"
        TXT_VRAM="vram"
        TXT_NET="net"
        TXT_IP_LOCAL="local ip"

        # Locales for system commands
        if locale -a 2>/dev/null | grep -qi "^en_US"; then
            export LC_TIME=en_US.UTF-8
        else
            export LC_TIME=C
        fi
        ;;
    "es"|*)
        # Power Menu
        TXT_LOCK="Bloquear"
        TXT_SUSPEND="Suspender"
        TXT_HIBERNATE="Hibernar"
        TXT_REBOOT="Reiniciar"
        TXT_LOGOUT="Cerrar Sesión"
        TXT_SHUTDOWN="Apagar"
        TXT_POWER_MENU_TITLE="Apagar"

        # CPU/System Popup
        TXT_CORE="núcleo"
        TXT_RAM="ram"
        TXT_VRAM="vram"
        TXT_NET="red"
        TXT_IP_LOCAL="ip local"

        # Locales for system commands
        if locale -a 2>/dev/null | grep -qi "^es_ES"; then
            export LC_TIME=es_ES.UTF-8
        fi
        ;;
esac
