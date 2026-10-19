# LAB-02 — Cifrado, credenciales y comunicaciones seguras

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Unidad:** II — Seguridad, privacidad y control de acceso  
**Tema:** Cifrado, credenciales y protección de las comunicaciones  
**Estudiante:** Carlos Romero  
**Motor de base de datos:** PostgreSQL 16  
**Herramientas:** pgAdmin 4, psql, PowerShell y OpenSSL  
**Base de datos:** `db_unidad02_carlos_romero`

## Objetivo general

Implementar y verificar mecanismos de protección criptográfica en PostgreSQL para reducir los riesgos asociados al almacenamiento de credenciales, tratamiento de información sensible y transmisión de datos entre cliente y servidor.

## 1. Introducción

La seguridad de una base de datos no depende exclusivamente de la creación de usuarios, roles y permisos. También es necesario proteger las credenciales, la información confidencial, las claves criptográficas y las comunicaciones.

En este laboratorio se estudiaron las diferencias entre hash y cifrado reversible mediante la extensión `pgcrypto`. Además, se configuró TLS en PostgreSQL 16 y se comprobó su funcionamiento con pgAdmin 4 y psql.

Todas las credenciales y los datos empleados como ejemplos en los scripts son ficticios y fueron utilizados con fines exclusivamente educativos.

## 2. Protección de credenciales

Se creó la tabla `usuarios_insegura` para demostrar los riesgos de almacenar contraseñas en texto claro.

Posteriormente se creó la tabla `usuarios_segura`, donde se aplicó `crypt()` junto con `gen_salt('bf')` para proteger una contraseña de prueba mediante bcrypt.

La verificación de la contraseña correcta produjo un resultado verdadero, mientras que la incorrecta produjo uno falso.

También se comprobó que dos hashes de una misma contraseña pueden ser diferentes debido al uso de sales aleatorias.

El hash de contraseñas es un mecanismo diseñado para verificar credenciales sin recuperar la contraseña original. Esto lo diferencia del cifrado reversible.

**Código:** [01-credenciales.sql](sql/01-credenciales.sql)  
**Evidencia:** [Protección de credenciales](evidencias/01-credenciales.md)

## 3. Protección de datos sensibles

Se creó la tabla `clientes_protegidos` con una columna de tipo `BYTEA` para almacenar un RFC ficticio en forma cifrada.

Se utilizó `pgp_sym_encrypt()` para cifrar el dato y `pgp_sym_decrypt()` para demostrar su recuperación mediante una frase de prueba.

La consulta con una frase incorrecta produjo un error de descifrado.

El ejercicio permitió distinguir el hash de contraseñas del cifrado reversible, así como identificar los riesgos de escribir claves reales directamente en consultas SQL.

**Código:** [02-cifrado-datos.sql](sql/02-cifrado-datos.sql)  
**Evidencia:** [Cifrado de información sensible](evidencias/02-cifrado-datos.md)

## 4. Protección de comunicaciones mediante TLS

Inicialmente se verificó que el parámetro `ssl` de PostgreSQL estaba deshabilitado y que la conexión consultada no utilizaba TLS.

Posteriormente se generó un certificado autofirmado de laboratorio con OpenSSL y se configuraron los archivos correspondientes en PostgreSQL 16.

Se protegieron los permisos de la clave privada, se respaldó el archivo original de configuración y se habilitó TLS en `postgresql.conf`.

Después de reiniciar el servicio, `SHOW ssl;` devolvió `on`.

La vista `pg_stat_ssl` confirmó una conexión cifrada mediante TLS 1.3 y el algoritmo `TLS_AES_256_GCM_SHA384`.

La conexión desde PowerShell utilizando `psql` y `sslmode=require` confirmó los mismos parámetros.

Debe señalarse que `sslmode=require` exige cifrado, pero no proporciona la validación completa de identidad del servidor que ofrece `sslmode=verify-full` con una configuración apropiada de confianza.

**Código:** [03-verificacion-tls.sql](sql/03-verificacion-tls.sql)  
**Evidencia:** [Configuración y verificación de TLS](evidencias/04-tls.md)

## 5. Gestión de claves criptográficas

Se analizó el riesgo de incluir claves de cifrado directamente en scripts, archivos compartidos y repositorios.

Una clave real publicada puede facilitar el descifrado no autorizado de información y permanecer en el historial del sistema de control de versiones.

Por ese motivo, en un entorno productivo se recomienda utilizar un gestor de secretos o KMS, establecer controles de acceso, aplicar rotación y mantener procedimientos de respaldo y revocación.

La clave privada utilizada para el certificado TLS permanece fuera del directorio del proyecto y no debe copiarse al repositorio.

**Evidencias:**

- [Análisis de gestión de claves](evidencias/03-gestion-claves.md)
- [Política mínima de protección de claves](evidencias/10-politica-claves.md)

## 6. Resultados principales

| Actividad | Resultado |
|---|---|
| Almacenamiento en texto claro | Se identificó la exposición de una contraseña ficticia |
| Hash con bcrypt | Se generó una representación no reversible de la contraseña |
| Verificación de contraseña | La correcta devolvió true y la incorrecta false |
| Sal aleatoria | Se obtuvieron hashes diferentes para la misma contraseña |
| Cifrado de RFC | El dato se almacenó en formato binario |
| Descifrado con frase correcta | Se comprobó el funcionamiento del mecanismo durante la práctica |
| Descifrado con frase incorrecta | Se obtuvo un error de clave incorrecta o dato corrupto |
| Estado inicial de TLS | ssl = off |
| Estado final de TLS | ssl = on |
| Sesión TLS activa | ssl = true |
| Versión negociada | TLSv1.3 |
| Algoritmo de conexión | TLS_AES_256_GCM_SHA384 |
| Conexión mediante psql | Se estableció una conexión TLS con sslmode=require |
| Revisión preliminar de secretos | Sin coincidencias en los patrones revisados |

## 7. Problemas encontrados y soluciones

### Configuración del entorno PostgreSQL

Durante la preparación del laboratorio fue necesario instalar y configurar PostgreSQL 16 en Windows, identificar el directorio de datos y verificar el funcionamiento del servicio.

### Activación de TLS

Inicialmente PostgreSQL tenía el parámetro `ssl` deshabilitado. Se generó un certificado de laboratorio, se configuraron los archivos de certificado y clave, se ajustaron permisos y se modificó `postgresql.conf`.

Después del reinicio, las consultas confirmaron el funcionamiento de TLS.

### Consulta SQL desde PowerShell

Durante la verificación mediante psql se presentó un error de sintaxis porque algunas palabras de una consulta quedaron unidas al pegar el código.

El problema se corrigió ejecutando la consulta SQL en una sola línea. La verificación final devolvió `t`, `TLSv1.3` y el algoritmo de cifrado negociado.

### Revisión de secretos

La primera búsqueda de posibles secretos se ejecutó accidentalmente desde `C:\Windows\system32`, por lo que aparecieron resultados ajenos al laboratorio.

Al repetirla dentro de la carpeta correcta del LAB-02, no se encontraron coincidencias con los patrones utilizados.

La revisión deberá repetirse cuando estén completos todos los archivos y antes de publicar el repositorio.

## 8. Conclusiones

El laboratorio permitió comprobar que existen distintos mecanismos para proteger los componentes de una base de datos.

El hash especializado con sal es adecuado para proteger contraseñas porque permite verificar una credencial sin almacenar su valor original.

El cifrado simétrico permite proteger información sensible que debe recuperarse posteriormente, pero requiere una gestión apropiada de claves.

TLS protege los datos durante la comunicación. Las pruebas con PostgreSQL 16 permitieron verificar una conexión utilizando TLS 1.3.

En un entorno productivo sería necesario complementar estas medidas con validación de identidad del servidor, controles de acceso, auditoría, políticas de gestión de claves, protección de respaldos y procedimientos de respuesta ante incidentes.

## 9. Preguntas de reflexión

### 1. ¿Qué riesgos presenta una contraseña almacenada en texto claro?

Cualquier persona que consiga acceso de lectura a la tabla podría obtener inmediatamente la contraseña. Esto facilita accesos no autorizados y aumenta el impacto de una filtración.

### 2. ¿En qué se diferencian el hash y el cifrado?

El hash de contraseñas está diseñado para verificar credenciales sin recuperar el valor original. El cifrado transforma información de forma reversible y permite recuperarla mediante la clave correspondiente.

### 3. ¿Por qué cifrar una columna no reemplaza los controles de acceso?

Porque el cifrado protege la confidencialidad del dato, pero no establece por sí solo quién puede consultar, modificar o eliminar registros. Se necesitan permisos para restringir esas operaciones.

### 4. ¿Por qué TLS no reemplaza la autorización en PostgreSQL?

TLS protege el canal de comunicación, pero no determina qué tablas u operaciones puede utilizar un usuario. La autorización sigue siendo responsabilidad de los roles y permisos de PostgreSQL.

### 5. ¿Qué consecuencias tendría perder una clave de cifrado?

La organización podría perder la capacidad de recuperar la información cifrada. Si no existe una copia protegida de la clave, la pérdida de datos podría ser irreversible.

### 6. ¿Qué hacer si una clave se publica accidentalmente en Git?

Debe considerarse potencialmente comprometida. Es necesario evaluar el incidente, revocar o rotar la clave y revisar si existe información que deba volver a cifrarse. Eliminar el archivo no garantiza borrar todas las copias de su historial.

### 7. ¿Por qué un repositorio privado no es adecuado para almacenar secretos?

Porque pueden existir accesos no autorizados, errores de configuración, copias, colaboradores o filtraciones. El carácter privado del repositorio no sustituye a un gestor de secretos.

### 8. ¿Qué cambia entre proteger datos almacenados y datos transmitidos?

La protección en reposo protege la información almacenada en tablas, archivos o respaldos. La protección en tránsito protege la información mientras se comunica entre cliente y servidor, generalmente mediante TLS.

### 9. ¿Por qué es importante administrar correctamente las claves?

Porque incluso un algoritmo criptográfico robusto puede resultar inútil si las claves quedan expuestas, se pierden o son utilizadas por personas no autorizadas.

### 10. ¿Cómo reforzarías la seguridad de los respaldos?

Aplicaría cifrado de los respaldos, acceso restringido, almacenamiento protegido, pruebas de restauración, políticas de conservación y gestión segura de las claves utilizadas para cifrarlos.

## 10. Archivos y evidencias

### Scripts SQL

- [01 — Protección de credenciales](sql/01-credenciales.sql)
- [02 — Cifrado de datos](sql/02-cifrado-datos.sql)
- [03 — Verificación de TLS](sql/03-verificacion-tls.sql)

### Documentación de evidencias

- [01 — Credenciales](evidencias/01-credenciales.md)
- [02 — Cifrado de datos](evidencias/02-cifrado-datos.md)
- [03 — Gestión de claves](evidencias/03-gestion-claves.md)
- [04 — TLS](evidencias/04-tls.md)
- [07 — Comparación de mecanismos](evidencias/07-comparacion.md)
- [08 — Análisis de escenario](evidencias/08-analisis-escenario.md)
- [10 — Política de claves](evidencias/10-politica-claves.md)

Las capturas se almacenan en `evidencias/imagenes/` y se insertan directamente dentro de los documentos Markdown correspondientes.

## 11. Referencia

FIC Academy. LAB-02 — Cifrado, credenciales y comunicaciones seguras.

https://academy.ficlabs.com.mx/materias/dba/unidad-02/laboratorios/laboratorio-2-cifrado-credenciales-y-comunicaciones-seguras/

**Nota de seguridad:** Este laboratorio es educativo. Los datos y frases de ejemplo son ficticios; ningún archivo de la entrega debe contener secretos reales.
