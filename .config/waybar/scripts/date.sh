#!/bin/sh

set -eu

# Sourcing translations
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
    . "$SCRIPT_DIR/i18n.sh"
fi


printf '  %s' "$(date '+%a %d')"
