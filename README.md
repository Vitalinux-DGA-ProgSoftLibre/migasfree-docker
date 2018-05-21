# Migasfree Docker DGA

Proporciona el entorno de producción para migasfree en **un host**.
Adaptado de Migasfree-Docker (rama master/desarrollo) https://github.com/migasfree/migasfree-docker/ para:

* Proporcionar configuraciones adicionales del servicio web (alias y conf. adicionales den server y location).
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
*Sobre todo deberás definir las variables FQDN y MIGASFREE_VERSION. Para éste último valor consulta siguiente apartado*

## Versionado. 4.15 o desarrollo

El servidor migasfree que se desplegará dependerá de la Versión que indiques en el fichero .env (concretamente con la variable MIGASFREE_VERSION) Si queremos usar la versión estable indicaremos el valor **4.15**. Si queremos la última versión de desarollo:**master**

* Tener en cuenta que si lanzamos el contenedor en versión master se creará o migrará la BD de la aplicación acorde a la versión del servidor, no pudiendo levantar un servidor con la versión 4.15 en un futuro usando la misma BD (datos). Tendríamos que restaurar para ello una copia de respaldo de la BD generada en 4.15 o antes.

## Ejecutar

```sh
        docker-compose up -d
```

## Prueba

Abre un navegador e indica en la URL el FQDN designado en las  variables de entorno

## Settings

* Editar el archivo **/var/lib/migasfree/FQDN/conf/settings.py** para personliazar migasfree-server (http://fun-with-migasfree.readthedocs.org/en/master/part05.html#ajustes-del-servidor-migasfree).
  * Si el contenedor de la base de datos va a estar en la misma máquina que el server se recomienda que el valor de la variable HOST sea 'db' (nombre del contenedor)
* Se pueden añadir alias (u otras configuración adicionales) al servicio web/nginx desplegado. Para ello tenemos dos opciones:
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_directives.conf** con la configuración que desarmos añadir a nivel de "server" en nginx
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_root_options.conf** con la configuración que desarmos añadir a nivel de "location /" en nginx

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

En **/var/lib/migasfree/** se almacenan todos los datos variables y persistentes del proyecto. No olvides hacer las copias de seguridad.

* conf -> Fichero de configuración básica del servidor
* data -> Ficheros de la BD. Se realiza un backup en dump
* keys -> Claves de la comunicación cliente-servidor. Es importante guardar las keys generadas en el servidor y restaurarlas de forma adecuada en un servidor en producción para que los clientes mantengan la consistencia con el servidor. De igual forma se deben guardar con el propietario (890) y permisos adecuados (solo lectura).
* public -> Repositorios y otros recursos compartidos vía web (a través de http://FQDN/public/)