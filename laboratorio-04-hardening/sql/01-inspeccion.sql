
-- ============================================================
-- LAB-04 - Hardening y configuracion segura de PostgreSQL
-- Archivo: 01-inspeccion.sql
-- Unidad II - Seguridad, privacidad y control de acceso
--
-- Motor: PostgreSQL 16.15
-- Base de datos: db_unidad02_carlos_romero
-- Sistema operativo: Windows
--
-- Objetivo:
-- Identificar la superficie de ataque y documentar
-- la configuracion inicial del servidor PostgreSQL.
-- ============================================================


-- ============================================================
-- 1. IDENTIFICAR VERSION Y CONFIGURACION INICIAL
-- Actividad 1
-- Evidencia: 01-superficie-ataque.png
-- ============================================================

SELECT
    version() AS version_postgresql,
    current_setting('port') AS puerto,
    current_setting('listen_addresses') AS interfaces_escucha,
    current_setting('ssl') AS ssl,
    current_setting('password_encryption')
        AS cifrado_contrasenas;


-- ============================================================
-- 2. IDENTIFICAR CONEXIONES ACTUALES
-- Actividad 1
-- Evidencia: 01b-conexiones-actuales.png
-- ============================================================

SELECT
    pid,
    usename,
    datname,
    client_addr,
    client_port,
    application_name
FROM pg_stat_activity
ORDER BY
    usename NULLS LAST,
    datname NULLS LAST,
    pid;


-- ============================================================
-- 3. LOCALIZAR ARCHIVOS DE CONFIGURACION
-- Actividad 2
-- Evidencia: 02-archivos-configuracion.png
-- ============================================================

SELECT
    'postgresql.conf' AS archivo,
    current_setting('config_file') AS ruta

UNION ALL

SELECT
    'pg_hba.conf',
    current_setting('hba_file')

UNION ALL

SELECT
    'pg_ident.conf',
    current_setting('ident_file');


-- ============================================================
-- 4. IDENTIFICAR DIRECTORIOS Y REGISTROS
-- Actividad 2
-- Evidencia: 02b-directorios-logs.png
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual
FROM pg_settings
WHERE name IN (
    'data_directory',
    'log_directory',
    'logging_collector',
    'log_destination',
    'log_connections',
    'log_disconnections'
)
ORDER BY name;


-- ============================================================
-- 5. VERIFICAR INTERFACES DE ESCUCHA
-- Actividad 3
-- Evidencia: 02-listen-addresses.png
-- ============================================================

SHOW listen_addresses;


-- ============================================================
-- 6. CONSULTAR EL PUERTO ACTUAL
-- ============================================================

SHOW port;


-- ============================================================
-- 7. IDENTIFICAR PARAMETROS DE RED Y AUTENTICACION
-- ============================================================

SELECT
    name AS parametro,
    setting AS valor_actual,
    source AS origen_configuracion
FROM pg_settings
WHERE name IN (
    'port',
    'listen_addresses',
    'ssl',
    'password_encryption'
)
ORDER BY name;


-- ============================================================
-- RESULTADOS OBTENIDOS DURANTE EL LABORATORIO
-- ============================================================

-- Version del servidor:
-- PostgreSQL 16.15

-- Puerto:
-- 5432

-- Interfaces:
-- localhost

-- SSL:
-- on

-- Configuracion de nuevas contrasenas:
-- scram-sha-256

-- Directorio de datos:
-- C:/Program Files/PostgreSQL/16/data

-- Archivo principal:
-- C:/Program Files/PostgreSQL/16/data/postgresql.conf

-- Reglas de autenticacion:
-- C:/Program Files/PostgreSQL/16/data/pg_hba.conf

-- Mapeo de identidades:
-- C:/Program Files/PostgreSQL/16/data/pg_ident.conf


-- ============================================================
-- CONFIGURACION DE REGISTROS OBSERVADA
-- ============================================================

-- logging_collector = on
-- log_connections = off
-- log_disconnections = off
-- log_destination = stderr
-- log_directory = log


-- ============================================================
-- ANALISIS DE SEGURIDAD
-- ============================================================

-- 1. PostgreSQL escucha en localhost, lo cual
--    restringe la exposicion de red para este
--    entorno academico.

-- 2. El puerto 5432 se encuentra documentado.
--    El numero de puerto por si solo no representa
--    un mecanismo de seguridad.

-- 3. SSL esta habilitado, pero este parametro
--    no demuestra que todas las conexiones
--    esten obligadas a utilizar TLS.

-- 4. SCRAM-SHA-256 esta configurado para las
--    nuevas contrasenas. Esto no garantiza que
--    todos los verificadores existentes utilicen
--    el mismo mecanismo.

-- 5. Las sesiones observadas durante la practica
--    provenian de la direccion local 127.0.0.1.

-- 6. Se identificaron los archivos principales
--    para su posterior revision y proteccion.

-- 7. Los registros de conexiones y desconexiones
--    estan desactivados. Se recomienda evaluar
--    su activacion segun la politica de auditoria.

-- 8. No fue necesario modificar estos parametros
--    durante la inspeccion.


-- ============================================================
-- CONCLUSION
-- ============================================================

-- La inspeccion inicial permitio conocer la
-- superficie de ataque de PostgreSQL 16.

-- Se verificaron version, puerto, interfaces,
-- cifrado de contrasenas, conexiones y archivos
-- de configuracion.

-- El servidor ya contaba con restricciones
-- importantes para el uso local.

-- Esta informacion constituye la referencia
-- inicial para evaluar el hardening y justificar
-- las mejoras propuestas.

-- Estado:
-- Inspeccion completada sin modificar el servidor.
-- ============================================================
