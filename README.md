# Hyper Theme

Este repositorio incluye scripts para preparar e instalar tu configuracion.

## Requisitos

Para instalar dependencias con pacman, debes ejecutar `install-dependencies.sh` con permisos de superusuario.

Opciones validas:

- Iniciar sesion como `root` y ejecutar el script.
- Ejecutar el script con `sudo` desde tu usuario normal.

## Instalacion de dependencias

Desde la raiz del proyecto:

```sh
./install-dependencies.sh
```

Sin confirmacion interactiva:

```sh
./install-dependencies.sh --noconfirm
```

## Instalacion de configuracion

Copia los archivos de `.config` a `~/.config`.

Importante: `install-config.sh` debe ejecutarse con usuario comun (no root).

```sh
./install-config.sh
```

Modo simulacion (sin cambios):

```sh
./install-config.sh --dry-run
```
