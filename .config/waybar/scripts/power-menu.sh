#!/bin/sh

set -eu

# If rofi is running, kill it and exit
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

LOCK_FILE="/tmp/rofi_power_menu.lock"
current_time=$(date +%s%3N)

if [ -f "$LOCK_FILE" ]; then
    last_time=$(cat "$LOCK_FILE")
    time_diff=$((current_time - last_time))
    # If it was closed less than 400ms ago, don't open it again (debounce click-through)
    if [ "$time_diff"
    
    
    
     
      
       
        
         
           -lt 400 ]; then
        rm -f "$LOCK_FILE"
        exit 0
    fi
fi

# Launch rofi
action=$(echo -e 'Bloquear\nSuspender\nHibernar\nReiniciar\nCerrar Sesión\nApagar' | \
rofi -dmenu -p 'Apagar' -location 3 -xoffset -10 -yoffset 45 \
  -hover-select \
  -me-select-entry '' -me-accept-entry '!MousePrimary' -kb-cancel 'MousePrimary' \
  -theme-str 'window { width: 200px; border: 1px; border-color: rgba(255, 255, 255, 0.14); border-radius: 12px; background-color: rgba(17, 17, 27, 0.96); text-color: #cdd6f4; font: "JetBrainsMono Nerd Font 11"; } mainbox { children: [ listview ]; background-color: transparent; } listview { lines: 6; background-color: transparent; scrollbar: false; padding: 8px; } element { padding: 8px 12px; background-color: transparent; text-color: #cdd6f4; border-radius: 6px; } element normal.normal { background-color: transparent; text-color: #cdd6f4; } element alternate.normal { background-color: transparent; text-color: #cdd6f4; } element selected.normal { background-color: #7aa2f7; text-color: #1a1b26; } element-text { background-color: transparent; text-color: inherit; }')

# Save close time immediately after rofi exits
date +%s%3N > "$LOCK_FILE"

# Execute action
case "$action" in
    "Bloquear") hyprlock ;;
    "Suspender") systemctl suspend ;;
    "Hibernar") systemctl hibernate ;;
    "Reiniciar") systemctl reboot ;;
    "Cerrar Sesión") hyprctl dispatch exit ;;
    "Apagar") systemctl poweroff ;;
esac
