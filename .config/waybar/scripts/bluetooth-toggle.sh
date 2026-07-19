#!/bin/sh

set -eu

state=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ { print $2; exit }')

if [ "${1:-}" = "toggle" ]; then
    if [ "$state" = "yes" ]; then
        bluetoothctl power off >/dev/null 2>&1 || true
        state="no"
    else
        bluetoothctl power on >/dev/null 2>&1 || true
        state="yes"
    fi
fi

if command -v jq >/dev/null 2>&1; then
    if [ "$state" = "yes" ]; then
        jq -nc --arg text "" '{text: $text, class: "on"}'
    else
        jq -nc --arg text "" '{text: $text, class: "off"}'
    fi
else
    if [ "$state" = "yes" ]; then
        printf '{"text":"","class":"on"}\n'
    else
        printf '{"text":"","class":"off"}\n'
    fi
fi