
-- ============================================================
-- LAB-04 - Hardening y configuracion segura de PostgreSQL
-- Archivo: 03-configuracion.sql
-- Unidad II - Seguridad, privacidad y control de acceso
--
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- Sistema operativo: Windows
--
-- OBJETIVO:
-- Revisar las reglas de autenticacion, extensiones,
-- conexiones, tiempos de espera, registros y SSL/TLS.
-- ============================================================


-- ============================================================
-- 1. REVISAR LAS REGLAS DE AUTENTICACION
-- Actividad 4
-- Evidencia: 03-pg-hba.png
-- ============================================================

SELECT
    line_number,
    type,
    database,
    user_name,
    address,
    netmask,
    auth_method,
    error
FROM pg_hba_file_rules
ORDER BY line_number;


-- ============================================================
-- 2. VERIFICAR EL METODO DE CIFRADO DE CONTRASENAS
-- Actividad 7
-- Evidencia: 03b-autenticacion.png
-- ============================================================

SHOW password_encryption;


-- ============================================================
-- 3. CONSULTAR LAS EXTENSIONES INSTALADAS
-- Actividad 10
-- Evidencia: 04c-extensiones.png
-- ============================================================

SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;


-- ============================================================
-- 4. REVISAR CONEXIONES Y TIEMPOS DE ESPERA
-- Actividad 11
-- Evidencia: 04d-conexiones-timeouts.png
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual,
    COALESCE(unit, 'sin unidad') AS unidad
FROM pg_settings
WHERE name IN (
    'max_connections',
    'superuser_reserved_connections',
    'statement_timeout',
    'idle_in_transaction_session_timeout'
)
ORDER BY name;


-- ============================================================
-- 5. REVISAR LA CONFIGURACION DE LOS REGISTROS
-- Relacionada con las actividades 2, 11 y 19
-- Evidencia: 02b-directorios-logs.png
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual
FROM pg_settings
WHERE name IN (
    'logging_collector',
    'log_destination',
    'log_directory',
    'log_connections',
    'log_disconnections'
)
ORDER BY name;


-- ============================================================
-- 6. REVISAR LA CONFIGURACION SSL/TLS
-- Actividad 15
-- Evidencia: 05a-configuracion-tls.png
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual
FROM pg_settings
WHERE name IN (
    'ssl',
    'ssl_min_protocol_version'
)
ORDER BY name;


-- ============================================================
-- 7. VERIFICAR EL CIFRADO DE LA CONEXION ACTUAL
-- Actividad 15
-- Evidencia: 05-tls.png
-- ============================================================

SELECT
    a.pid,
    a.usename,
    a.client_addr,
    s.ssl,
    s.version,
    s.cipher
FROM pg_stat_ssl AS s
JOIN pg_stat_activity AS a
    ON a.pid = s.pid
WHERE s.pid = pg_backend_pid();


-- ============================================================
-- 8. CONSULTAR LOS PARAMETROS RELEVANTES DE HARDENING
-- Resumen general de configuracion
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual,
    source AS origen_configuracion,
    pending_restart AS requiere_reinicio
FROM pg_settings
WHERE name IN (
    'port',
    'listen_addresses',
    'ssl',
    'ssl_min_protocol_version',
    'password_encryption',
    'max_connections',
    'superuser_reserved_connections',
    'statement_timeout',
    'idle_in_transaction_session_timeout',
    'logging_collector',
    'log_connections',
    'log_disconnections'
)
ORDER BY name;


-- ============================================================
-- RESULTADOS OBSERVADOS DURANTE EL LABORATORIO
-- ============================================================

-- REGLAS DE AUTENTICACION
--
-- Se identificaron seis reglas en pg_hba.conf.
--
-- Todas utilizan scram-sha-256.
--
-- No se encontraron reglas:
--   0.0.0.0/0
--   ::/0
--   trust
--
-- No se observaron errores de analisis en las reglas.


-- ============================================================
-- CIFRADO DE CONTRASENAS
-- ============================================================

-- password_encryption = scram-sha-256
--
-- Este valor corresponde al mecanismo configurado
-- para establecer nuevas contrasenas.
--
-- No demuestra por si solo que todas las contrasenas
-- anteriores utilicen el mismo tipo de verificador.


-- ============================================================
-- EXTENSIONES INSTALADAS
-- ============================================================

-- pgcrypto = 1.3
-- plpgsql  = 1.0
--
-- pgcrypto fue utilizada durante el LAB-02.
--
-- plpgsql permite utilizar funciones y procedimientos
-- desarrollados mediante el lenguaje procedural SQL.
--
-- No se eliminaron extensiones.


-- ============================================================
-- CONEXIONES Y TIEMPOS DE ESPERA
-- ============================================================

-- max_connections = 100
--
-- superuser_reserved_connections = 3
--
-- statement_timeout = 0 ms
--
-- idle_in_transaction_session_timeout = 0 ms
--
-- Los tiempos de espera con valor cero estan
-- desactivados en la configuracion consultada.
--
-- Se recomienda evaluar limites por rol o aplicacion
-- para reducir riesgos de sesiones o consultas
-- que consuman recursos durante periodos excesivos.


-- ============================================================
-- CONFIGURACION DE REGISTROS
-- ============================================================

-- logging_collector = on
--
-- log_destination = stderr
--
-- log_directory = log
--
-- log_connections = off
--
-- log_disconnections = off
--
-- El recolector de registros esta habilitado.
--
-- El registro de conexiones y desconexiones
-- permanece desactivado.
--
-- Se recomienda evaluar estas opciones conforme
-- a las necesidades de auditoria de la organizacion.


-- ============================================================
-- CONFIGURACION SSL/TLS
-- ============================================================

-- ssl = on
--
-- ssl_min_protocol_version = TLSv1.2
--
-- Conexion actual:
-- ssl = true
-- version = TLSv1.3
--
-- El algoritmo exacto de cifrado puede consultarse
-- mediante la columna cipher de pg_stat_ssl.
--
-- Se verifico que la conexion de pgAdmin utiliza TLS.
--
-- IMPORTANTE:
-- ssl = on no significa que todos los clientes
-- esten obligados a conectarse mediante TLS.
--
-- La validacion de la identidad del servidor
-- tambien depende de la configuracion del cliente
-- y de la verificacion de certificados.


-- ============================================================
-- ANALISIS DE SEGURIDAD
-- ============================================================

-- 1. Las reglas de autenticacion revisadas se encuentran
--    limitadas a conexiones locales.

-- 2. PostgreSQL utiliza SCRAM-SHA-256 para establecer
--    nuevas contrasenas.

-- 3. Se identificaron dos extensiones instaladas.
--    Ambas se conservaron para no afectar las
--    funcionalidades utilizadas en las practicas.

-- 4. Los limites generales de tiempo para consultas
--    y transacciones inactivas estan desactivados.

-- 5. Los registros de conexion y desconexion
--    estan desactivados.

-- 6. SSL se encuentra habilitado.

-- 7. Se comprobo una conexion cifrada mediante TLS 1.3.

-- 8. Se identificaron mejoras posibles, pero no
--    se aplicaron cambios que pudieran afectar
--    el funcionamiento del servidor.

-- 9. Para un entorno productivo seria necesario
--    revisar estos parametros considerando los
--    requisitos de seguridad y disponibilidad.


-- ============================================================
-- CONCLUSION
-- ============================================================

-- La revision de configuracion permitio comprobar
-- los mecanismos de autenticacion y cifrado
-- utilizados por PostgreSQL 16.

-- Tambien se identificaron parametros relacionados
-- con auditoria, disponibilidad y consumo de recursos.

-- El servidor ya cuenta con medidas importantes
-- de seguridad para el entorno academico local.

-- Sin embargo, la separacion de cuentas,
-- los registros de eventos y los tiempos de espera
-- requieren una evaluacion adicional.

-- ESTADO:
-- Inspeccion y documentacion completadas.
-- No se realizaron modificaciones al servidor.
-- ============================================================
