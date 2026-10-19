
-- ============================================================
-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividad 2: Cifrado de información sensible
-- Motor: PostgreSQL 16
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Crear tabla con información protegida
CREATE TABLE IF NOT EXISTS public.clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

-- 2. Insertar un RFC ficticio cifrado
-- CLAVE-DE-PRUEBA es una frase exclusivamente demostrativa.
INSERT INTO public.clientes_protegidos (
    nombre,
    rfc_cifrado
)
SELECT
    'Ana López',
    pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA')
WHERE NOT EXISTS (
    SELECT 1
    FROM public.clientes_protegidos
    WHERE nombre = 'Ana López'
);

-- 3. Visualizar el dato almacenado
SELECT
    id,
    nombre,
    rfc_cifrado
FROM public.clientes_protegidos
WHERE nombre = 'Ana López';

-- 4. Visualización alternativa del dato cifrado
SELECT
    id,
    nombre,
    encode(rfc_cifrado, 'hex') AS rfc_en_hexadecimal
FROM public.clientes_protegidos
WHERE nombre = 'Ana López';

-- 5. Descifrar con la frase de prueba correcta
SELECT
    id,
    nombre,
    pgp_sym_decrypt(
        rfc_cifrado,
        'CLAVE-DE-PRUEBA'
    ) AS rfc_descifrado
FROM public.clientes_protegidos
WHERE nombre = 'Ana López';

-- 6. Prueba con frase incorrecta
-- Ejecutar esta consulta por separado, retirando
-- el comentario. Se espera un error de descifrado.
--
-- SELECT
--     pgp_sym_decrypt(
--         rfc_cifrado,
--         'CLAVE-INCORRECTA'
--     )
-- FROM public.clientes_protegidos
-- WHERE nombre = 'Ana López';

-- CONCLUSIÓN:
-- El cifrado simétrico permite recuperar información
-- mediante la clave correcta.
-- En producción, la clave NO debe incluirse en scripts SQL
-- ni publicarse en repositorios.
