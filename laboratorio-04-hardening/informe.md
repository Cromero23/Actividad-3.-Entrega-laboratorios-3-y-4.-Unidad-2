# LAB-04 — Informe de hardening y configuración segura de PostgreSQL

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Unidad:** II — Seguridad, privacidad y control de acceso  
**Tema:** Hardening de servidores de bases de datos  
**Estudiante:** Carlos Romero  
**Motor:** PostgreSQL 16.15  
**Sistema operativo:** Windows  
**Herramientas:** pgAdmin 4, PowerShell y Visual Studio Code  
**Base de datos:** `db_unidad02_carlos_romero`

---

## 1. Introducción

El hardening consiste en fortalecer la seguridad de un sistema mediante la reducción de su superficie de ataque, la restricción de accesos innecesarios y el establecimiento de configuraciones adecuadas para su funcionamiento.

Durante este laboratorio se examinó la instalación local de PostgreSQL 16.15, con el objetivo de identificar sus principales configuraciones de seguridad, evaluar posibles riesgos y establecer una línea base documentada.

Se realizaron consultas SQL y comprobaciones mediante PowerShell para revisar interfaces de red, autenticación, privilegios, extensiones, permisos del sistema operativo, parámetros de conexión y mecanismos de cifrado.

También se elaboraron propuestas de mejora relacionadas con políticas de firewall, cuentas de aplicación, auditoría, mantenimiento y mínimo privilegio.

El trabajo se desarrolló sobre un entorno académico local, utilizando la configuración existente de los laboratorios anteriores.

## 2. Objetivo

Evaluar la configuración de seguridad de PostgreSQL 16 mediante un proceso de inspección, análisis y verificación, identificando los controles existentes, los riesgos pendientes y las medidas necesarias para establecer una línea base de hardening.

## 3. Entorno de trabajo

| Elemento | Configuración comprobada |
|---|---|
| PostgreSQL | 16.15 |
| Puerto | 5432 |
| Interfaces de escucha | localhost |
| Autenticación configurada | SCRAM-SHA-256 |
| SSL habilitado | Sí |
| TLS mínimo | TLS 1.2 |
| TLS de la sesión comprobada | TLS 1.3 |
| Servicio Windows | postgresql-x64-16 |
| Cuenta del servicio | NT AUTHORITY\NetworkService |
| Conexión de administración | pgAdmin 4 |

## 4. Resultados de la inspección

### Superficie de ataque

La inspección inicial permitió identificar el puerto, las interfaces, las conexiones existentes y los archivos principales de configuración.

PostgreSQL estaba configurado para escuchar únicamente en `localhost`.

Mediante PowerShell se comprobó que el proceso `postgres` escuchaba en `127.0.0.1` y `::1`, utilizando el puerto 5432.

Esto limita el acceso TCP directo al equipo local.

### Reglas de autenticación

Se identificaron seis reglas en `pg_hba.conf`, todas con autenticación SCRAM-SHA-256.

No se encontraron reglas `trust`, orígenes globales IPv4 o IPv6 ni errores de análisis.

### Roles y privilegios

Se identificaron 16 roles, incluidos los predefinidos de PostgreSQL.

Entre los roles no predefinidos se encontraron `postgres`, con privilegios administrativos, y `analista`, sin capacidad de inicio de sesión ni privilegios de superusuario.

También se verificó que `analista` dispone de lectura sobre la vista autorizada del LAB-03 y no tiene acceso directo a la tabla original de clientes.

### Cifrado

Se comprobó que SSL se encuentra habilitado y que la versión mínima permitida es TLS 1.2.

La conexión utilizada en pgAdmin negoció TLS 1.3.

Esta verificación demuestra el cifrado de la sesión analizada, pero no que todos los clientes estén obligados a utilizar TLS ni que validen siempre el certificado del servidor.

### Parámetros de disponibilidad y auditoría

Se encontraron los siguientes valores:

| Parámetro | Valor |
|---|---|
| `max_connections` | 100 |
| `superuser_reserved_connections` | 3 |
| `statement_timeout` | 0 ms |
| `idle_in_transaction_session_timeout` | 0 ms |
| `logging_collector` | on |
| `log_connections` | off |
| `log_disconnections` | off |

Estos resultados permitieron identificar oportunidades de mejora relacionadas con trazabilidad y control de recursos.

## 5. Preguntas del informe

### 1. ¿Cuál era la principal superficie de ataque?

La principal superficie de ataque analizada estuvo relacionada con las conexiones al servidor PostgreSQL, especialmente el puerto TCP 5432, las interfaces de escucha, las reglas de autenticación y las cuentas que pueden acceder a las bases de datos.

También se consideraron los archivos de configuración, las extensiones y los permisos del sistema operativo.

En nuestro entorno se comprobó que PostgreSQL escucha únicamente en las interfaces locales, por lo que la exposición de red ya estaba restringida antes de iniciar el LAB-04.

La revisión permitió demostrar que una base de datos debe protegerse tanto desde PostgreSQL como desde la red y el sistema operativo.

### 2. ¿Qué configuración representaba el mayor riesgo?

Entre las configuraciones reales observadas, las principales oportunidades de mejora fueron la ausencia de límites generales para determinadas sesiones inactivas, los registros de conexión desactivados y la necesidad de revisar algunos permisos NTFS.

Estos aspectos pueden dificultar la detección de eventos o permitir situaciones que afecten la disponibilidad.

No se identificó una regla de autenticación abierta a cualquier dirección ni una interfaz TCP externa de escucha.

En el escenario hipotético de la guía, la mayor exposición estaría relacionada con combinar `listen_addresses = '*'`, una regla `0.0.0.0/0`, un firewall permisivo y una aplicación que utiliza privilegios administrativos.

Esa combinación incrementaría considerablemente los riesgos de acceso no autorizado y ampliaría el impacto de posibles vulnerabilidades.

### 3. ¿Qué cambio produjo la mayor reducción de exposición?

Durante el LAB-04 no fue necesario modificar las interfaces de escucha ni las reglas de autenticación porque la configuración del servidor ya se encontraba restringida al equipo local.

Por lo tanto, no sería correcto afirmar que realizamos un cambio que produjo una reducción nueva de exposición.

El control preexistente más importante fue `listen_addresses = 'localhost'`, acompañado de reglas locales en `pg_hba.conf`.

Si un servidor estuviera escuchando innecesariamente en todas las interfaces, restringirlo únicamente a las interfaces autorizadas podría representar una de las medidas más importantes para disminuir su exposición.

Sin embargo, antes de aplicar ese cambio en producción sería necesario identificar las aplicaciones dependientes, evaluar el impacto, preparar respaldos y verificar la continuidad del servicio.

### 4. ¿Qué diferencia existe entre firewall y `pg_hba.conf`?

El firewall controla el tráfico de red que puede llegar al servidor mediante condiciones relacionadas con direcciones, puertos, protocolos y reglas de comunicación.

En cambio, `pg_hba.conf` determina qué conexiones puede autenticar PostgreSQL, considerando la base de datos, el usuario, el tipo de conexión, la dirección de origen y el método de autenticación.

Por ejemplo, el firewall puede permitir el acceso al puerto 5432 únicamente desde una red administrativa. Después, PostgreSQL puede exigir que una cuenta específica utilice SCRAM-SHA-256 para conectarse a determinada base de datos.

Ambos controles se complementan, pero no son equivalentes.

### 5. ¿Qué diferencia existe entre autenticación y autorización?

La autenticación permite verificar la identidad de un usuario antes de permitirle ingresar al sistema.

Por ejemplo, PostgreSQL puede utilizar SCRAM-SHA-256 para comprobar credenciales.

La autorización determina qué acciones puede realizar una identidad autenticada.

Durante el LAB-03 se comprobó que el rol `analista` tenía permiso para consultar una vista limitada, pero no para consultar directamente la tabla `clientes`.

Esto demuestra que verificar una identidad no significa otorgarle acceso a todos los recursos.

### 6. ¿Por qué una cuenta de aplicación no debe ser `SUPERUSER`?

Una cuenta `SUPERUSER` dispone de capacidades administrativas amplias y puede eludir numerosos controles de acceso de PostgreSQL.

Si una aplicación utiliza esa cuenta y presenta una vulnerabilidad, como una inyección SQL, el atacante podría aprovechar privilegios mucho mayores de los necesarios para el funcionamiento ordinario de la aplicación.

Esto incrementaría el impacto del incidente y podría comprometer otras tablas, bases de datos o recursos del servidor.

Por esa razón se recomienda crear cuentas independientes de aplicación y otorgarles solamente los privilegios necesarios.

Durante la Actividad 9 se diseñaron conceptualmente cuentas DBA, APP y CONSULTA, aunque no se crearon nuevos usuarios.

### 7. ¿Por qué cambiar el puerto de PostgreSQL no constituye hardening suficiente?

Porque cambiar el puerto modifica la ubicación lógica del servicio, pero no corrige automáticamente sus problemas de seguridad.

Un servidor que utilice otro puerto puede continuar expuesto si escucha en todas las interfaces, permite conexiones desde redes innecesarias o utiliza cuentas con privilegios excesivos.

Además, un análisis de puertos puede identificar servicios disponibles independientemente del número utilizado.

Por ello, la seguridad debe basarse principalmente en restricciones de red, autenticación, autorización, protección del sistema operativo y mantenimiento.

Durante nuestra práctica se mantuvo el puerto 5432 porque no fue necesario cambiarlo para cumplir el objetivo de seguridad del entorno local.

### 8. ¿Por qué `listen_addresses='*'` puede ser innecesario?

Porque esa configuración permite que PostgreSQL escuche en todas las interfaces de red disponibles.

Si una base de datos solamente necesita conexiones locales o desde una interfaz privada específica, escuchar en otras interfaces aumenta innecesariamente su superficie de exposición.

Esto no significa automáticamente que cualquier usuario pueda conectarse, ya que también intervienen `pg_hba.conf` y el firewall.

Sin embargo, resulta más adecuado escuchar únicamente en las interfaces necesarias.

En nuestro laboratorio se comprobó que `listen_addresses = 'localhost'` permite el funcionamiento correcto de pgAdmin y de las prácticas locales sin habilitar interfaces externas.

### 9. ¿Qué papel tiene el sistema operativo en la seguridad de PostgreSQL?

El sistema operativo proporciona mecanismos fundamentales para proteger los procesos, archivos, directorios y recursos utilizados por PostgreSQL.

En Windows, los permisos NTFS determinan qué cuentas pueden leer, modificar o administrar los archivos del servidor.

Durante el laboratorio se inspeccionaron los permisos de `postgresql.conf`, `pg_hba.conf` y el directorio de datos utilizando `icacls` y `Get-Acl`.

También se verificó que el servicio de PostgreSQL se ejecuta mediante `NT AUTHORITY\NetworkService`.

La revisión demostró que algunas cuentas disponen de control total sobre archivos de configuración, por lo que es importante justificar sus permisos.

Los privilegios SQL no sustituyen los controles del sistema operativo, porque un acceso indebido a archivos sensibles puede comprometer la seguridad incluso sin utilizar una conexión SQL ordinaria.

### 10. ¿Qué controles deberían revisarse periódicamente?

La organización debería revisar periódicamente las reglas de autenticación, los usuarios y sus privilegios, las interfaces y puertos de escucha, las políticas de firewall y la necesidad de las extensiones instaladas.

También deben verificarse los certificados TLS, las versiones y actualizaciones de PostgreSQL, los permisos de archivos, los mecanismos de respaldo y los registros de auditoría.

Los límites de conexiones y tiempos de espera deben revisarse conforme a las necesidades operativas.

Además, cualquier modificación importante debería quedar documentada en una línea base de seguridad, conservando información sobre su justificación, responsables, verificación y posibles mecanismos de reversión.

## 6. Reflexión individual

### ¿Qué cambiarías primero si recibieras la responsabilidad de asegurar un servidor PostgreSQL que ya se encuentra funcionando en producción?

Si recibiera la responsabilidad de asegurar un servidor PostgreSQL en producción, primero identificaría su superficie de ataque y comprobaría qué sistemas necesitan conectarse realmente.

Antes de aplicar cambios revisaría el estado del servicio, las interfaces de escucha, las reglas de firewall, `pg_hba.conf`, las cuentas privilegiadas y los mecanismos de autenticación.

También verificaría que existan respaldos recuperables y un procedimiento para revertir modificaciones que pudieran afectar a los usuarios.

Después de esta inspección priorizaría **restringir cualquier exposición de red innecesaria que se haya identificado**, porque permitir conexiones desde redes no autorizadas aumenta las oportunidades de ataque.

Sin embargo, no aplicaría restricciones sin comprobar previamente cuáles son los orígenes utilizados por las aplicaciones legítimas. En producción, bloquear una conexión necesaria podría interrumpir servicios importantes.

Si el servidor ya tuviera una exposición de red adecuada, consideraría prioritario revisar las cuentas de aplicación, especialmente si alguna utiliza `SUPERUSER` o privilegios excesivos.

La autenticación también sería fundamental, ya que las cuentas deberían utilizar mecanismos seguros y credenciales administradas correctamente.

Mi decisión se basaría en reducir primero los riesgos de mayor impacto sin comprometer la disponibilidad y continuidad de los servicios.

El orden general sería evaluar la exposición, comprobar las dependencias, preparar los mecanismos de recuperación, aplicar cambios controlados y verificar sus resultados.

De esta manera, el hardening no consistiría simplemente en modificar parámetros, sino en mejorar la seguridad manteniendo el funcionamiento de la organización.

## 7. Verificación final

Al finalizar el laboratorio se ejecutó `04-verificacion.sql`, que reunió las principales comprobaciones de seguridad.

La consulta produjo once resultados:

| Resultado | Cantidad |
|---|---:|
| Controles verificados | 8 |
| Cuenta administrativa identificada | 1 |
| Mejoras propuestas | 2 |
| **Total** | **11** |

Los controles verificados incluyen versión de PostgreSQL, puerto e interfaces, autenticación, reglas de `pg_hba.conf`, rol `analista`, privilegios de consulta, SSL y TLS de la sesión.

Se identificó la cuenta administrativa `postgres`.

Las dos mejoras propuestas corresponden al registro de conexiones y al tiempo de espera de las transacciones inactivas.

![Verificación final del LAB-04](evidencias/06-verificacion.png)

La verificación terminó correctamente y no fue necesario modificar datos ni parámetros del servidor.

Debe aclararse que estos resultados no constituyen una certificación integral de seguridad; representan las comprobaciones realizadas conforme al alcance del laboratorio.

## 8. Evidencias y documentos

### Scripts SQL

- [01 — Inspección inicial](sql/01-inspeccion.sql)
- [02 — Roles y privilegios](sql/02-roles.sql)
- [03 — Configuración del servidor](sql/03-configuracion.sql)
- [04 — Verificación final](sql/04-verificacion.sql)

### Documentación de seguridad

- [Línea base y checklist](configuracion/baseline.md)
- [Análisis, propuestas y comparación](configuracion/cambios.md)

### Evidencias principales

- [Superficie de ataque](evidencias/01-superficie-ataque.png)
- [Interfaces de escucha](evidencias/02-listen-addresses.png)
- [Reglas de autenticación](evidencias/03-pg-hba.png)
- [Roles](evidencias/04-roles.png)
- [Conexión TLS](evidencias/05-tls.png)
- [Verificación final](evidencias/06-verificacion.png)

Las demás capturas de PostgreSQL y PowerShell se encuentran en la carpeta `evidencias`.

## 9. Cambios realizados y alcance del laboratorio

Durante el LAB-04 se inspeccionó y verificó la configuración existente de PostgreSQL 16.

Se elaboraron propuestas de mínimo privilegio, firewall, separación de cuentas, auditoría, tiempos de espera y mantenimiento.

No se modificaron directamente las reglas de `pg_hba.conf`, el firewall de Windows, los certificados TLS, los privilegios existentes ni los permisos NTFS.

Tampoco se aplicaron nuevos parámetros a `postgresql.conf`.

Por lo tanto, las mejoras conceptuales se presentan como recomendaciones y no como cambios efectivamente implementados.

Esta distinción es importante para conservar la trazabilidad y evitar atribuir resultados a operaciones que no fueron realizadas.

## 10. Conclusiones

El LAB-04 permitió comprender que la seguridad de PostgreSQL depende de diversos componentes que deben funcionar de manera coordinada.

Durante las prácticas se comprobó que nuestro entorno local dispone de varias medidas relevantes, entre ellas interfaces de escucha restringidas, autenticación SCRAM-SHA-256, separación parcial de privilegios y conexiones cifradas mediante TLS 1.3.

También se identificaron oportunidades de mejora relacionadas con registros de conexiones, tiempos de espera, permisos del sistema operativo, separación de cuentas de aplicación y validación de certificados.

La revisión demuestra que el hardening no consiste únicamente en cambiar configuraciones. También requiere analizar riesgos, justificar decisiones, documentar el estado del servidor y comprobar que los controles funcionan correctamente.

Finalmente, se concluye que el fortalecimiento de seguridad debe realizarse de forma continua, considerando tanto la protección de la información como la disponibilidad y continuidad de los servicios.
