
# Evidencia 08 — Análisis de un escenario de seguridad

## Objetivo

Evaluar los riesgos de una organización que administra información sensible en PostgreSQL y proponer mecanismos adecuados para protegerla.

## Procedimiento

Se analizó el escenario de una empresa que almacena nombres, correos electrónicos, contraseñas, RFC, información financiera y claves criptográficas.

Aunque la empresa cuenta con usuarios y roles configurados, presenta deficiencias en el almacenamiento de contraseñas, cifrado de datos, validación del servidor, gestión de claves y protección de respaldos.

## Resultado obtenido

### 1. ¿Cuáles son los principales riesgos?

Los riesgos principales son la exposición de contraseñas almacenadas en texto claro, la divulgación de RFC y datos financieros, la interceptación de comunicaciones sin autenticación adecuada del servidor, el uso indebido de claves criptográficas publicadas en scripts y el acceso no autorizado a respaldos sin cifrar.

Estas deficiencias pueden facilitar filtraciones de datos, accesos no autorizados y pérdida de confidencialidad.

### 2. ¿Qué mecanismo utilizarías para cada elemento?

| Elemento | Medida recomendada |
|---|---|
| Nombres y correos electrónicos | Control de acceso, minimización de datos y cifrado cuando corresponda |
| Contraseñas | Hash especializado con sal, preferentemente Argon2id o bcrypt |
| RFC | Cifrado simétrico con gestión segura de claves |
| Información financiera | Cifrado, controles de acceso y auditoría |
| Claves criptográficas | Gestor de secretos o KMS |
| Conexiones | TLS con validación adecuada del servidor |
| Respaldos | Cifrado, acceso restringido y almacenamiento protegido |

### 3. ¿Cuál problema consideras más crítico y por qué?

Uno de los problemas más críticos es almacenar contraseñas en texto claro. Una filtración permitiría conocer directamente las credenciales de los usuarios y podría facilitar accesos a otros servicios cuando se reutilizan las contraseñas.

La exposición de claves criptográficas también es especialmente grave porque puede comprometer grandes cantidades de información cifrada.

### 4. ¿Los usuarios y permisos correctamente configurados eliminan esos riesgos?

No. Los usuarios y roles controlan el acceso a los recursos, pero no sustituyen el hash de contraseñas, el cifrado de información, TLS ni la gestión de claves.

Si una cuenta autorizada resulta comprometida, un atacante podría consultar información almacenada en texto claro. Además, los permisos de PostgreSQL no protegen automáticamente los respaldos que se encuentran fuera del servidor.

Por ello, se requiere una estrategia de seguridad en profundidad.

## Análisis

El escenario demuestra que la seguridad no depende de un único control. Las medidas criptográficas y los mecanismos de autorización deben complementarse.

También es necesario considerar la protección de los respaldos, el ciclo de vida de las claves y la configuración de las conexiones.

## Conclusión

Una organización debe implementar una estrategia integral de protección de datos. La combinación de controles de acceso, hash de contraseñas, cifrado, TLS, protección de respaldos y gestión segura de claves permite reducir los riesgos identificados.
