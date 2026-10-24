# LAB-04 — Línea base de seguridad de PostgreSQL 16

## Entorno del laboratorio

- **Sistema operativo:** Windows.
- **Motor de base de datos:** PostgreSQL 16.15.
- **Servidor:** PostgreSQL 16 Local.
- **Base de datos:** `db_unidad02_carlos_romero`.
- **Puerto:** 5432.
- **Interfaces de escucha:** `localhost`.
- **SSL:** habilitado.
- **Cifrado configurado para nuevas contraseñas:** `scram-sha-256`.

## Actividad 4 — Revisión de pg_hba.conf

Se consultó la vista `pg_hba_file_rules` para identificar las reglas de autenticación.

El servidor presenta seis reglas relacionadas con conexiones locales y replicación.

Las conexiones IPv4 se limitan a `127.0.0.1` y las conexiones IPv6 a `::1`.

Todas las reglas utilizan `scram-sha-256`.

No se identificaron reglas que acepten cualquier dirección IPv4 o IPv6, ni reglas configuradas con el método `trust`.

La consulta tampoco mostró errores de análisis en las reglas.

**Evidencia:** `../evidencias/03-pg-hba.png`.

## Actividad 5 — Análisis de una regla permisiva

### Regla hipotética del ejercicio

```text
host    all    all    0.0.0.0/0    scram-sha-256
```

Esta regla no corresponde a nuestra configuración real. Se analiza únicamente como un escenario propuesto por la guía.

### 1. ¿Qué bases de datos permite?

El primer valor `all` indica que la regla puede aplicarse a todas las bases de datos del servidor.

### 2. ¿Qué usuarios permite?

El segundo valor `all` indica que la regla puede aplicarse a todos los usuarios o roles habilitados para iniciar sesión, sin restringirse a una cuenta de aplicación específica.

### 3. ¿Qué direcciones de origen permite?

El rango `0.0.0.0/0` representa cualquier dirección IPv4.

Esto significa que la regla no limita las conexiones a una red o dirección de origen específica.

### 4. ¿Qué método de autenticación utiliza?

Utiliza `scram-sha-256`, un método de autenticación mediante contraseña que emplea un mecanismo de desafío y respuesta.

Aunque ofrece protección de credenciales, no sustituye la necesidad de restringir los orígenes autorizados.

### 5. ¿Por qué puede representar una exposición innecesaria?

Porque permite intentos de autenticación desde cualquier dirección IPv4 que tenga conectividad hacia el servidor.

Si PostgreSQL también escuchara en interfaces accesibles desde redes externas y el firewall permitiera el tráfico, aumentaría la superficie de ataque.

Esta configuración podría facilitar intentos de acceso no autorizado y ampliar la exposición de las cuentas y bases de datos.

### 6. ¿Qué información necesitamos para restringirla?

Es necesario identificar:

- Qué aplicación requiere conectarse.
- Qué base de datos necesita utilizar.
- Qué usuario de PostgreSQL utilizará.
- Desde qué dirección o red se conectará.
- Qué método de autenticación está autorizado.
- Si requiere TLS y qué controles adicionales están disponibles.

## Propuesta para nuestro entorno local

**Regla hipotética original:**

```text
host    all    all    0.0.0.0/0    scram-sha-256
```

**Problema:** permite intentos de autenticación desde cualquier origen IPv4 y abarca todas las bases de datos y usuarios.

**Origen que realmente necesita acceso:** el equipo local, mediante `127.0.0.1`.

**Base de datos:** `db_unidad02_carlos_romero`.

**Usuario:** `postgres`, utilizado para administrar el entorno académico.

**Regla específica propuesta para administración local:**

```text
host    db_unidad02_carlos_romero    postgres    127.0.0.1/32    scram-sha-256
```

Esta regla se propone únicamente como ejemplo para restringir la administración local. Una implementación real deberá considerar las demás conexiones necesarias, el orden de las reglas y el acceso mediante IPv6.

En un entorno productivo también debería evitarse utilizar la cuenta `postgres` para las conexiones ordinarias de las aplicaciones.

## Comparación con nuestra configuración real

Nuestro servidor ya utiliza `listen_addresses = 'localhost'` y reglas limitadas a direcciones locales.

Por lo tanto, no es necesario agregar la regla hipotética ni cambiar las direcciones de origen para demostrar el objetivo de esta actividad.

Las reglas actuales permiten diferentes usuarios y bases de datos desde el equipo local. En las siguientes actividades analizaremos si es conveniente establecer restricciones adicionales por rol y finalidad.

## Conclusión

El análisis demuestra que un método de autenticación seguro no es suficiente cuando las reglas permiten orígenes innecesariamente amplios.

El hardening debe combinar restricciones de red, identificación de usuarios autorizados, métodos de autenticación apropiados y controles de acceso.

En nuestro laboratorio se comprobó que PostgreSQL ya limita las conexiones a interfaces locales y utiliza SCRAM-SHA-256.

**Estado:** análisis realizado. No se modificó `pg_hba.conf`.








## Actividad 6 — Mínimo privilegio en conexiones

Se diseñó una regla conceptual de autenticación adaptada al entorno PostgreSQL 16 local.

```text
host    db_unidad02_carlos_romero    postgres    127.0.0.1/32    scram-sha-256
```

Esta propuesta delimita la base de datos, el usuario, la dirección de origen y el método de autenticación.

La configuración real ya restringe las conexiones a direcciones locales, pero utiliza reglas generales para todos los usuarios y bases de datos.

La regla diseñada no se aplicó al servidor, debido a que sería necesario revisar el orden de las reglas existentes, mantener los accesos administrativos necesarios y comprobar las conexiones antes de sustituirlas.

**Conclusión:** el mínimo privilegio en las conexiones requiere limitar cada elemento de la regla según las necesidades reales, sin impedir el funcionamiento de los servicios autorizados.

**Estado:** diseño conceptual completado, sin cambios en pg_hba.conf.









## Actividad 8 — Revisión de usuarios y privilegios

Se identificaron 16 roles en PostgreSQL, de los cuales 14
corresponden a roles predefinidos del sistema.

Los dos roles restantes son:

| Rol | LOGIN | SUPERUSER | CREATEROLE | CREATEDB | Función |
|---|---|---|---|---|---|
| postgres | Sí | Sí | Sí | Sí | Administración del servidor |
| analista | No | No | No | No | Rol de permisos para analítica |

El rol `postgres` debe reservarse para actividades
administrativas. No se recomienda utilizarlo como credencial
ordinaria de una aplicación.

El rol `analista` fue creado durante el LAB-03 para limitar
la consulta a una vista autorizada. No tiene privilegios
administrativos y no puede iniciar sesión directamente.

Evidencias:
- `../evidencias/04-roles.png`
- `../evidencias/04b-roles-laboratorio.png`

## Actividad 9 — Separación de cuentas

Se diseñó conceptualmente una estructura de tres cuentas.

| Cuenta | Propósito | LOGIN | Privilegios |
|---|---|---|---|
| postgres (DBA) | Administración | Sí | Administrativos |
| app_lab04 (APP) | Operaciones de aplicación | Sí | Mínimos según su función |
| consulta_lab04 (CONSULTA) | Consultar datos autorizados | Sí | Solo lectura |

Las cuentas `app_lab04` y `consulta_lab04` son propuestas
académicas; no se crearon durante esta actividad.

### Riesgo de usar una cuenta administrativa en una aplicación

Si una aplicación utiliza una cuenta SUPERUSER, una
vulnerabilidad de seguridad podría permitir que un atacante
ejecute operaciones con privilegios administrativos.

Esto incrementaría considerablemente el impacto de un
incidente, ya que podría afectar otras bases de datos,
usuarios y configuraciones del servidor.

### Medidas recomendadas

La aplicación debe utilizar una cuenta independiente con
los permisos mínimos necesarios.

Las consultas deben efectuarse mediante cuentas con
acceso limitado a las tablas o vistas autorizadas.

La cuenta administrativa debe reservarse para operaciones
de mantenimiento y administración.

### Conclusión

Separar las cuentas administrativas y de aplicación reduce
el impacto de posibles vulnerabilidades y permite aplicar
el principio de mínimo privilegio.

Estado: diseño conceptual completado. No se modificaron roles.










---

## Actividad 17 — Checklist de hardening de PostgreSQL 16

### Objetivo

Elaborar una lista de verificación de seguridad para evaluar los
controles de hardening del servidor PostgreSQL 16, identificando
los controles comprobados, los parcialmente implementados y
aquellos que requieren acciones adicionales.

### Entorno evaluado

- Motor: PostgreSQL 16.15
- Sistema operativo: Windows
- Servicio: postgresql-x64-16
- Base de datos: db_unidad02_carlos_romero
- Puerto: 5432
- Modalidad: Laboratorio académico local

### Criterios de evaluación

**Sí:** El control fue comprobado o su documentación fue
completada según el alcance indicado.

**Parcial:** Se inspeccionó o diseñó el control, pero
quedan requisitos pendientes.

**No:** El control todavía no ha sido implementado
o su cumplimiento no fue demostrado.

### Checklist de hardening

| N.º | Control | Verificado | Evidencia o justificación |
|---|---|---|---|
| 1 | Puerto PostgreSQL documentado | Sí | Puerto 5432 confirmado mediante SQL y PowerShell. `01-superficie-ataque.png` |
| 2 | Interfaces de escucha justificadas | Sí | `listen_addresses = localhost`. `02-listen-addresses.png` |
| 3 | Reglas de `pg_hba.conf` revisadas | Sí | Se identificaron seis reglas sin errores de análisis. `03-pg-hba.png` |
| 4 | Redes autorizadas restringidas | Sí | Acceso local por `127.0.0.1` y `::1`; no se encontraron reglas abiertas a cualquier red. `03-pg-hba.png` |
| 5 | Método de autenticación seguro | Sí | Se verificó `password_encryption = scram-sha-256`. No se auditaron los verificadores históricos de todas las cuentas. `03b-autenticacion.png` |
| 6 | Superusuarios identificados | Sí | Se confirmó que `postgres` posee privilegios administrativos. `04b-roles-laboratorio.png` |
| 7 | Cuentas de aplicación separadas | No | La separación entre DBA, APP y CONSULTA fue diseñada, pero las cuentas nuevas no fueron creadas. |
| 8 | Principio de mínimo privilegio | Parcial | El rol `analista` tiene permisos limitados, comprobados en LAB-03. Falta aplicar la separación a cuentas reales de aplicación. |
| 9 | Extensiones instaladas revisadas | Sí | Se identificaron `pgcrypto` 1.3 y `plpgsql` 1.0. `04c-extensiones.png` |
| 10 | TLS verificado | Sí | Se comprobó una conexión cifrada mediante TLS 1.3. No se ha demostrado que todas las conexiones exijan TLS. `05-tls.png` |
| 11 | Archivos de configuración protegidos | Parcial | Se revisaron las ACL de `postgresql.conf` y `pg_hba.conf`. La cuenta local conserva control total y requiere evaluación de mínimo privilegio. `04e-permisos-archivos.png` |
| 12 | Directorio de datos protegido | Parcial | Se revisaron propietario y permisos NTFS. No se realizaron cambios ni una auditoría exhaustiva de sus permisos. `04f-permisos-directorio.png` |
| 13 | Política de firewall documentada | Sí | Se diseñó una política de acceso restringido para el escenario ficticio. No fue aplicada al firewall real. `configuracion/cambios.md` |
| 14 | Actualizaciones documentadas | Parcial | Se registró PostgreSQL 16.15, pero falta definir una política de revisión y actualización periódica. |
| 15 | Configuración de seguridad registrada | Sí | Se documentaron los valores iniciales, las verificaciones y las propuestas en `baseline.md` y `cambios.md`. |
| 16 | Registros de conexión y desconexión evaluados | Parcial | `logging_collector = on`, pero `log_connections` y `log_disconnections` permanecen en `off`. `02b-directorios-logs.png` |
| 17 | Límites de conexión y tiempos de espera revisados | Parcial | `max_connections = 100`; ambos tiempos de espera consultados están desactivados. `04d-conexiones-timeouts.png` |
| 18 | Validación del certificado TLS del servidor | No | Se comprobó que la sesión utiliza TLS, pero no se verificó que el cliente valide el certificado mediante `verify-ca` o `verify-full`. |

### Análisis de resultados

El checklist permitió evaluar 18 controles relacionados con
configuración, autenticación, autorización, red, cifrado,
archivos sensibles y mantenimiento.

Se comprobó que el servidor dispone de varias medidas
adecuadas para el entorno académico local:

- Escucha limitada a localhost.
- Reglas de autenticación restringidas a direcciones locales.
- SCRAM-SHA-256 configurado para nuevas contraseñas.
- Roles administrativos identificados.
- Extensiones revisadas.
- Conexión TLS 1.3 verificada.
- Superficie de red inspeccionada.
- Configuración inicial documentada.

También se identificaron medidas pendientes.

### Controles que requieren atención

**Separación de cuentas**

El servidor utiliza `postgres` para administración y
conserva el rol `analista` sin capacidad de inicio de sesión.

Se propuso crear cuentas diferenciadas para aplicaciones
y consultas, pero todavía no fueron implementadas.

**Permisos del sistema operativo**

Los permisos NTFS fueron inspeccionados y no se
identificó un permiso general para todos los usuarios.

Sin embargo, algunas cuentas poseen control total sobre
archivos de configuración. Esto debe justificarse y
revisarse antes de realizar modificaciones.

**Mantenimiento**

La versión del servidor está documentada, pero todavía
es necesario establecer una política de actualizaciones,
revisión periódica y registro de cambios.

**Registros y disponibilidad**

Los registros de conexión y desconexión están desactivados.

Los parámetros `statement_timeout` e
`idle_in_transaction_session_timeout` tienen un valor
general de cero, por lo que deben evaluarse límites
adecuados para las aplicaciones.

**Cifrado y validación**

Se confirmó que la sesión actual utiliza TLS 1.3.

Sin embargo, debe comprobarse por separado que
las conexiones que lo requieran estén obligadas
a utilizar TLS y que el cliente valide el certificado
del servidor de acuerdo con su política de seguridad.

### Relación con las evidencias

Todas las capturas fueron obtenidas directamente
en PostgreSQL 16, pgAdmin 4 y PowerShell.

Las propuestas conceptuales se distinguen de
los controles efectivamente implementados.

No se realizaron modificaciones a las ACL, reglas
de firewall, certificados ni archivos de configuración
durante esta evaluación.

### Conclusión

El checklist de hardening permitió identificar
fortalezas y oportunidades de mejora en PostgreSQL 16.

La configuración actual presenta medidas importantes
de seguridad para su uso como laboratorio local.

Sin embargo, no todos los controles han alcanzado
el mismo nivel de implementación.

La separación de cuentas, la política de actualizaciones,
los controles de auditoría y la validación completa de
certificados requieren acciones adicionales.

El hardening debe desarrollarse mediante un proceso
continuo de inspección, justificación, implementación,
verificación y documentación.








---

## Actividad 19 — Construcción de una línea base de seguridad

### Objetivo

Construir una línea base de seguridad para PostgreSQL 16
que establezca una configuración de referencia para
administrar el servidor, reducir su superficie de ataque
y documentar las medidas de protección necesarias.

La propuesta considera siete áreas: red, autenticación,
autorización, configuración, sistema operativo, cifrado
y mantenimiento.

### 1. Información general del entorno

| Elemento | Configuración verificada |
|---|---|
| Sistema operativo | Windows |
| Motor | PostgreSQL 16.15 |
| Servicio | postgresql-x64-16 |
| Estado del servicio | Running |
| Cuenta del servicio | NT AUTHORITY\NetworkService |
| Base de datos | db_unidad02_carlos_romero |
| Puerto | 5432 |
| Interfaces de escucha | localhost |
| SSL | on |
| Versión TLS mínima | TLSv1.2 |
| Versión TLS negociada | TLSv1.3 |
| Autenticación configurada | scram-sha-256 |

Esta información se obtuvo mediante consultas ejecutadas
en pgAdmin 4 y comandos de PowerShell.

### 2. Seguridad de red

#### Estado verificado

Durante las actividades anteriores se comprobó que
PostgreSQL utiliza el puerto TCP 5432.

El parámetro `listen_addresses` contiene `localhost`.

Mediante PowerShell se identificaron las interfaces:

- 127.0.0.1
- ::1

También se verificó que el proceso `postgres`
escucha en dichas interfaces.

La prueba de conectividad local devolvió:

`TcpTestSucceeded : True`

No se observaron sockets de escucha del proceso
PostgreSQL asociados al puerto 5432 en interfaces externas.

#### Línea base propuesta

| Control | Configuración recomendada |
|---|---|
| Puerto | Mantener el puerto documentado |
| Interfaces | Escuchar solamente en las interfaces necesarias |
| Acceso remoto | Deshabilitado cuando no sea necesario |
| Redes permitidas | Únicamente direcciones o redes autorizadas |
| Firewall | Aplicar reglas restrictivas según los servicios necesarios |
| Revisión | Verificar periódicamente direcciones y puertos de escucha |

Para nuestro entorno académico se considera adecuado
conservar `listen_addresses = 'localhost'`.

La política de firewall para el servidor ficticio
10.10.10.20 fue diseñada conceptualmente, pero
no se aplicó en Windows.

**Estado:** interfaces verificadas. Política de
firewall diseñada, sin implementación real.

### 3. Autenticación

#### Estado verificado

Se comprobó que PostgreSQL utiliza:

`password_encryption = 'scram-sha-256'`

También se revisó `pg_hba.conf`, identificando
seis reglas de conexiones locales y replicación.

Todas las reglas revisadas utilizan SCRAM-SHA-256
y no presentan errores de análisis.

No se encontraron reglas `trust` ni reglas con
origen `0.0.0.0/0` o `::/0`.

#### Línea base propuesta

| Control | Recomendación |
|---|---|
| Método | Utilizar SCRAM-SHA-256 |
| Contraseñas | Emplear credenciales individuales y robustas |
| Almacenamiento | No guardar contraseñas en texto plano |
| Cuentas administrativas | Reservarlas para administración |
| Reglas pg_hba.conf | Restringir por usuario, base y origen |
| Credenciales | Evitar compartir cuentas o publicar secretos |

El parámetro `password_encryption` determina
el formato configurado para nuevas contraseñas.

No se verificó individualmente el formato de
todos los verificadores de contraseña existentes.

**Estado:** configuración SCRAM verificada.
Política completa de credenciales propuesta.

### 4. Autorización

#### Estado verificado

Durante la revisión se identificaron dos roles
no pertenecientes al conjunto de roles predefinidos:

| Rol | LOGIN | SUPERUSER | Función |
|---|---|---|---|
| postgres | Sí | Sí | Administración |
| analista | No | No | Permisos de analítica |

El rol `postgres` cuenta con privilegios para
administrar el servidor.

El rol `analista`, creado durante el LAB-03,
no puede iniciar sesión directamente.

Durante el laboratorio anterior se comprobó
que este último dispone de permiso SELECT
sobre `v_analitica_clientes`, pero no de
acceso directo a `public.clientes`.

#### Línea base propuesta

| Control | Recomendación |
|---|---|
| DBA | Cuenta administrativa para mantenimiento |
| APP | Cuenta independiente con permisos mínimos |
| CONSULTA | Cuenta de lectura limitada |
| Roles | Separar privilegios según funciones |
| SUPERUSER | Evitarlo en aplicaciones ordinarias |
| Permisos | Revisar periódicamente GRANT y REVOKE |

Durante el LAB-04 se diseñaron las cuentas
`app_lab04` y `consulta_lab04`.

Estas cuentas son propuestas y no fueron
creadas físicamente en PostgreSQL.

**Estado:** roles existentes verificados.
Separación adicional de cuentas pendiente.

### 5. Configuración del servidor

#### Estado verificado

Se revisaron los siguientes parámetros:

| Parámetro | Valor encontrado |
|---|---|
| max_connections | 100 |
| superuser_reserved_connections | 3 |
| statement_timeout | 0 ms |
| idle_in_transaction_session_timeout | 0 ms |
| logging_collector | on |
| log_connections | off |
| log_disconnections | off |
| log_destination | stderr |
| log_directory | log |

Los valores de cero para los tiempos de espera
significan que los límites generales
correspondientes están desactivados.

También se identificaron estas extensiones:

| Extensión | Versión |
|---|---|
| pgcrypto | 1.3 |
| plpgsql | 1.0 |

#### Línea base propuesta

Los límites de conexión deben establecerse
considerando la capacidad del servidor y las
necesidades de las aplicaciones.

Se recomienda evaluar tiempos de espera
apropiados para evitar sesiones o transacciones
inactivas durante periodos excesivos.

También debe analizarse la activación de
registros de conexión y desconexión.

Las extensiones instaladas deben conservarse
únicamente cuando exista una necesidad
funcional justificada.

#### Decisión para el laboratorio

Se conservaron los valores originales
para no afectar las prácticas anteriores.

`pgcrypto` se mantiene porque fue utilizada
durante el LAB-02.

No se modificaron los tiempos de espera
ni las opciones de registro.

**Estado:** parámetros y extensiones verificados.
Mejoras de auditoría y disponibilidad pendientes.

### 6. Sistema operativo

#### Estado verificado

La instalación utiliza el directorio:

`C:\Program Files\PostgreSQL\16\data`

Se identificaron los archivos:

- postgresql.conf
- pg_hba.conf
- pg_ident.conf

El servicio PostgreSQL se ejecuta mediante:

`NT AUTHORITY\NetworkService`

Los permisos NTFS se inspeccionaron
mediante los comandos `icacls` y `Get-Acl`.

Se comprobó que las cuentas de administradores,
SYSTEM, la cuenta local y NetworkService
disponen de permisos sobre los archivos
de configuración.

El propietario del directorio de datos
es el grupo Administradores.

También se comprobó que la cuenta local
posee control total sobre archivos
de configuración revisados.

#### Línea base propuesta

| Control | Recomendación |
|---|---|
| Cuenta de servicio | Utilizar una identidad con permisos justificados |
| Archivos .conf | Restringir acceso de lectura y modificación |
| Directorio de datos | Permitir únicamente accesos necesarios |
| Certificados | Proteger archivos y claves privadas |
| Propietarios | Revisar y documentar propietarios |
| ACL | Auditar periódicamente los permisos NTFS |

No deben modificarse los permisos sin
comprobar previamente las necesidades
de la cuenta que ejecuta PostgreSQL.

#### Decisión para el laboratorio

Se conservaron las ACL actuales para
evitar afectar el servicio y los
certificados TLS configurados en LAB-02.

**Estado:** permisos inspeccionados.
Evaluación de mínimo privilegio pendiente.

### 7. Cifrado y protección de información

#### Estado verificado

Durante la revisión se comprobó:

- SSL habilitado.
- Versión TLS mínima: TLSv1.2.
- Sesión actual utilizando TLS.
- Versión negociada: TLSv1.3.
- Autenticación configurada: SCRAM-SHA-256.

Durante el LAB-02 también se realizaron
pruebas de cifrado utilizando `pgcrypto`.

#### Línea base propuesta

| Control | Recomendación |
|---|---|
| TLS | Proteger las comunicaciones |
| Versión mínima | Evitar versiones obsoletas |
| Certificados | Gestionarlos y renovarlos correctamente |
| Claves privadas | Restringir accesos mediante permisos NTFS |
| Credenciales | Evitar almacenamiento en texto plano |
| Datos sensibles | Aplicar cifrado cuando corresponda |
| Validación TLS | Verificar la identidad del servidor |

Aunque se comprobó que la conexión
actual utiliza TLS 1.3, todavía no
se ha demostrado que todos los clientes
estén obligados a utilizar TLS.

Tampoco se verificó completamente
la validación del certificado por parte
de todos los clientes.

**Estado:** TLS habilitado y conexión
cifrada comprobada. Validación integral
de clientes pendiente.

### 8. Mantenimiento y actualización

#### Estado verificado

El servidor utiliza PostgreSQL 16.15.

Durante el LAB-04 se documentaron
sus parámetros principales, roles,
extensiones, interfaces de red
y mecanismos de protección.

#### Línea base propuesta

La organización debe establecer
un procedimiento periódico que incluya:

1. Revisar actualizaciones de PostgreSQL.
2. Evaluar avisos de seguridad aplicables.
3. Mantener respaldos adecuados.
4. Comprobar la recuperación de los respaldos.
5. Revisar cuentas y permisos.
6. Verificar reglas de autenticación y firewall.
7. Revisar certificados y sus fechas de vencimiento.
8. Inspeccionar registros y eventos relevantes.
9. Documentar cambios de configuración.
10. Repetir el checklist de hardening.

Las actualizaciones deben probarse
antes de aplicarse a sistemas productivos.

#### Estado

Se identificó la versión instalada,
pero no se implementó una política
automatizada de actualizaciones.

### 9. Resumen de cumplimiento

| Área | Estado de la línea base | Observación |
|---|---|---|
| Red | Verificada parcialmente | Escucha local comprobada; firewall real no auditado completamente |
| Autenticación | Verificada parcialmente | SCRAM configurado; política integral de credenciales pendiente |
| Autorización | Parcial | Roles revisados; separación de cuentas propuesta |
| Configuración | Parcial | Parámetros identificados; auditoría y timeouts pendientes de evaluación |
| Sistema operativo | Parcial | ACL inspeccionadas; revisión de privilegios pendiente |
| Cifrado | Parcial | TLS 1.3 comprobado en la sesión; validación integral pendiente |
| Mantenimiento | Parcial | Versión identificada; política de revisión y actualización propuesta |

La clasificación reconoce que algunos controles
fueron comprobados mediante evidencias reales,
mientras que otros permanecen como recomendaciones.

No debe interpretarse que todas las medidas
propuestas fueron implementadas.

### 10. Controles prioritarios para futuras mejoras

Se consideran prioritarias las siguientes acciones:

1. Separar las cuentas de aplicación y administración.
2. Definir una política formal de actualización.
3. Revisar el acceso a archivos sensibles.
4. Evaluar registros de conexiones y desconexiones.
5. Establecer tiempos de espera apropiados.
6. Comprobar que los clientes validen certificados TLS.
7. Revisar periódicamente reglas de autenticación.
8. Mantener un inventario de configuraciones y cambios.

Estas medidas requieren pruebas, autorización y
respaldos adecuados antes de su implementación.

### 11. Evidencias utilizadas

Las verificaciones fueron realizadas mediante
consultas SQL, pgAdmin 4 y PowerShell.

Evidencias principales:

- [Superficie de ataque](../evidencias/01-superficie-ataque.png)
- [Interfaces de escucha](../evidencias/02-listen-addresses.png)
- [Reglas de autenticación](../evidencias/03-pg-hba.png)
- [Roles](../evidencias/04-roles.png)
- [Permisos de archivos](../evidencias/04e-permisos-archivos.png)
- [Exposición de red](../evidencias/04g-exposicion-red.png)
- [Conectividad local](../evidencias/04h-conectividad-local.png)
- [Verificación TLS](../evidencias/05-tls.png)

Las verificaciones adicionales están
documentadas en la carpeta `evidencias`.

### 12. Conclusión

La construcción de una línea base de seguridad
permite identificar, documentar y evaluar
las configuraciones de un servidor PostgreSQL.

Durante el LAB-04 se comprobó que el entorno
académico ya contaba con controles importantes,
como interfaces locales, autenticación SCRAM-SHA-256
y TLS.

También se identificaron oportunidades de mejora
en administración de cuentas, auditoría,
tiempos de espera, permisos y mantenimiento.

Por lo tanto, el resultado principal fue la
verificación del estado de seguridad y la
documentación de propuestas de fortalecimiento.

El hardening debe realizarse como un proceso
continuo y controlado, evitando cambios que
puedan interrumpir los servicios autorizados.

**Estado final:** línea base documentada.
No se realizaron modificaciones directas
a la configuración activa del servidor
durante el LAB-04.
