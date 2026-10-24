
-- ============================================================
-- LAB-03 - Privacidad, cumplimiento y gobierno de los datos
-- Archivo: 02-finalidad.sql
-- Actividad 3: Separacion por finalidad
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- ============================================================


-- ------------------------------------------------------------
-- 1. Estadisticas por ciudad
-- Evidencia: cap03-clientes-por-ciudad.png
-- ------------------------------------------------------------

SELECT
    ciudad,
    COUNT(*) AS cantidad_clientes
FROM public.clientes
GROUP BY ciudad
ORDER BY cantidad_clientes DESC, ciudad;


-- ------------------------------------------------------------
-- 2. Estadisticas por rangos de edad
-- Evidencia: cap04-rangos-edad.png
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad,
    COUNT(*) AS cantidad
FROM public.clientes
GROUP BY
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END
ORDER BY rango_edad;


-- ------------------------------------------------------------
-- 3. Estadisticas por region del codigo postal
-- Se utilizan solo los primeros dos caracteres.
-- Evidencia: cap05-region-postal.png
-- ------------------------------------------------------------

SELECT
    LEFT(codigo_postal, 2) AS region_postal,
    COUNT(*) AS cantidad_clientes
FROM public.clientes
GROUP BY LEFT(codigo_postal, 2)
ORDER BY region_postal;


-- ------------------------------------------------------------
-- RESULTADOS OBTENIDOS DURANTE EL LABORATORIO
-- ------------------------------------------------------------

-- CLIENTES POR CIUDAD:
-- Culiacan    = 3
-- Los Mochis  = 1
-- Mazatlan    = 1

-- CLIENTES POR RANGO DE EDAD:
-- 30-44 = 4
-- 45-59 = 1

-- CLIENTES POR REGION POSTAL:
-- 80 = 3
-- 81 = 1
-- 82 = 1


-- ------------------------------------------------------------
-- ANALISIS
-- ------------------------------------------------------------

-- Las consultas permiten obtener informacion estadistica
-- sin proporcionar nombres, correos, telefonos o RFC.

-- Se aplica el principio de minimizacion porque cada
-- resultado incluye solamente los campos necesarios
-- para la finalidad de analitica.

-- Los resultados se encuentran agregados por categorias.

-- IMPORTANTE:
-- Los grupos con un solo registro pueden facilitar
-- la reidentificacion si se combinan con otros datos.
-- Por ello, la agregacion no garantiza automaticamente
-- el anonimato de la informacion.


-- ------------------------------------------------------------
-- CONCLUSION
-- ------------------------------------------------------------

-- La separacion por finalidad permite generar estadisticas
-- sin entregar la tabla completa de clientes.

-- Para sistemas reales se recomienda utilizar vistas
-- agregadas, controles de acceso y umbrales minimos
-- de agrupacion cuando exista riesgo de reidentificacion.
