-- LAB-01 — Actividad 2
-- Enmascaramiento y control de acceso

-- Crear rol único para el entorno compartido FICLabs
-- El rol "soporte" ya existía en el servidor,
-- por lo que se utiliza un nombre asociado a la matrícula.
CREATE ROLE soporte_23101075 NOLOGIN;

-- Crear vista con información enmascarada
CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    nombre,
    CONCAT(
        LEFT(correo, 2),
        '*****',
        SUBSTRING(correo FROM POSITION('@' IN correo))
    ) AS correo,
    CONCAT(
        '******',
        RIGHT(telefono, 4)
    ) AS telefono,
    CONCAT(
        '*********',
        RIGHT(rfc, 4)
    ) AS rfc
FROM public.clientes;

-- Verificar información presentada por la vista
SELECT *
FROM v_clientes_soporte;

-- Permitir acceso al esquema public
GRANT USAGE
ON SCHEMA public
TO soporte_23101075;

-- Permitir consulta únicamente sobre la vista
GRANT SELECT
ON v_clientes_soporte
TO soporte_23101075;

-- Asegurar que el rol no tenga acceso directo
-- a la tabla original de clientes
REVOKE ALL
ON public.clientes
FROM soporte_23101075;

-- Verificar privilegios
SELECT
    has_table_privilege(
        'soporte_23101075',
        'public.v_clientes_soporte',
        'SELECT'
    ) AS puede_ver_vista,

    has_table_privilege(
        'soporte_23101075',
        'public.clientes',
        'SELECT'
    ) AS puede_ver_clientes;

-- Resultado esperado:
-- puede_ver_vista    = true
-- puede_ver_clientes = false

-- Permitir que el usuario de la práctica pueda asumir el rol
GRANT soporte_23101075
TO u_23101075_carlos_romero;

-- Probar los permisos del rol soporte
SET ROLE soporte_23101075;

-- Verificar rol activo
SELECT
    current_user,
    session_user;

-- Debe funcionar y mostrar únicamente los datos enmascarados
SELECT *
FROM v_clientes_soporte;

-- Debe ser rechazado
SELECT *
FROM public.clientes;

-- Volver al usuario original
RESET ROLE;