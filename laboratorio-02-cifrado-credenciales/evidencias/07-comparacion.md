
# Evidencia 07 — Comparación de mecanismos de protección

## Objetivo

Diferenciar los mecanismos empleados para proteger contraseñas, información almacenada, comunicaciones, respaldos y claves criptográficas.

## Procedimiento

Se analizaron las actividades prácticas realizadas con `pgcrypto` y TLS, identificando qué mecanismo corresponde a cada necesidad de seguridad.

## Resultado obtenido

| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash con sal mediante Argon2id o bcrypt | Reduce la exposición de contraseñas ante filtraciones. |
| RFC almacenado en una tabla | Cifrado simétrico | Protege la confidencialidad del RFC almacenado. |
| Consulta enviada desde un cliente al servidor | TLS con validación del servidor | Protege la confidencialidad e integridad de los datos transmitidos. |
| Respaldo de una base de datos | Cifrado de respaldos y controles de acceso | Impide la lectura no autorizada de los respaldos. |
| Clave criptográfica | Gestor de secretos o KMS | Protege el almacenamiento, uso y ciclo de vida de las claves. |

## Análisis

La protección de datos en reposo se enfoca en información almacenada en tablas, archivos, discos o respaldos. La protección de datos en tránsito se enfoca en información que viaja entre dos sistemas.

Las contraseñas requieren un mecanismo de hash especializado y no deben almacenarse mediante cifrado reversible como si fueran datos que necesiten recuperarse.

En cambio, un RFC que deba consultarse posteriormente puede requerir cifrado reversible y una adecuada gestión de claves.

TLS no sustituye al cifrado de datos almacenados, al igual que el cifrado de una columna no protege automáticamente su transmisión por la red.

## Conclusión

Cada mecanismo criptográfico atiende una necesidad diferente. Una estrategia adecuada debe combinar protección de credenciales, cifrado de datos, TLS, control de acceso y administración segura de claves.
