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
*Sobre todo deberás definir las variables FQDN, EMAIL y MIGASFREE_VERSION en el fichero .env. Para éste último valor consulta siguiente apartado*

## Versionado. 4.16 o desarrollo

El servidor migasfree que se desplegará dependerá de la Versión que indiques en el fichero .env (concretamente con la variable MIGASFREE_VERSION) Si queremos usar la versión estable indicaremos el valor **4.16**. Si queremos la última versión de desarollo:**master**

* Tener en cuenta que si lanzamos el contenedor en versión master se creará o migrará la BD de la aplicación acorde a la versión del servidor, no pudiendo levantar un servidor con la versión 4.16 en un futuro usando la misma BD (datos). Tendríamos que restaurar para ello una copia de respaldo de la BD generada en 4.16 o antes.

## Ejecutar

```sh
        docker-compose up -d
```
En éste caso se lanzará todo la infraestructura en base a la definición descrita en el docker-compose.yml
Si quieres una infraestructura más simple, deberías usar otro fichero de definición de docker-compose.
¿Qué version de docker-compose usar?

* docker-compose.yml: Si queremos desplegar el servicio mediante http y https con certificado autogenerado por letsencrypt.

* docker-compose_proxy_one_cont.yml: Igual que el anterior pero en este caso nginx-proxy está en un mismo contenedor. Teóricamente algo más inseguro que el anterior...https://github.com/jwilder/nginx-proxy#separate-containers

* docker-compose-simple-version.yml: Despliega el servicio sin proxy http/https, exponiendo el servidor directamente. No será necesario construir las imágenes al obtenerlas del dockerhub. **Recomendado para entornos de pruebas**

* docker-compose-simple-build.yml: Despliegua el servicio sin proxy http/https y es necesario contruir las imagénes ```docker-compose up --build -d ``` en base a las imágenes del repositorio.

Recuerda que para lanzar un docker-compose.yml diferente, debes cambiarle el nombre a docker-compose.yml o levantarlo usando:
```sh
        docker-compose -f FICHERO.YML up -d
```

## Prueba

Abre un navegador e indica en la URL el FQDN designado en las  variables de entorno. La primera vez puede demorar algo de tiempo si usas nginx-proxy, al tener que generarse los certificados.

## Settings

* Editar el archivo **/var/lib/migasfree/FQDN/conf/settings.py** para personalizar migasfree-server (http://fun-with-migasfree.readthedocs.org/en/master/part05.html#ajustes-del-servidor-migasfree).
  * Si el contenedor de la base de datos va a estar en la misma máquina que el server se recomienda que el valor de la variable HOST sea 'db' (nombre del contenedor) establecido por defecto
* Se pueden añadir alias (u otras configuración adicionales) al servicio web/nginx desplegado en función de requerimientos extra. Para ello tenemos dos opciones:
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_directives.conf** con la configuración que desarmos añadir a nivel de "server" en nginx (ejemplo en server-conf-examples)
  * Crear un archivo **/var/lib/migasfree/FQDN/sites-available/add_root_options.conf** con la configuración que desarmos añadir a nivel del location raiz "location /" en nginx (ejemplo en server-conf-examples)

## Backup de la Base de Datos

Migasfree server realiza un dump de la base de datos (de forma perdiódica según indicamos en POSTGRES_CRON en el fichero .env), pero podemos realizar dicha copia en cualquier momento, quedando en **/var/lib/migasfree/FQDN/dump/migasfree.sql**

```sh
docker exec -ti FQDN-db backup
```

## Restaurar la Base de Datos

Copiar el fichero dump en **/var/lib/migasfree/FQDN/dump/migasfree.sql** y ejecutar:

```sh
docker exec -ti FQDN-db restore
```

## Respaldo y resturación de los datos
Si queremos restaurar un sistema completo, deberemos copiar (y restaurar cuando proceda) lo siguiente.
En **/var/lib/migasfree/** se almacenan todos los datos variables y persistentes del proyecto.

* conf -> Fichero de configuración básica del servidor
* data -> Ficheros de la BD. Se realiza un backup en dump. No sería necesario al restaurarlo con un fichero dump.
* keys -> Claves de la comunicación cliente-servidor. Es importante guardar las keys generadas en el servidor y restaurarlas de forma adecuada en un servidor en producción para que los clientes mantengan la consistencia con el servidor. De igual forma se deben guardar con el propietario (890) y permisos adecuados (solo lectura).
* public -> Repositorios y otros recursos compartidos vía web (a través de http://FQDN/public/)
* sites-available -> Si hemos creado ficheros add_directives.conf o add_root_options.conf personalizados. migasfree.conf no es necesario ya que lo crea el contenedor al arrancar.
* frontend -> Directorio con los datos usados por el proxy. No sería necesario en éste caso guardar los datos.

## Apendice A: Ajuste de los logs
Por defecto los contenedores no generan gran cantidad de logs, salvo en el caso del proxy inverso (que registra todas las conexiones entrantes)
Se hace necesario "limitar" la cantidad de registros que se almacenan. Para ello podemos editar las directivas establecidas en el docker-compose.yml. En el ejemplo propuesto se guardan en 5 archivos de hasta 200M cada uno. Puede interesarnos ajustar dicha parametrización según nuestro entorno:
```    
    logging:
      driver: "json-file"
      options:
        max-size: "200m"
        max-file: "5"
```

## Apendice B: Personalizar parámetros del contenedor proxy

Si necesitamos personalizar algún parámetro del servidor proxy de cabecera (no confundir con la personalización del nginx interno del server visto en settings), podemos indicarlo creando un archivo personal en el directorio conf.d del contenedor. Ejemplo:

```bash
cat /var/lib/migasfree/${FQDN}/frontend/conf.d/my_options.conf
client_max_body_size 100m;
```

También se podría personalizar no para todos los vhost que gestiona el proxy, sino para algunos concretos:

```bash
cat /var/lib/migasfree/${FQDN}/frontend/vhost.d/migasfree.midominio.com
client_max_body_size 100m;
```

## Apendice C: Modificar Directorio Raiz Docker /var/lib/docker (Docker Root Dir)

Tras [instalar **docker** en Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/) sus contenedores o imágenes son almacenadas por defecto en **/var/lib/docker**.  En el caso de que queramos modifcar el destino haremos lo siguiente:

1. Comprobamos la ubicación actual del directorio raíz:

```bash
docker info | grep "Docker Root Dir"
Docker Root Dir: /var/lib/docker
```

2. Paramos el servicio **docker** para modificar su configuración, su **Docker Root Dir**, comprobando que realmente esta parado:

```bash
ps aux | grep -i docker | grep -v grep
sudo systemctl stop docker
ps aux | grep -i docker | grep -v grep
```

3. Creamos el nuevo directorio de destino y el fichero de configuración de **docker** que lo tendrá en cuenta:

```bash
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

```bash
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

## Apendice D: Bug en 4.16 que se soluciona en versiones posteriores

Hasta actualizar a la versión 4.17.1? (la 4.16 y 17 lo tienen aún) del server, hay un bug con que provoca que ciertos equipos (los AMD Athlon) no se detecten correctamente la mac a la hora de obtener el uuid del equipo.
Mientras no se corrija, y si hubiera que reinicar los contenedores (se destruyen por un down), ojo, que habría que modificar:
En el server, el file:
/usr/local/lib/python2.7/dist-packages/migasfree/server/models/hw_node.py debe modificarse la función get_mac_address:
```python
    @staticmethod
    def get_mac_address(computer_id):
        query = HwNode.objects.filter(
            computer=computer_id
        ).filter(
            Q(
                name__icontains='network',
                class_name='network'
            ) | Q(
                name__icontains='bridge', 
                class_name='bridge'
            )
        )
        lst = []
        for iface in query:
            if validate_mac(iface.serial):
                lst.append(iface.serial.upper().replace(':', ''))

        return ''.join(lst)
```