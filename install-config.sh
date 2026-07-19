#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SOURCE_DIR="$SCRIPT_DIR/.config"
TARGET_DIR="$HOME/.config"
HYPR_TARGET_DIR="$TARGET_DIR/hypr"
ASSET_DIRS="images video"
DRY_RUN=false

usage() {
  cat <<'EOF'
Uso:
  ./install-config.sh [--dry-run]

Opciones:
  --dry-run   Muestra qué se copiaría, sin hacer cambios.
  -h, --help  Muestra esta ayuda.

Nota:
  Este script debe ejecutarse con un usuario normal (no root).
EOF
}

refresh_bar() {
  # Refresca Waybar si ya esta corriendo.
  if command -v waybar >/dev/null 2>&1; then
    if pgrep -x waybar >/dev/null 2>&1; then
      echo "Refrescando Waybar..."
      pkill -x waybar || true
      nohup waybar >/dev/null 2>&1 &
    else
      echo "Waybar no esta en ejecucion; no se inicia desde el instalador."
    fi
    return 0
  fi

  # Refresca Polybar si esta corriendo.
  if command -v polybar-msg >/dev/null 2>&1 && pgrep -x polybar >/dev/null 2>&1; then
    echo "Refrescando Polybar..."
    polybar-msg cmd restart >/dev/null 2>&1 || true
    return 0
  fi

  echo "No se detecto una barra en ejecucion para refrescar (Waybar/Polybar)."
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opción no reconocida: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: install-config.sh no debe ejecutarse como root." >&2
  echo "Ejecutalo con tu usuario normal para copiar a su carpeta HOME." >&2
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "No se encontró la carpeta fuente: $SOURCE_DIR" >&2
  exit 1
fi

for asset_dir in $ASSET_DIRS; do
  if [ ! -d "$SCRIPT_DIR/$asset_dir" ]; then
    echo "No se encontró la carpeta asset: $SCRIPT_DIR/$asset_dir" >&2
    exit 1
  fi
done

mkdir -p "$TARGET_DIR"
mkdir -p "$HYPR_TARGET_DIR"

echo "Origen:  $SOURCE_DIR"
echo "Destino: $TARGET_DIR"

if command -v rsync >/dev/null 2>&1; then
  RSYNC_OPTS="-avh"
  if [ "$DRY_RUN" = "true" ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    echo "Modo dry-run activado."
  fi

  # Copia el contenido de .config/ al ~/.config/ sin borrar archivos existentes.
  # shellcheck disable=SC2086
  rsync $RSYNC_OPTS "$SOURCE_DIR/" "$TARGET_DIR/"
else
  if [ "$DRY_RUN" = "true" ]; then
    echo "rsync no está instalado y --dry-run requiere rsync." >&2
    exit 1
  fi

  echo "rsync no está instalado; usando cp -a como alternativa."
  cp -a "$SOURCE_DIR/." "$TARGET_DIR/"
fi

echo "Copia completada."

if command -v rsync >/dev/null 2>&1; then
  for asset_dir in $ASSET_DIRS; do
    if [ "$DRY_RUN" = "true" ]; then
      echo "rsync --dry-run -avh $SCRIPT_DIR/$asset_dir/ $HYPR_TARGET_DIR/$asset_dir/"
      continue
    fi

    rsync -avh "$SCRIPT_DIR/$asset_dir/" "$HYPR_TARGET_DIR/$asset_dir/"
  done
else
  if [ "$DRY_RUN" = "true" ]; then
    echo "Dry-run: no se copian images/video a ~/.config/hypr/."
  else
    for asset_dir in $ASSET_DIRS; do
      cp -a "$SCRIPT_DIR/$asset_dir" "$HYPR_TARGET_DIR/"
    done
  fi
fi

if [ "$DRY_RUN" = "false" ]; then
  refresh_bar
else
  echo "Dry-run: no se refresca la barra."
fi
