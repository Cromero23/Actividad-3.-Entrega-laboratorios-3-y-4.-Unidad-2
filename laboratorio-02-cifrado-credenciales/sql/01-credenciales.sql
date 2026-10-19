
-- ============================================================
-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividad 1: Protección de credenciales
-- Motor: PostgreSQL 16
-- Base de datos: db_unidad02_carlos_romero
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Demostración de almacenamiento inseguro
CREATE TABLE IF NOT EXISTS public.usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);

INSERT INTO public.usuarios_insegura (usuario, password)
SELECT 'juan', 'Password123'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.usuarios_insegura
    WHERE usuario = 'juan'
);

-- La contraseña ficticia aparece en texto claro.
SELECT id, usuario, password
FROM public.usuarios_insegura
WHERE usuario = 'juan';


-- 2. Almacenamiento protegido mediante bcrypt
CREATE TABLE IF NOT EXISTS public.usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

INSERT INTO public.usuarios_segura (
    usuario,
    password_hash
)
VALUES (
    'juan',
    crypt('Password123', gen_salt('bf'))
)
ON CONFLICT (usuario) DO NOTHING;

-- La contraseña original no se almacena en esta tabla.
SELECT id, usuario, password_hash
FROM public.usuarios_segura
WHERE usuario = 'juan';


-- 3. Verificar contraseña correcta e incorrecta
SELECT
    usuario,
    crypt('Password123', password_hash) = password_hash
        AS contrasena_correcta,
    crypt('OtraPassword', password_hash) = password_hash
        AS contrasena_incorrecta
FROM public.usuarios_segura
WHERE usuario = 'juan';


-- 4. Comprobar el efecto de una sal aleatoria
-- Una misma contraseña produce hashes diferentes.
WITH hashes AS (
    SELECT
        crypt('Password123', gen_salt('bf')) AS hash_1,
        crypt('Password123', gen_salt('bf')) AS hash_2
)
SELECT
    hash_1,
    hash_2,
    hash_1 <> hash_2 AS hashes_diferentes
FROM hashes;

-- CONCLUSIÓN:
-- Las contraseñas deben protegerse con algoritmos
-- específicos de hash de contraseñas y sal.
-- En sistemas reales puede utilizarse Argon2id mediante
-- bibliotecas o frameworks de seguridad adecuados.
