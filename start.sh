#!/bin/bash

[ "$1" = "" ] && echo "Debes indicar una version...4.16 o 4.18" && exit 1
#[ "$1" != "4.17.1" ] && [ "$1" != "4.16" ] && echo "Debes indicar una version...4.16 o 4.17.1" && exit 1
[ "$1" != "4.18" ] && [ "$1" != "4.16" ] && echo "Debes indicar una version...4.16 o 4.18" && exit 1
VERSION="$1"
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
