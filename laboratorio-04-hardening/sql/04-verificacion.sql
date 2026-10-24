
-- ============================================================
-- LAB-04 - Hardening y configuracion segura de PostgreSQL
-- Archivo: 04-verificacion.sql
-- Unidad II - Seguridad, privacidad y control de acceso
--
-- Estudiante: Carlos Romero
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- Sistema operativo: Windows
--
-- OBJETIVO:
-- Comprobar los principales controles de seguridad
-- del servidor y generar una tabla final de resultados.
-- ============================================================

WITH estado AS (
    SELECT
        current_setting('server_version') AS version_pg,
        current_setting('port') AS puerto,
        current_setting('listen_addresses') AS escucha,
        current_setting('password_encryption') AS autenticacion,
        current_setting('ssl') AS ssl_servidor,
        current_setting('ssl_min_protocol_version') AS tls_minimo,
        current_setting('log_connections') AS registro_conexiones,
        current_setting(
            'idle_in_transaction_session_timeout'
        ) AS timeout_inactivo,

        -- Comprobar reglas sin errores
        (
            SELECT COUNT(*)
            FROM pg_hba_file_rules
            WHERE error IS NOT NULL
        ) AS errores_hba,

        -- Comprobar reglas trust
        (
            SELECT COUNT(*)
            FROM pg_hba_file_rules
            WHERE auth_method = 'trust'
        ) AS reglas_trust,

        -- Comprobar reglas abiertas a cualquier origen
        (
            SELECT COUNT(*)
            FROM pg_hba_file_rules
            WHERE address IN ('0.0.0.0/0', '::/0')
               OR (
                    address = '0.0.0.0'
                    AND netmask = '0.0.0.0'
               )
               OR (
                    address = '::'
                    AND netmask = '::'
               )
        ) AS reglas_amplias,

        -- Verificar cuenta DBA
        EXISTS (
            SELECT 1
            FROM pg_roles
            WHERE rolname = 'postgres'
              AND rolsuper = TRUE
              AND rolcanlogin = TRUE
        ) AS dba_identificado,

        -- Verificar rol analista
        EXISTS (
            SELECT 1
            FROM pg_roles
            WHERE rolname = 'analista'
              AND rolsuper = FALSE
              AND rolcanlogin = FALSE
        ) AS analista_limitado,

        -- Verificar permisos heredados del LAB-03
        has_table_privilege(
            'analista',
            'public.v_analitica_clientes',
            'SELECT'
        ) AS acceso_vista,

        has_table_privilege(
            'analista',
            'public.clientes',
            'SELECT'
        ) AS acceso_clientes,

        -- Comprobar TLS en esta sesion
        (
            SELECT ssl
            FROM pg_stat_ssl
            WHERE pid = pg_backend_pid()
        ) AS sesion_cifrada,

        (
            SELECT version
            FROM pg_stat_ssl
            WHERE pid = pg_backend_pid()
        ) AS version_tls
)

SELECT
    v.control,
    v.valor_actual,
    v.resultado
FROM estado AS e
CROSS JOIN LATERAL (
    VALUES

    (
        '01 - Version PostgreSQL',
        e.version_pg,
        CASE
            WHEN split_part(e.version_pg, '.', 1) = '16'
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '02 - Puerto e interfaces',
        e.puerto || ' / ' || e.escucha,
        CASE
            WHEN e.puerto = '5432'
             AND e.escucha = 'localhost'
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '03 - Autenticacion',
        e.autenticacion,
        CASE
            WHEN e.autenticacion = 'scram-sha-256'
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '04 - Reglas pg_hba.conf',
        'Errores: ' || e.errores_hba::text ||
        ', trust: ' || e.reglas_trust::text ||
        ', amplias: ' || e.reglas_amplias::text,
        CASE
            WHEN e.errores_hba = 0
             AND e.reglas_trust = 0
             AND e.reglas_amplias = 0
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '05 - Cuenta administrativa',
        CASE
            WHEN e.dba_identificado
                THEN 'postgres / SUPERUSER'
            ELSE 'No coincide'
        END,
        CASE
            WHEN e.dba_identificado
                THEN 'IDENTIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '06 - Rol analista',
        CASE
            WHEN e.analista_limitado
                THEN 'NOLOGIN / sin SUPERUSER'
            ELSE 'No coincide'
        END,
        CASE
            WHEN e.analista_limitado
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '07 - Privilegios analista',
        'Vista: ' || COALESCE(e.acceso_vista::text, 'NULL') ||
        ', clientes: ' ||
        COALESCE(e.acceso_clientes::text, 'NULL'),
        CASE
            WHEN e.acceso_vista = TRUE
             AND e.acceso_clientes = FALSE
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '08 - SSL del servidor',
        e.ssl_servidor || ' / minimo ' || e.tls_minimo,
        CASE
            WHEN e.ssl_servidor = 'on'
             AND e.tls_minimo IN ('TLSv1.2', 'TLSv1.3')
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '09 - TLS de la sesion',
        COALESCE(e.version_tls, 'Sin TLS'),
        CASE
            WHEN e.sesion_cifrada = TRUE
                THEN 'VERIFICADO'
            ELSE 'REVISAR'
        END
    ),

    (
        '10 - Registro de conexiones',
        e.registro_conexiones,
        CASE
            WHEN e.registro_conexiones = 'on'
                THEN 'HABILITADO'
            ELSE 'MEJORA PROPUESTA'
        END
    ),

    (
        '11 - Timeout transaccion inactiva',
        e.timeout_inactivo || ' ms',
        CASE
            WHEN e.timeout_inactivo::bigint > 0
                THEN 'CONFIGURADO'
            ELSE 'MEJORA PROPUESTA'
        END
    )

) AS v(control, valor_actual, resultado)
ORDER BY v.control;


-- ============================================================
-- INTERPRETACION
-- ============================================================

-- VERIFICADO:
-- El control coincide con el estado esperado
-- para nuestro laboratorio local.
--
-- IDENTIFICADO:
-- Se ha comprobado la existencia de una
-- cuenta administrativa.
--
-- MEJORA PROPUESTA:
-- Se identifico un parametro cuya configuracion
-- debe evaluarse. No se modifico durante el LAB-04.
--
-- REVISAR:
-- El resultado no coincide con el valor esperado
-- o requiere una comprobacion adicional.
--
-- IMPORTANTE:
-- Esta consulta verifica determinados controles
-- de PostgreSQL, pero no sustituye las evidencias
-- de firewall, permisos NTFS o validacion completa
-- de certificados.
--
-- ============================================================
-- CONCLUSION
-- ============================================================

-- La verificacion final permite comprobar
-- que PostgreSQL mantiene los principales
-- controles documentados durante el laboratorio.
--
-- Se distinguen los controles existentes
-- de las oportunidades de mejora.
--
-- No se realizaron cambios directos al servidor.
-- ============================================================
