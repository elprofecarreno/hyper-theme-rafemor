#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Uso:
  ./install-dependencies.sh [--noconfirm]

Instala dependencias con pacman para tu entorno Hyprland.

Opciones:
  --noconfirm  Ejecuta pacman sin pedir confirmacion interactiva.
  -h, --help   Muestra esta ayuda.
EOF
}

NO_CONFIRM=false

for arg in "$@"; do
  case "$arg" in
    --noconfirm)
      NO_CONFIRM=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opcion no reconocida: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v pacman >/dev/null 2>&1; then
  echo "Error: pacman no esta disponible en este sistema." >&2
  exit 1
fi

# Nota: el paquete es 'blueman' (incluye el ejecutable blueman-applet).
# Bloqueo: hyprlock para conservar la misma sesion al desbloquear.
# Audio: PipeWire + WirePlumber + compatibilidad PulseAudio + panel pavucontrol.
PACKAGES="waybar dunst hyprpaper rofi thunar kitty blueman hyprlock pavucontrol wireplumber zenity"

if [ "$(id -u)" -eq 0 ]; then
  SUDO_CMD=""
else
  if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD="sudo"
  else
    echo "Error: necesitas ejecutar como root o tener sudo instalado." >&2
    exit 1
  fi
fi

echo "Actualizando base de datos de paquetes..."
if [ "$NO_CONFIRM" = "true" ]; then
  $SUDO_CMD pacman -Sy --noconfirm
else
  $SUDO_CMD pacman -Sy
fi

echo "Instalando paquetes: $PACKAGES"
if [ "$NO_CONFIRM" = "true" ]; then
  $SUDO_CMD pacman -S --needed --noconfirm $PACKAGES
else
  $SUDO_CMD pacman -S --needed $PACKAGES
fi

echo "Instalacion completada."
