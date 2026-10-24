
-- ============================================================
-- LAB-03 - Privacidad, cumplimiento y gobierno de los datos
-- Archivo: 01-minimizacion.sql
-- Actividades 1 y 2: Inventario y minimizacion
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- ============================================================


-- ------------------------------------------------------------
-- 1. Consultar la tabla original de clientes
-- ------------------------------------------------------------

SELECT
    id,
    nombre,
    correo,
    telefono,
    rfc,
    edad,
    ciudad,
    codigo_postal,
    fecha_alta
FROM public.clientes
ORDER BY id;


-- ------------------------------------------------------------
-- 2. Verificar el numero de registros originales
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_clientes
FROM public.clientes;


-- ------------------------------------------------------------
-- 3. Crear una tabla con los datos necesarios para soporte
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.clientes_soporte (
    id BIGINT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);


-- ------------------------------------------------------------
-- 4. Copiar solamente los campos necesarios
-- ------------------------------------------------------------

INSERT INTO public.clientes_soporte (
    id,
    nombre,
    correo,
    telefono
)
SELECT
    id,
    nombre,
    correo,
    telefono
FROM public.clientes
ON CONFLICT (id) DO NOTHING;


-- ------------------------------------------------------------
-- 5. Verificar los registros de soporte
-- ------------------------------------------------------------

SELECT
    id,
    nombre,
    correo,
    telefono
FROM public.clientes_soporte
ORDER BY id;


-- ------------------------------------------------------------
-- 6. Comparar la cantidad de columnas
-- ------------------------------------------------------------

SELECT
    table_name AS tabla,
    COUNT(*) AS total_columnas
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('clientes', 'clientes_soporte')
GROUP BY table_name
ORDER BY table_name;


-- ------------------------------------------------------------
-- 7. Comprobar la cantidad de clientes en ambas tablas
-- ------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM public.clientes)
        AS clientes_originales,
    (SELECT COUNT(*) FROM public.clientes_soporte)
        AS clientes_soporte;


-- ------------------------------------------------------------
-- RESULTADOS OBTENIDOS EN EL LABORATORIO
--
-- Tabla original:
--   9 columnas
--   5 registros ficticios
--
-- Tabla clientes_soporte:
--   4 columnas
--   5 registros ficticios
--
-- No se copiaron a soporte:
--   rfc
--   edad
--   ciudad
--   codigo_postal
--   fecha_alta
--
-- CONCLUSION:
-- La minimizacion permite reducir la cantidad de datos
-- personales tratados para una finalidad especifica.
--
-- NOTA:
-- Ya no quiero hacer otro laboratorio XD.
-- ON CONFLICT DO NOTHING evita duplicar registros.
-- No sincroniza automaticamente modificaciones posteriores.
-- En la Actividad 7 se rectifico el correo y se actualizo
-- tambien la copia almacenada en clientes_soporte.
-- ------------------------------------------------------------
