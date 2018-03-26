# Migasfree Docker DGA

Proporciona el entorno de producción para migasfree en **un host**.
Adaptado de Migasfree-Docker (versión 4.15) https://github.com/migasfree/migasfree-docker/ para:

* Proporcionar alias adicionales.
* Evitar la llamada a las variables de entorno.
* Acceso a la BD mediante localhost del equipo anfitrión.

## Requerimientos

Al igual que para migasfree-docker:

* ***Un nombre FQDN***: O sino dispones, se puede configurar a través de direccionamienot IP
* ***docker engine instalado***: https://docs.docker.com/engine/installation/
* ***docker-compose instalado***: https://docs.docker.com/compose/install/
* ***haveged instalado***: Migasfree necesita entropía. En Debian:

```sh
       apt-get install haveged
```

## Instalación

* ***Descargar docker-compose***:

```sh
        mkdir mf
        cd mf
        wget https://github.com/Vitalinux-DGA-ProgSoftLibre/migasfree-docker/raw/master/mf/docker-compose.yml
```

* ***Configurar***:

```sh
        cp .env_example .env
        vi .env
```

## Ejecutar

```sh
        docker-compose up -d
```

## Prueba

Abre un navegador e indica en la URL el FQDN designado en las  variables de entorno

## Settings

* Editar el archivo **/var/lib/migasfree/FQDN/conf/settings.py** para personliazar migasfree-server (http://fun-with-migasfree.readthedocs.org/en/master/part05.html#ajustes-del-servidor-migasfree).
* Se pueden añadir alias o configuración adicional al servicio web/nginx desplegado, usando un archivo adicional:
  * Fichero **/var/lib/migasfree/FQDN/sites-available/aliases.conf**

## Backup the Database

Migasfree server makes a dump of the database at POSTGRES_CRON config variable, but running this command will force the dump of the database in **/var/lib/migasfree/FQDN/dump/migasfree.sql** :

```sh
docker exec -ti FQDN-db backup
```

## Restore the DataBase

Copy a dump file in **/var/lib/migasfree/FQDN/dump/migasfree.sql** and run:

```sh
docker exec -ti FQDN-db restore
```

## Respaldo de los datos

En **/var/lib/migasfree/** se almacenan todos los datos variables y persistentes del proyecto.
