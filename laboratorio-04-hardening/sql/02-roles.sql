
-- ============================================================
-- LAB-04 - Hardening y configuracion segura de PostgreSQL
-- Archivo: 02-roles.sql
-- Unidad II - Seguridad, privacidad y control de acceso
--
-- Estudiante: Carlos Romero
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- Sistema operativo: Windows
--
-- Objetivo:
-- Inspeccionar los roles existentes, identificar cuentas
-- administrativas y verificar el principio de minimo
-- privilegio aplicado en los laboratorios anteriores.
-- ============================================================


-- ============================================================
-- 1. CONSULTAR TODOS LOS ROLES
-- Actividad 8
-- Evidencia: 04-roles.png
-- ============================================================

SELECT
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
ORDER BY rolname;


-- ============================================================
-- 2. CONSULTAR ROLES NO PREDEFINIDOS
-- Actividad 8
-- Evidencia: 04b-roles-laboratorio.png
-- ============================================================

SELECT
    rolname AS rol,
    rolcanlogin AS puede_iniciar_sesion,
    rolsuper AS superusuario,
    rolcreaterole AS puede_crear_roles,
    rolcreatedb AS puede_crear_bases,
    rolinherit AS hereda_privilegios
FROM pg_roles
WHERE LEFT(rolname, 3) <> 'pg_'
ORDER BY rolname;


-- ============================================================
-- 3. IDENTIFICAR CUENTAS CON PRIVILEGIOS ADMINISTRATIVOS
-- ============================================================

SELECT
    rolname AS rol,
    rolcanlogin AS puede_iniciar_sesion,
    rolsuper AS superusuario,
    rolcreaterole AS puede_crear_roles,
    rolcreatedb AS puede_crear_bases
FROM pg_roles
WHERE rolsuper = TRUE
   OR rolcreaterole = TRUE
   OR rolcreatedb = TRUE
ORDER BY rolname;


-- ============================================================
-- 4. IDENTIFICAR ROLES QUE PUEDEN INICIAR SESION
-- ============================================================

SELECT
    rolname AS rol,
    rolcanlogin AS puede_iniciar_sesion,
    rolsuper AS superusuario
FROM pg_roles
WHERE rolcanlogin = TRUE
ORDER BY rolname;


-- ============================================================
-- 5. VERIFICAR EL ROL ANALISTA DEL LAB-03
-- ============================================================

SELECT
    rolname AS rol,
    rolcanlogin AS puede_iniciar_sesion,
    rolsuper AS superusuario,
    rolcreaterole AS puede_crear_roles,
    rolcreatedb AS puede_crear_bases
FROM pg_roles
WHERE rolname = 'analista';


-- ============================================================
-- 6. VERIFICAR PRIVILEGIOS DEL ROL ANALISTA
-- Se documentan los controles del laboratorio anterior.
-- ============================================================

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


-- ============================================================
-- 7. IDENTIFICAR PERMISOS SOBRE LA VISTA DE ANALITICA
-- ============================================================

SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista'
ORDER BY table_schema, table_name, privilege_type;


-- ============================================================
-- 8. CONTAR LOS ROLES DEL SERVIDOR
-- ============================================================

SELECT
    COUNT(*) AS total_roles,

    COUNT(*) FILTER (
        WHERE LEFT(rolname, 3) = 'pg_'
    ) AS roles_predefinidos,

    COUNT(*) FILTER (
        WHERE LEFT(rolname, 3) <> 'pg_'
    ) AS roles_no_predefinidos
FROM pg_roles;


-- ============================================================
-- RESULTADOS OBTENIDOS EN EL LABORATORIO
-- ============================================================

-- Durante la inspeccion se encontraron:
--
-- Total de roles: 16
-- Roles predefinidos pg_: 14
-- Roles no predefinidos: 2
--
-- Roles identificados:
--
-- postgres:
--   LOGIN       = true
--   SUPERUSER   = true
--   CREATEROLE  = true
--   CREATEDB    = true
--   INHERIT     = true
--
-- analista:
--   LOGIN       = false
--   SUPERUSER   = false
--   CREATEROLE  = false
--   CREATEDB    = false
--   INHERIT     = true
--
-- Estos resultados corresponden al estado observado
-- durante el LAB-04. Podrian variar si se crean roles
-- posteriormente.


-- ============================================================
-- VERIFICACION DE MINIMO PRIVILEGIO
-- ============================================================

-- Durante el LAB-03 se comprobo:
--
-- Rol: analista
--
-- SELECT sobre public.v_analitica_clientes = true
-- SELECT sobre public.clientes = false
--
-- El rol puede utilizarse para conceder permisos
-- mediante membresias, aunque no puede iniciar
-- sesion directamente porque tiene NOLOGIN.


-- ============================================================
-- ANALISIS DE SEGURIDAD
-- ============================================================

-- 1. La cuenta postgres tiene privilegios de superusuario.
--    Debe reservarse para tareas administrativas.

-- 2. Una aplicacion ordinaria no deberia utilizar
--    credenciales con privilegios SUPERUSER.

-- 3. El rol analista no tiene privilegios administrativos
--    ni capacidad de iniciar sesion directamente.

-- 4. La vista de analitica permite restringir el acceso
--    a columnas autorizadas, evitando entregar
--    directamente toda la tabla clientes.

-- 5. El principio de minimo privilegio reduce el impacto
--    que podria tener una cuenta comprometida.

-- 6. En la Actividad 9 se disenaron conceptualmente
--    cuentas independientes para DBA, APP y CONSULTA.

-- 7. Las cuentas propuestas app_lab04 y consulta_lab04
--    no se crearon durante esta actividad.


-- ============================================================
-- CONCLUSION
-- ============================================================

-- La revision de roles permitio identificar las cuentas
-- administrativas y comprobar sus privilegios.

-- PostgreSQL cuenta con mecanismos para separar
-- responsabilidades y limitar el acceso a los datos.

-- En nuestro entorno, postgres conserva los privilegios
-- de administracion y analista representa un ejemplo
-- practico de acceso limitado por finalidad.

-- Estado:
-- Revision de roles completada.
-- No se modificaron usuarios ni privilegios.
-- ============================================================
