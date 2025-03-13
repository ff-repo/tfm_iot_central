# Proyecto para TFM de máster en Ciberseguridad

Este repositorio forma parte de un TFM dirigido al desarrollo de una prueba de concepto, resultado de un análisis de Botnets IoT como plataforma SaaS. El objetivo principal es estudiar la viabilidad de implementar un macrosistema utilizando servicios y dispositivos disponibles en el mercado.

La implementación incluye los siguientes componentes:

- 🏰Servidor C&C: Es un aplicativo web que permite administrar toda la botnet. Actúa como la entidad central que coordina los demás componentes, realizando actividades de comando y control con los bots, desplegando otros aplicativos para ser utilizados por los clientes que alquilan segmentos de la botnet, suministrando recursos y operando bajo la supervisión de un botmaster.
- 🤡Web fachada: Es una aplicación web desarrollada en Ruby on Rails, que sirve como fachada para proporcionar los scripts y dependencias necesarias para instalar los programas maliciosos en los dispositivos IoT. Estos recursos son proporcionados por el servidor C&C.
- 🚪API Gateways: Es una aplicación web desarrollada en Ruby on Rails que sirve como interfaz para los usuarios maliciosos que han alquilado un segmento de la botnet para llevar a cabo actividades ilícitas.
- 🤖Bot Admin y Cliente: Son dos aplicaciones desarrolladas en Ruby on Rails, encargadas de ejecutar los comandos enviados por el servidor C&C y los API Gateways a los que están asignados. Estos comandos se ejecutan dentro de los dispositivos IoT.

> Nota: Debido a las restricciones del proyecto, solo se garantiza la ejecución de las aplicaciones Bot Admin y Cliente en dispositivos Raspberry Pi 4. En cuanto a los servicios con los que están integrados, se depende completamente de AWS, Heroku y NameCheap.

>⚠️Disclaimer: This repository is for academic purposes, the use of this software is your responsibility.

>⚠️ Descargo de responsabilidad: Este repositorio tiene fines académicos, y el uso de este software es responsabilidad del usuario.

## Contenido
- API_GATEWAY: Contiene el código de la aplicación API Gateway, para ser usado como interfaz de acceso por los clientes que han rentado una segmento de la botnet.

- BOT_ADMIN: Contiene el código del aplicativo principal a desplegar en el dispositivo IoT. Requiere comunicarse constantemente con el servidor C&C para poder ejecutar operaciones en el dispositivo IoT.

- BOT_CLIENT: Contiene el código del aplicativo secundario que se despliega cuando el bot es asignado a un cliente. Se comunica con una instancia asignada de API Gateway para ejecutar las operaciones indicadas por el cliente que ha rentado una botnet.

- FACADE_WEB: Contiene el código de laaplicación correspondiente a la web fachada para exponer y proveer el contenido malicioso. Requiere de un Servidor C&C para proverle los recursos necesarios, y así poder surtir los aplicaivos BOT_ADMIN y BOT_CLIENT que estan previamente preparados.

- SERVER_C_C: Contiene el código  del aplicativo administrativo que gestiona las operaciones de comando y control toda la botnet.

- TFM Copy.postman_collection.json: Archivo principal con requests pre hechos para interacturar con una instancia de API Gateway, la Web Fachada o el Servidor C&C.

- Prod.postman_environment.json: Archivo con la especificaciones de las variables de entorno requeridas para interacturar con una instancia de API Gateway, la Web Fachada o el Servidor C&C.

## Requisitos Previos

### Heroku

1. Ingresar al enlace de [Heroku](https://www.heroku.com/) y registrarse como un usuario nuevo.
2. Obtener un API Key.

### Namecheap

1. Ingresar al enlace de [Namecheap](https://www.namecheap.com/) y registrarse como un usuario nuevo.
2. Activar la Interfaz API y mantener en la cuenta un saldo de al menos 50$.

![image](https://github.com/user-attachments/assets/92a61a89-96f3-4f6f-8889-90149d59e2a5)

### AWS

1. Ingresar al enlace de [AWS](https://aws.amazon.com/) y registrarse como un usuario nuevo.
2. Crear dos buckets y un usuario con permisos de escritura y lectura al contenido, para su acceso por el uso de librerias SDK.
3. Crear una instancia EC2 y configurar un usuario para que permita conectarse con SSH utilizando un par de llaves privada y pública. Almacenar el .pem en uno de los buckets.
4. Instalar CLI de Heroku en la instancia EC2 e iniciar sesión.

### Raspberry Pi 4

1. Ingresar al enlace de [Raspberry]([https://aws.amazon.com/](https://www.raspberrypi.com/software/)) y descargar Raspberry Pi Imager.
2. Seleccionar Raspberry Pi OS (64 bits). La version empleada es de Kernel version: 6.6 y Debian version 12 (bookworm)
3. Instalar OS en la memoria.

![image](https://github.com/user-attachments/assets/02a73d72-2bf8-4d22-bddf-08c9d96cffe2)


## 📜 License
This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.

You can read the full license [here](https://www.gnu.org/licenses/gpl-3.0.html).

