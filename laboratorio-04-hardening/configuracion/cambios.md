# LAB-04 — Cambios y propuestas de hardening

## Actividad 14 — Diseño de política de firewall

### Objetivo

Diseñar una política de firewall que limite el acceso de red al servidor PostgreSQL, utilizando el principio de mínimo privilegio y permitiendo únicamente los orígenes necesarios.

### Escenario propuesto

La guía establece el siguiente escenario ficticio:

- **Servidor PostgreSQL:** 10.10.10.20
- **Puerto:** 5432/TCP
- **Red DBA autorizada:** 10.10.10.0/24
- **Otros orígenes:** No autorizados

Estas direcciones corresponden al ejercicio académico y no representan la configuración real de nuestro equipo.

### Matriz de reglas de firewall

| Origen | Destino | Puerto | Protocolo | Acción |
|---|---|---|---|---|
| 10.10.10.0/24 | 10.10.10.20 | 5432 | TCP | Permitir |
| Cualquier otro origen | 10.10.10.20 | 5432 | TCP | Denegar |

La política permite solamente las conexiones provenientes de la red administrativa autorizada y rechaza los intentos desde otras redes hacia el puerto PostgreSQL.

Para que resulte efectiva, debe implementarse en el punto adecuado de la red y verificarse que otras reglas no permitan el mismo tráfico de forma más amplia.

### ¿Por qué pg_hba.conf y el firewall no son controles equivalentes?

El firewall controla el tráfico de red que puede alcanzar al servidor, aplicando restricciones sobre direcciones, puertos y protocolos.

Por su parte, `pg_hba.conf` determina qué conexiones puede autenticar PostgreSQL, considerando el tipo de conexión, la base de datos, el usuario, la dirección de origen y el método de autenticación.

Ambos mecanismos se complementan, pero actúan en niveles diferentes.

Una política de firewall restrictiva reduce la exposición del servicio. Las reglas de `pg_hba.conf` permiten establecer condiciones específicas para el acceso a PostgreSQL.

En consecuencia, no debe considerarse que la configuración de uno sustituye automáticamente la necesidad del otro.

### Relación con nuestro laboratorio en Windows

Durante la Actividad 13 se comprobó que PostgreSQL escucha en las siguientes interfaces:

| Elemento | Valor verificado |
|---|---|
| IPv4 | 127.0.0.1 |
| IPv6 | ::1 |
| Puerto | 5432 |
| Proceso | postgres |
| PID observado | 4268 |

La prueba `Test-NetConnection 127.0.0.1 -Port 5432` devolvió `TcpTestSucceeded : True`.

Estas evidencias demuestran que el servicio está disponible desde el equipo local.

Además, anteriormente se verificó que el parámetro `listen_addresses` contiene `localhost`, por lo que PostgreSQL no está configurado para escuchar directamente en interfaces externas.

Para este entorno académico no se requiere habilitar conexiones remotas.

### Decisión de hardening

Se decidió conservar la configuración local actual porque responde a las necesidades del laboratorio y evita ampliar innecesariamente la superficie de exposición.

No se creó ninguna regla de firewall ni se modificaron los parámetros de red.

La política para la dirección 10.10.10.20 se presenta únicamente como propuesta conceptual.

### Evidencias

- `../evidencias/04g-exposicion-red.png`
- `../evidencias/04h-conectividad-local.png`

### Conclusión

El firewall y `pg_hba.conf` proporcionan controles complementarios que ayudan a proteger la disponibilidad y el acceso autorizado al servidor PostgreSQL.

Una configuración segura debe limitar las direcciones permitidas y establecer condiciones específicas de autenticación, evitando que el servicio permanezca expuesto a redes innecesarias.

**Estado:** diseño conceptual completado. No se realizaron cambios reales al firewall de Windows.








---

## Actividad 16 — Comparación de configuración inicial y final

### Objetivo

Comparar el estado inicial de PostgreSQL 16 con la configuración
verificada después de las actividades de hardening, documentando
los controles existentes, las decisiones adoptadas y las mejoras
que todavía requieren implementación.

### Entorno

- Motor: PostgreSQL 16.15
- Sistema operativo: Windows
- Base de datos: db_unidad02_carlos_romero
- Servicio: postgresql-x64-16
- Puerto: 5432
- Modalidad: Laboratorio local

### Matriz comparativa

| Control | Antes | Después | Justificación |
|---|---|---|---|
| `listen_addresses` | `localhost` | `localhost` — sin cambios | La configuración existente restringe la escucha a interfaces locales. No se requieren conexiones remotas. |
| `pg_hba.conf` | 6 reglas locales con SCRAM-SHA-256 | Mismas 6 reglas — sin cambios | No se encontraron reglas `trust` ni accesos desde `0.0.0.0/0` o `::/0`. Se diseñaron restricciones adicionales como propuesta. |
| Método de autenticación | `scram-sha-256` | `scram-sha-256` — sin cambios | Es el método configurado para almacenar nuevas contraseñas. |
| Usuarios administrativos | `postgres` con SUPERUSER | Sin cambios | Se identificaron sus privilegios y se recomendó reservarlo para administración. |
| Cuentas de aplicación | No se identificaron cuentas de aplicación independientes | Sin cambios; separación propuesta | Se diseñaron conceptualmente `app_lab04` y `consulta_lab04`, pero no se crearon. |
| Puerto | `5432` | `5432` — sin cambios | El puerto está documentado y escucha únicamente en las interfaces locales verificadas. |
| TLS | SSL habilitado, mínimo TLS 1.2 | Sin cambios; conexión TLS 1.3 verificada | La conexión de pgAdmin utiliza TLS 1.3, según la consulta a `pg_stat_ssl`. |
| Permisos del sistema operativo | Permisos NTFS con acceso de administradores, SYSTEM, cuenta local y NetworkService | Sin cambios; permisos revisados | Se identificaron propietarios y permisos. Es necesario evaluar el mínimo privilegio antes de modificar las ACL. |
| Extensiones | `pgcrypto` 1.3 y `plpgsql` 1.0 | Sin cambios | Ambas extensiones fueron identificadas y se decidió conservarlas para no afectar funcionalidades existentes. |
| Conexiones | Máximo 100; 3 reservadas a superusuarios; tiempos de espera generales desactivados | Sin cambios; riesgos documentados | Se verificaron los límites y se identificó la necesidad de evaluar tiempos de espera según las aplicaciones. |

### Controles adicionales verificados

**Exposición de red**

Se comprobó mediante PowerShell que PostgreSQL escucha en
127.0.0.1 y ::1, utilizando el puerto 5432.

La prueba de conectividad local devolvió:

`TcpTestSucceeded : True`

No se observaron sockets de escucha del proceso PostgreSQL
en interfaces externas.

**Registros de conexiones**

La inspección inicial mostró:

- logging_collector = on
- log_connections = off
- log_disconnections = off
- log_destination = stderr

Estos valores no se modificaron durante el laboratorio.

Se recomienda evaluar la activación de registros de conexión
y desconexión conforme a una política de auditoría.

**Tiempos de espera**

La revisión mostró:

- max_connections = 100
- superuser_reserved_connections = 3
- statement_timeout = 0
- idle_in_transaction_session_timeout = 0

Los valores cero indican que los límites generales
correspondientes están desactivados.

Se recomienda evaluar tiempos de espera apropiados
para las cuentas de aplicación, sin afectar las tareas
administrativas o consultas de larga duración justificadas.

### Cambios reales realizados durante LAB-04

No se realizaron cambios sobre la configuración activa
de PostgreSQL, las reglas de autenticación, los certificados,
los roles existentes, las ACL de Windows o el firewall.

Los controles que ya cumplían con las necesidades del entorno
académico fueron conservados.

Las actividades de diseño se documentaron como propuestas,
sin presentarlas como configuraciones implementadas.

### Mejoras pendientes de evaluación

1. Establecer cuentas de aplicación independientes.
2. Revisar la necesidad de activar registros de conexiones.
3. Definir tiempos de espera por rol o aplicación.
4. Revisar los permisos NTFS bajo el principio de mínimo privilegio.
5. Establecer una política de actualización y revisión periódica.
6. Evaluar reglas `hostssl` cuando se necesite exigir TLS.
7. Comprobar las opciones de validación del certificado utilizadas
   por los clientes.

Estas mejoras requieren evaluación, respaldo y pruebas
antes de aplicarse a la configuración activa.

### Evidencias relacionadas

- `../evidencias/01-superficie-ataque.png`
- `../evidencias/02-listen-addresses.png`
- `../evidencias/03-pg-hba.png`
- `../evidencias/03b-autenticacion.png`
- `../evidencias/04-roles.png`
- `../evidencias/04c-extensiones.png`
- `../evidencias/04d-conexiones-timeouts.png`
- `../evidencias/04e-permisos-archivos.png`
- `../evidencias/04g-exposicion-red.png`
- `../evidencias/05a-configuracion-tls.png`
- `../evidencias/05-tls.png`

### Conclusión

La comparación demuestra que PostgreSQL 16 ya contaba
con medidas de seguridad importantes antes del LAB-04,
entre ellas la restricción de interfaces locales,
autenticación SCRAM-SHA-256 y TLS.

Las actividades permitieron comprobar esos controles,
identificar riesgos pendientes y justificar decisiones.

El hardening no requiere modificar parámetros que ya
son adecuados para la finalidad del sistema.

Sin embargo, la evaluación también identificó áreas
de mejora que podrían implementarse posteriormente
mediante un procedimiento controlado.





---

## Actividad 18 — Caso integral de hardening

### Objetivo

Analizar un escenario de PostgreSQL con configuraciones de
seguridad excesivamente permisivas, identificando los riesgos
existentes y proponiendo controles correctivos basados en
autenticación, autorización, protección de red, configuración
segura, sistema operativo y monitoreo.

### 1. Descripción del escenario

Una empresa utiliza PostgreSQL para almacenar información
de una aplicación web.

El servidor presenta las siguientes condiciones:

- PostgreSQL escucha en todas las interfaces de red.
- Se aceptan conexiones desde cualquier dirección IPv4.
- El firewall permite el puerto TCP 5432 desde cualquier origen.
- El archivo pg_hba.conf utiliza una regla que permite
  all/all desde 0.0.0.0/0.
- La aplicación web utiliza una cuenta con privilegios
  administrativos.
- El administrador considera que las contraseñas fuertes
  son suficientes para proteger el sistema.

Estas condiciones generan una superficie de ataque
innecesariamente amplia y aumentan el impacto potencial
de un acceso no autorizado.

### 2. Matriz de problemas, riesgos y controles propuestos

| N.º | Problema identificado | Riesgo | Control propuesto |
|---|---|---|---|
| 1 | PostgreSQL escucha en todas las interfaces de red. | El servicio queda disponible a través de interfaces que podrían no ser necesarias. | Configurar `listen_addresses` únicamente con las interfaces autorizadas. |
| 2 | El servidor acepta conexiones desde cualquier dirección IPv4 alcanzable. | Aumentan los orígenes desde los que se pueden intentar conexiones no autorizadas. | Restringir el acceso a direcciones o redes específicas. |
| 3 | El firewall permite conexiones al puerto 5432 desde cualquier origen. | Se amplía la exposición del servicio y la posibilidad de recibir tráfico malicioso. | Crear reglas que permitan exclusivamente las redes o equipos autorizados. |
| 4 | La regla de `pg_hba.conf` utiliza `0.0.0.0/0`. | PostgreSQL no limita las direcciones IPv4 desde las que puede intentarse la autenticación. | Sustituir la regla amplia por reglas específicas para los orígenes necesarios. |
| 5 | `pg_hba.conf` permite `all` para todas las bases de datos. | Una misma regla de autenticación abarca bases de datos con diferentes funciones y necesidades. | Definir reglas específicas por base de datos. |
| 6 | `pg_hba.conf` permite `all` para todos los usuarios. | No existe una diferenciación adecuada de usuarios por origen o finalidad en esa regla. | Restringir las reglas a roles de conexión autorizados. |
| 7 | La aplicación web utiliza una cuenta administrativa. | Una vulnerabilidad en la aplicación podría facilitar operaciones privilegiadas sobre PostgreSQL. | Crear una cuenta de aplicación independiente, sin privilegios administrativos. |
| 8 | La cuenta de la aplicación tiene privilegios superiores a los necesarios. | Un error, inyección SQL o compromiso de credenciales podría afectar tablas y otros recursos no relacionados con la aplicación. | Aplicar mínimo privilegio mediante GRANT, REVOKE y roles específicos. |
| 9 | No existe separación efectiva entre el acceso administrativo y el acceso ordinario de la aplicación. | Se dificulta limitar el impacto de incidentes y establecer responsabilidades diferenciadas. | Separar cuentas DBA, APP y CONSULTA con funciones claramente definidas. |
| 10 | La protección depende principalmente de contraseñas fuertes. | Si una credencial es robada o una aplicación es comprometida, las demás configuraciones permisivas incrementan las consecuencias. | Aplicar defensa en profundidad combinando autenticación, autorización, red y monitoreo. |
| 11 | La configuración de red es excesivamente amplia para una aplicación que podría necesitar solamente un conjunto limitado de orígenes. | Se incrementa la superficie de ataque y se dificulta controlar qué sistemas alcanzan el servidor. | Aplicar segmentación de red y listas de orígenes autorizados. |
| 12 | Las configuraciones permisivas no están justificadas mediante necesidades específicas del escenario. | Pueden mantenerse accesos innecesarios y resultar difícil demostrar que las restricciones son apropiadas. | Crear una línea base de seguridad, revisar periódicamente las reglas y documentar las excepciones autorizadas. |

### 3. Análisis de los principales problemas

#### 3.1 Exposición innecesaria de red

El servidor escucha en todas sus interfaces y recibe
tráfico hacia PostgreSQL desde cualquier origen permitido
por la conectividad disponible.

Esta situación incrementa la superficie de ataque.

La solución consiste en identificar qué aplicaciones
y equipos necesitan acceder al servidor y limitar
las interfaces y redes autorizadas.

Para un entorno local, utilizar localhost puede ser
suficiente. Para un entorno empresarial podrían
autorizarse redes privadas específicas.

#### 3.2 Reglas de autenticación demasiado amplias

La configuración de pg_hba.conf permite cualquier
usuario y base de datos desde cualquier dirección IPv4.

Aunque exista un método de autenticación mediante
contraseña, la regla no establece restricciones
específicas por usuario, base de datos u origen.

Se recomienda utilizar reglas más específicas,
considerando las necesidades reales de cada aplicación.

También debe revisarse el orden de las reglas, ya que
PostgreSQL aplica la primera regla coincidente.

#### 3.3 Uso de cuentas administrativas

La aplicación utiliza una cuenta con privilegios
administrativos.

Este es uno de los problemas más graves del escenario,
porque una vulnerabilidad de la aplicación podría
permitir operaciones que no forman parte de su función.

Por ejemplo, una inyección SQL podría tener
consecuencias mucho mayores cuando se ejecuta
mediante un usuario con privilegios elevados.

Se recomienda crear cuentas de aplicación
independientes y conceder únicamente los permisos
estrictamente necesarios.

#### 3.4 Dependencia excesiva de contraseñas fuertes

Las contraseñas fuertes son importantes, pero
no eliminan las vulnerabilidades de la aplicación
ni compensan los privilegios excesivos.

Incluso una contraseña compleja puede verse
comprometida mediante errores de configuración,
exposición de credenciales o vulnerabilidades
de otros componentes.

La seguridad debe apoyarse en múltiples controles.

### 4. ¿Es suficiente tener contraseñas fuertes?

No. Las contraseñas fuertes ayudan a proteger
la autenticación, pero no garantizan por sí solas
la seguridad de una base de datos.

Se requiere combinar diferentes niveles de protección.

**Autenticación**

Permite verificar la identidad del usuario que intenta
conectarse. Deben emplearse mecanismos adecuados,
como SCRAM-SHA-256, y una gestión segura de credenciales.

**Autorización**

Determina las acciones que puede ejecutar un usuario
después de autenticarse. Los privilegios deben limitarse
según las necesidades reales de cada función.

**Red**

Se deben restringir las interfaces de escucha,
los puertos y las redes autorizadas mediante
controles como listen_addresses y firewall.

**Configuración**

Es necesario revisar los parámetros de PostgreSQL,
las reglas de pg_hba.conf, los componentes habilitados
y las medidas de protección de las conexiones.

**Sistema operativo**

Los archivos de configuración, certificados,
claves privadas y directorio de datos deben contar
con permisos adecuados para evitar accesos
o modificaciones no autorizadas.

**Monitoreo**

Es importante disponer de registros y mecanismos
de supervisión que permitan identificar intentos
de acceso, errores de autenticación, cambios
administrativos y eventos relevantes.

### 5. Plan de corrección propuesto

#### Prioridad alta

1. Revisar y restringir las interfaces de escucha.
2. Limitar las conexiones mediante reglas de firewall.
3. Sustituir las reglas excesivamente amplias
   de pg_hba.conf.
4. Retirar los privilegios administrativos
   de la cuenta utilizada por la aplicación.
5. Probar las conexiones autorizadas antes
   de aplicar definitivamente los cambios.

#### Prioridad media

1. Revisar todos los roles y sus privilegios.
2. Separar las cuentas administrativas
   de las cuentas de aplicación.
3. Verificar que las conexiones utilicen
   mecanismos de cifrado apropiados.
4. Revisar los permisos de los archivos
   sensibles del sistema operativo.

#### Mantenimiento continuo

1. Establecer una línea base documentada.
2. Definir políticas de actualización.
3. Revisar periódicamente las reglas de acceso.
4. Implementar controles de monitoreo y auditoría.
5. Conservar evidencias de verificación.

### 6. Relación con nuestro laboratorio

El escenario descrito es hipotético y no corresponde
a la configuración real de nuestro PostgreSQL 16.

Durante el LAB-04 se comprobó que nuestro servidor:

- Utiliza listen_addresses = localhost.
- Escucha en 127.0.0.1 y ::1.
- Emplea el puerto 5432.
- Tiene reglas locales con SCRAM-SHA-256.
- No presenta reglas de autenticación
  abiertas a 0.0.0.0/0 o ::/0.
- Mantiene TLS habilitado.
- Utiliza TLS 1.3 en la conexión verificada.
- Conserva el rol analista sin privilegios
  administrativos y sin capacidad de LOGIN.

También se identificaron aspectos que merecen
evaluación adicional:

- Separación de cuentas de aplicación.
- Permisos NTFS.
- Registros de conexión y desconexión.
- Tiempos de espera.
- Validación de certificados.
- Políticas de actualización.

Estos aspectos se encuentran documentados
en el checklist y en la comparación de
configuración del laboratorio.

### 7. Conclusión

El escenario demuestra que una base de datos puede
tener contraseñas fuertes y continuar expuesta a
riesgos importantes.

Los privilegios excesivos, las reglas amplias
de autenticación y la exposición innecesaria
del puerto PostgreSQL incrementan tanto
la probabilidad como el impacto de un incidente.

El hardening requiere una estrategia integral
que combine protección de red, autenticación,
autorización, configuración, seguridad del
sistema operativo y monitoreo.

La finalidad es reducir la superficie de ataque
sin impedir las operaciones legítimas.

**Estado:** evaluación conceptual completada.
No se realizaron modificaciones al servidor.
