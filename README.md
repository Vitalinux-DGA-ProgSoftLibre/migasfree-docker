# Migasfree Docker DGA

Proporciona el entorno de producción para migasfree en **un host**.
Adaptado de Migasfree-Docker (rama master/desarrollo) https://github.com/migasfree/migasfree-docker/ para:

* Proporcionar configuraciones adicionales del servicio web (alias y configuracions adicionales en server y location).
* Evita la llamada a las variables de entorno.
* Acceso a la BD mediante localhost del equipo anfitrión para test. Se aisla en una red de backend la BD
* Acceso por http y https mediante proxy y generación de certificados con LetsEncrypt

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
Obtener la última versión para el nginx-proxy:
```sh
        curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > migasfree-docker/nginx.tmpl
```
* ***Configurar***:

```sh
        cd migasfree-docker
        cp .env_example .env
        vi .env
```
*Sobre todo deberás definir las variables FQDN, EMAIL y MIGASFREE_VERSION. Para éste último valor consulta siguiente apartado*

## Versionado. 4.15 o desarrollo

El servidor migasfree que se desplegará dependerá de la Versión que indiques en el fichero .env (concretamente con la variable MIGASFREE_VERSION) Si queremos usar la versión estable indicaremos el valor **4.15**. Si queremos la última versión de desarollo:**master**

* Tener en cuenta que si lanzamos el contenedor en versión master se creará o migrará la BD de la aplicación acorde a la versión del servidor, no pudiendo levantar un servidor con la versión 4.15 en un futuro usando la misma BD (datos). Tendríamos que restaurar para ello una copia de respaldo de la BD generada en 4.15 o antes.

## Ejecutar

```sh
        docker-compose up -d
```
¿Dudas sobre qué version de docker-compose usar?

* docker-compose.yml: Si queremos desplegar el servicio mediante http y https con certificado autogenerado por letsencrypt.

* docker-compose_proxy_one_cont.yml: Igual que el anterior pero en este caso nginx-proxy está en un mismo contenedor. Teóricamente algo más inseguro que el anterior...https://github.com/jwilder/nginx-proxy#separate-containers

* docker-compose-simple-version.yml: Despliega el servicio sin proxy http/https, exponiendo el servidor directamente. No será necesario construir las imágenes al obtenerlas del dockerhub

* docker-compose-simple-build.yml: Despliegua el servicio sin proxy http/https y es necesario contruir las imagénes ```docker-compose up --build -d ``` en base a las imágenes del repositorio.

## Prueba

Abre un navegador e indica en la URL el FQDN designado en las  variables de entorno. La primera vez puede demorar algo de tiempo si usas nginx-proxy, al tener que generarse los certificados.

## Settings

* Editar el archivo **/var/lib/migasfree/FQDN/conf/settings.py** para personliazar migasfree-server (http://fun-with-migasfree.readthedocs.org/en/master/part05.html#ajustes-del-servidor-migasfree).
  * Si el contenedor de la base de datos va a estar en la misma máquina que el server se recomienda que el valor de la variable HOST sea 'db' (nombre del contenedor) establecido por defecto
* Se pueden añadir alias (u otras configuración adicionales) al servicio web/nginx desplegado. Para ello tenemos dos opciones:
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_directives.conf** con la configuración que desarmos añadir a nivel de "server" en nginx (ejemplo en server-conf-examples)
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_root_options.conf** con la configuración que desarmos añadir a nivel de "location /" en nginx (ejemplo en server-conf-examples)

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
* frontend -> Directorio con los datos usaos por el proxy. No sería necesario en éste caso guardar los datos.

## Apendice A: Modificar Directorio Raiz Docker /var/lib/docker (Docker Root Dir)

Tras [instalar **docker** en Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/) sus contenedores o imágenes son almacenadas por defecto en **/var/lib/docker**.  En el caso de que queramos modifcar el destino haremos lo siguiente:

1. Comprobamos la ubicación actual del directorio raíz:
```bash
docker info | grep "Docker Root Dir"
Docker Root Dir: /var/lib/docker
```
2. Paramos el servicio **docker** para modificar su configuración, su **Docker Root Dir**, comprobando que realmente esta parado:
```
ps aux | grep -i docker | grep -v grep
sudo systemctl stop docker
ps aux | grep -i docker | grep -v grep
```
3. Creamos el nuevo directorio de destino y el fichero de configuración de **docker** que lo tendrá en cuenta:
```
mkdir /new/docker/root/dir # p.e. mkdir /home/arturo/docker
sudo nano /etc/docker/daemon.json
```
```json
// Contenido de daemon.json
{
  "data-root": "/new/docker/root/dir"
}
```
4. Sincronizamos el antiguo directorio **Docker Root Dir** con su nuevo destino, y volvemos a activar el servicio **docker**:
```
sudo rsync -axPS /var/lib/docker/ /home/arturo/docker
sudo systemctl start docker
```
5. Por último, comprobamos que el serivio vuelve a estar corriendo, que el nuevo directorio **Docker Root Dir** es el que hemos configurado, comprobamos con **docker run hello-world** que todo funciona correctamente y eliminamos los datos antiguos:
```bash
docker info | grep "Docker Root Dir"
Docker Root Dir: /new/docker/root/dir

ps aux | grep -i docker | grep -v grep
docker run hello-world
sudo rm -r /var/lib/docker
```