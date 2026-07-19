#!/bin/sh

set -eu

minute=$(date +%M)
second=$(date +%S)
clock_face=$(( (10#$minute + 2) / 5 ))
calendar=$(date '+%Y %B')
week_calendar=$(date '+%B %Y')

case "$clock_face" in
  0|12) icon="🕛" ;;
  1) icon="🕐" ;;
  2) icon="🕑" ;;
  3) icon="🕒" ;;
  4) icon="🕓" ;;
  5) icon="🕔" ;;
  6) icon="🕕" ;;
  7) icon="🕖" ;;
  8) icon="🕗" ;;
  9) icon="🕘" ;;
  10) icon="🕙" ;;
  11) icon="🕚" ;;
  *) icon="🕛" ;;
esac

if command -v jq >/dev/null 2>&1; then
  jq -nc \
    --arg text "$icon  $(date +%H):$minute:$second  📅 $(date '+%a %d')" \
    --arg tooltip "$(cal 2>/dev/null || printf '%s' "$calendar")" \
    '{text: $text, tooltip: $tooltip}'
else
  printf '{"text":"%s  %s:%s:%s  📅 %s","tooltip":"%s"}\n' \
    "$icon" \
    "$(date +%H)" \
    "$minute" \
    "$second" \
    "$(date '+%a %d')" \
    "$(cal 2>/dev/null || printf '%s' "$calendar")"
fi
