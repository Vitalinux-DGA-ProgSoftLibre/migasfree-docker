#!/bin/bash

if [ "$1" = "" ]; then
    echo "Usando versión 4.18 por defecto..."
    VERSION="4.18";
    elif [ "$1" = "4.18" ] || [ "$1" = "4.19" ]; then
    VERSION="$1"
else
    echo "No entiendo...ejecuta ./start  [version]"
    exit 1
fi

[ ! -f ".env" ] && echo "No existe el archivo .env...salimos" && exit 1
sed  -i "s/^MIGASFREE_VERSION=.*/MIGASFREE_VERSION=${VERSION}/" .env

DIRTRABAJO="/var/lib/migasfree/192.168.56.1"
if [ -e "${DIRTRABAJO}" ] && [ -h "${DIRTRABAJO}" ]; then
    sudo rm -f "${DIRTRABAJO}"
    elif [ -e "${DIRTRABAJO}" ]; then
    echo "El directorio de trabajo existe pero no es un enlace...revisa que ocurre"
    exit 1
fi
[ ! -d "${DIRTRABAJO}_${VERSION}_data" ] && echo "El directorio de trabajo ${DIRTRABAJO}_${VERSION}_data NO existe....revisa" && exit 1
# Creamos el enlace simbólico
sudo ln -s "${DIRTRABAJO}_${VERSION}_data" "${DIRTRABAJO}"
# Forzamos que se escriba en disco....parece que si va muy rápido el docker crea antes las estructuras y se lia la cosa pero bien...
sync && sleep 1
# Lanzamos docker modo simple
docker-compose -f docker-compose-simple-version.yml up -d
docker-compose logs -f
