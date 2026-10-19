-- LAB-01 — Actividad 3
-- Seudonimización y separación de funciones

-- Crear esquemas
CREATE SCHEMA IF NOT EXISTS pii;
CREATE SCHEMA IF NOT EXISTS analitica;

-- Crear tabla de correspondencia
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE
        REFERENCES public.clientes(id)
);

-- Habilitar generación de UUID
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Generar un token por cliente
INSERT INTO pii.mapa_cliente
(token, cliente_id)
SELECT
    gen_random_uuid(),
    id
FROM public.clientes;

-- Verificar mapa de correspondencia
SELECT *
FROM pii.mapa_cliente
ORDER BY cliente_id;

-- Crear conjunto analítico
CREATE TABLE analitica.clientes AS
SELECT
    m.token AS cliente_token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente m
JOIN public.clientes c
ON c.id = m.cliente_id;

-- Verificar conjunto seudonimizado
SELECT *
FROM analitica.clientes;

-- Crear rol único para el entorno compartido FICLabs
CREATE ROLE analista_23101075 NOLOGIN;

-- Permitir acceso únicamente al conjunto analítico
GRANT USAGE
ON SCHEMA analitica
TO analista_23101075;

GRANT SELECT
ON analitica.clientes
TO analista_23101075;

-- Asegurar que no tenga acceso al mapa ni a los datos originales
REVOKE ALL
ON pii.mapa_cliente
FROM analista_23101075;

REVOKE ALL
ON public.clientes
FROM analista_23101075;

-- Verificar privilegios
SELECT
    has_table_privilege(
        'analista_23101075',
        'analitica.clientes',
        'SELECT'
    ) AS puede_ver_analitica,
    has_table_privilege(
        'analista_23101075',
        'pii.mapa_cliente',
        'SELECT'
    ) AS puede_ver_mapa,
    has_table_privilege(
        'analista_23101075',
        'public.clientes',
        'SELECT'
    ) AS puede_ver_clientes;

-- Permitir que el usuario de la práctica pueda asumir el rol
GRANT analista_23101075
TO u_23101075_carlos_romero;

-- Probar los permisos del analista
SET ROLE analista_23101075;

-- Debe funcionar
SELECT *
FROM analitica.clientes;

-- Debe ser rechazado
SELECT *
FROM pii.mapa_cliente;

-- Debe ser rechazado
SELECT *
FROM public.clientes;

-- Volver al usuario original
RESET ROLE;