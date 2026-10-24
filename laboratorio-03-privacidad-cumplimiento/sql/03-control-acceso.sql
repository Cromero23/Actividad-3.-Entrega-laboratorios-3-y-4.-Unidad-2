
-- ============================================================
-- LAB-03 - Privacidad, cumplimiento y gobierno de los datos
-- Archivo: 03-control-acceso.sql
-- Actividad 4: Control de acceso relacionado con la finalidad
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- ============================================================


-- ------------------------------------------------------------
-- 1. Verificar si existe el rol analista
-- ------------------------------------------------------------

SELECT
    rolname,
    rolcanlogin
FROM pg_roles
WHERE rolname = 'analista';


-- ------------------------------------------------------------
-- 2. Crear el rol analista si no existe
-- ------------------------------------------------------------

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'analista'
    ) THEN
        CREATE ROLE analista NOLOGIN;
    END IF;
END
$$;


-- ------------------------------------------------------------
-- 3. Crear vista para la finalidad de analitica
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_analitica_clientes AS
SELECT
    ciudad,
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad
FROM public.clientes;


-- ------------------------------------------------------------
-- 4. Consultar la vista
-- Evidencia: cap06-vista-analitica.png
-- ------------------------------------------------------------

SELECT *
FROM public.v_analitica_clientes
ORDER BY ciudad, rango_edad;


-- ------------------------------------------------------------
-- 5. Conceder acceso al esquema public
-- ------------------------------------------------------------

GRANT USAGE
ON SCHEMA public
TO analista;


-- ------------------------------------------------------------
-- 6. Otorgar lectura unicamente sobre la vista
-- ------------------------------------------------------------

GRANT SELECT
ON public.v_analitica_clientes
TO analista;


-- ------------------------------------------------------------
-- IMPORTANTE
-- ------------------------------------------------------------

-- NO se concede acceso directo a clientes.
--
-- No ejecutar:
--
-- GRANT SELECT ON public.clientes TO analista;
--
-- El rol debe utilizar la vista autorizada.


-- ------------------------------------------------------------
-- 7. Verificar los privilegios concedidos
-- Evidencia: cap07-permisos-analista.png
-- ------------------------------------------------------------

SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista'
ORDER BY table_name;


-- ------------------------------------------------------------
-- 8. Verificar el acceso efectivo
-- Evidencia: cap08-acceso-restringido.png
-- ------------------------------------------------------------

SELECT
    has_table_privilege(
        'analista',
        'public.v_analitica_clientes',
        'SELECT'
    ) AS puede_consultar_vista,

    has_table_privilege(
        'analista',
        'public.clientes',
        'SELECT'
    ) AS puede_consultar_clientes;


-- ------------------------------------------------------------
-- 9. Confirmar las caracteristicas del rol
-- ------------------------------------------------------------

SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname = 'analista';


-- ------------------------------------------------------------
-- RESULTADOS COMPROBADOS DURANTE EL LABORATORIO
-- ------------------------------------------------------------

-- Rol:
-- analista

-- Caracteristica:
-- NOLOGIN

-- Vista:
-- public.v_analitica_clientes

-- Columnas de la vista:
-- ciudad
-- rango_edad

-- Privilegio concedido:
-- SELECT sobre v_analitica_clientes

-- Verificacion de acceso:
--
-- puede_consultar_vista    = true
-- puede_consultar_clientes = false


-- ------------------------------------------------------------
-- ANALISIS
-- ------------------------------------------------------------

-- El rol analista tiene acceso a una vista que limita
-- las columnas visibles a ciudad y rango_edad.

-- Se evita otorgar acceso directo a la tabla clientes,
-- que contiene nombres, correos, telefonos y RFC.

-- De esta manera se aplican los principios de:
--
-- 1. Minimo privilegio.
-- 2. Limitacion de finalidad.
-- 3. Minimizacion de informacion.
-- 4. Necesidad de conocer.

-- La verificacion de permisos efectivos permite detectar
-- si existieran otros privilegios que otorgaran acceso
-- a la tabla original.

-- La vista utilizada en la practica muestra filas
-- individuales sin identificadores directos.
-- No representa una anonimizacion completa.

-- Para un entorno productivo seria preferible
-- utilizar vistas verdaderamente agregadas.


-- ------------------------------------------------------------
-- CONCLUSION
-- ------------------------------------------------------------

-- PostgreSQL permite restringir el acceso a la
-- informacion mediante roles, vistas y privilegios.

-- Durante la practica se comprobo que el analista
-- puede consultar la vista autorizada, pero no
-- dispone de permiso directo SELECT sobre clientes.

-- Esta separacion reduce la exposicion innecesaria
-- de informacion personal.
