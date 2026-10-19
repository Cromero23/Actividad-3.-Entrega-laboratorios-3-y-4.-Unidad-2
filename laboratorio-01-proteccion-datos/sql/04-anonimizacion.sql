-- LAB-01 — Actividad 4
-- Anonimización y análisis del riesgo de reidentificación

-- Generalizar la edad
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1
ORDER BY 1;

-- Generalizar el código postal
SELECT
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1
ORDER BY 1;

-- Combinar rango de edad y región
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1, 2
ORDER BY 1, 2;

-- Suprimir grupos pequeños utilizando un umbral didáctico k = 5
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;

-- Reto:
-- aumentar la generalización para reducir el riesgo
-- de reidentificación
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 50 THEN '18-50'
        ELSE '51+'
    END AS rango_edad_amplio,
    LEFT(codigo_postal, 1) AS region_amplia,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1, 2
ORDER BY 1, 2;

-- Aplicar nuevamente el umbral k = 5
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 50 THEN '18-50'
        ELSE '51+'
    END AS rango_edad_amplio,
    LEFT(codigo_postal, 1) AS region_amplia,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;