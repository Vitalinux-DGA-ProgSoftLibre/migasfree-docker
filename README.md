# Migasfree Docker DGA

Proporciona el entorno de producción para migasfree en **un host**.
Adaptado de Migasfree-Docker (rama master/desarrollo) https://github.com/migasfree/migasfree-docker/ para:

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

* ***Descargar docker-compose e imágenes para levantar el entorno***:

```sh
        git clone https://github.com/Vitalinux-DGA-ProgSoftLibre/migasfree-docker.git
```

* ***Configurar***:

```sh
        cd migasfree-docker
        cp .env_example .env
        vi .env
```
## Uso de una versión anterior (4.15 por ejemplo) estable

La configuración actual despliega la versión en desarollo (master) del servidor migasfree. Si queremos usar la versión estable anterior (4.15), antes de construir y lanzar los contenedores deberemos indicar en el archivo migasfree-docker/images/server/VERSION **4.15** en lugar de **master**

* Tener en cuenta que si lanzamos el contenedor en versión master, la BD existente se migrará a dicha versión y no podremos lanzar el contendor con la versión 4.15 en un futuro usando dicha BD. Tendríamos que restaurar para ello una copia de respaldo de la BD generada en 4.15 o antes.

## Ejecutar
Hasta que tengamos una imagen preparada, construiremos la imagen en base a las especificaciones:
```sh
        docker-compose up --build -d
```

## Prueba

Abre un navegador e indica en la URL el FQDN designado en las  variables de entorno

## Settings

* Editar el archivo **/var/lib/migasfree/FQDN/conf/settings.py** para personliazar migasfree-server (http://fun-with-migasfree.readthedocs.org/en/master/part05.html#ajustes-del-servidor-migasfree).
* Se pueden añadir alias (u otras configuración adicional) al servicio web/nginx desplegado. Para ello crea un archivo **/var/lib/migasfree/FQDN/sites-available/aliases.conf** con la configuración deseada

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

