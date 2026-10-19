
-- ============================================================
-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividades 4, 5 y 6: Verificación de TLS
-- Motor: PostgreSQL 16
-- ============================================================

-- 1. Estado general de TLS
SHOW ssl;

-- 2. Versión mínima de TLS configurada
SHOW ssl_min_protocol_version;

-- 3. Puerto de PostgreSQL
SHOW port;

-- 4. Direcciones de escucha del servidor
SHOW listen_addresses;

-- 5. Resumen de parámetros
SELECT
    current_setting('ssl') AS ssl_habilitado,
    current_setting('ssl_min_protocol_version') AS tls_minimo,
    current_setting('port') AS puerto,
    current_setting('listen_addresses')
        AS direcciones_escucha;

-- 6. Estado TLS de la conexión actual
SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

-- 7. Información del cliente
SELECT
    inet_client_addr() AS direccion_cliente,
    inet_client_port() AS puerto_cliente;

-- 8. Rutas y parámetros de configuración
-- No muestra el contenido de claves privadas.
SELECT
    name,
    setting
FROM pg_settings
WHERE name IN (
    'data_directory',
    'config_file',
    'ssl_cert_file',
    'ssl_key_file',
    'listen_addresses'
)
ORDER BY name;

-- RESULTADOS COMPROBADOS DURANTE LA PRÁCTICA:
--
-- Estado inicial:
--   ssl = off
--   pg_stat_ssl.ssl = false
--
-- Después de configurar PostgreSQL:
--   ssl = on
--   pg_stat_ssl.ssl = true
--   version = TLSv1.3
--   cipher = TLS_AES_256_GCM_SHA384
--
-- Para una conexión por psql se utilizó:
--   sslmode=require
--
-- Nota: require exige cifrado, pero no realiza la
-- validación completa de identidad de verify-full.
