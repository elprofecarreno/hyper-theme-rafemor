#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Uso:
  ./install-dependencies.sh [--confirm]

Instala dependencias con pacman para tu entorno Hyprland.

Opciones:
  --confirm    Ejecuta pacman pidiendo confirmacion interactiva.
  -h, --help   Muestra esta ayuda.
EOF
}

NO_CONFIRM=true

for arg in "$@"; do
  case "$arg" in
    --confirm)
      NO_CONFIRM=false
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
PACKAGES="waybar dunst hyprland hyprpaper rofi thunar kitty blueman hyprlock pavucontrol wireplumber zenity ttf-jetbrains-mono-nerd jq"

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

echo "Configurando locales de idioma (en_US, es_ES, es_CL)..."
if [ -f /etc/locale.gen ]; then
  # Descomentar los locales requeridos
  $SUDO_CMD sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  $SUDO_CMD sed -i 's/^#\(es_ES.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  $SUDO_CMD sed -i 's/^#\(es_CL.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  echo "Ejecutando locale-gen..."
  $SUDO_CMD locale-gen
else
  echo "Advertencia: no se encontro /etc/locale.gen." >&2
fi

echo "Configurando distribucion de teclado (us,es,latam) en Hyprland..."
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HYPR_CONF="$SCRIPT_DIR/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
  sed -i 's/kb_layout = .*/kb_layout = us,es,latam/' "$HYPR_CONF"
fi
USER_HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$USER_HYPR_CONF" ]; then
  sed -i 's/kb_layout = .*/kb_layout = us,es,latam/' "$USER_HYPR_CONF"
fi

echo "Instalacion completada."
