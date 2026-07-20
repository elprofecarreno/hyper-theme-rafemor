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

PACKAGES="hyprland pavucontrol wireplumber zenity wl-clipboard cliphist grim slurp imv mpv brightnessctl"

# Add font packages
FONT_PACKAGES="ttf-jetbrains-mono-nerd ttf-roboto ttf-roboto-mono"
FONT_PACKAGES="$FONT_PACKAGES ttf-fira-code"
FONT_PACKAGES="$FONT_PACKAGES ttf-fira-mono ttf-fira-sans"
PACKAGES="$PACKAGES $FONT_PACKAGES"

# Add hyprland tools
HYPRLAND_TOOLS="hyprpicker hyprpaper hyprlock"
PACKAGES="$PACKAGES $HYPRLAND_TOOLS"

# Add terminal
TERMINAL="kitty"
PACKAGES="$PACKAGES $TERMINAL"

# Add terminal tools
TERMINAL_TOOLS="btop fastfetch"
PACKAGES="$PACKAGES $TERMINAL_TOOLS"

# Add folder and file management tools
FOLDER_FILE_TOOLS="thunar thunar-archive-plugin"
PACKAGES="$PACKAGES $FOLDER_FILE_TOOLS"

# Add bluetooth tools
BLUETOOTH_TOOLS="blueman"
PACKAGES="$PACKAGES $BLUETOOTH_TOOLS"

# Add bar and notification tools
BAR_NOTIFICATION_TOOLS="waybar dunst rofi"
PACKAGES="$PACKAGES $BAR_NOTIFICATION_TOOLS"

# Add web terminal tools
WEB_TERMINAL_TOOLS="curl wget jq"
PACKAGES="$PACKAGES $WEB_TERMINAL_TOOLS"

# Add compress tools
COMPRESS_TOOLS="zip unzip tar gzip bzip2 xz p7zip unrar"
PACKAGES="$PACKAGES $COMPRESS_TOOLS"

# Add teams packages streaming support
# TEAMS_PACKAGES="xdg-desktop-portal-hyprland xdg-desktop-portal pipewire wireplumber"
# PACKAGES="$PACKAGES $TEAMS_PACKAGES"

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
