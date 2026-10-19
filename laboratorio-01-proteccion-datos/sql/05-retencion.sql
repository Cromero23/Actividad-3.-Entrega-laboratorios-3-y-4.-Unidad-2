-- LAB-01 — Actividad 5
-- Retención de datos

-- Identificar los registros que serían candidatos
-- a una política de retención de cinco años
SELECT *
FROM public.clientes
WHERE fecha_alta <
CURRENT_DATE - INTERVAL '5 years';

-- Mostrar la fecha actual y la fecha límite
-- utilizada para aplicar la política de retención
SELECT
    CURRENT_DATE AS fecha_actual,
    CURRENT_DATE - INTERVAL '5 years'
        AS fecha_limite_retencion;

-- Contar los registros que cumplirían
-- el criterio de eliminación
SELECT
    COUNT(*) AS registros_candidatos_eliminacion
FROM public.clientes
WHERE fecha_alta <
CURRENT_DATE - INTERVAL '5 years';

-- IMPORTANTE:
-- No se ejecuta DELETE sobre la tabla principal.
--
-- Una eliminación real requeriría previamente:
-- 1. Validar la política de retención.
-- 2. Obtener autorización.
-- 3. Verificar respaldos.
-- 4. Registrar evidencia de la operación.
-- 5. Contar con un procedimiento de recuperación.