#!/bin/bash
# Paramos docker modo simple y borramos enlace simbólico a la BD
docker-compose -f docker-compose-simple-version.yml down
DIRTRABAJO="/var/lib/migasfree/192.168.56.1"
if [ -e "${DIRTRABAJO}" ] && [ -h "${DIRTRABAJO}" ]; then
    sudo rm -f "${DIRTRABAJO}"
fi