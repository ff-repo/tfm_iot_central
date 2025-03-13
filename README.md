# Análisis de botnets IoT utilizadas como plataforma SaaS por actores maliciosos

Proyecto para TFM.

## Contenido
API_GATEWAY: código fuente del aplicativo web utilizado por el cliente que ha
rentado una parte de la botnet.

BOT_ADMIN: aplicativo principal empleado para comunicarse con el servidor C&C
y ejecutar operaciones en el dispositivo IoT infectado.

BOT_CLIENT: aplicativo secundario que se despliega cuando el bot es asignado a
un cliente, permitiéndole interactuar con el API Gateway.

FACADE_WEB: aplicación correspondiente a la web fachada implementada para
proveer el código malicioso.

SERVER_C_C: aplicativo administrativo que gestiona las operaciones de comando
y control de la botnet.
