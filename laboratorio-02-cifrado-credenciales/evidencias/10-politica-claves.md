
# Evidencia 10 — Política mínima de protección de claves criptográficas

## Objetivo

Establecer reglas básicas para administrar de manera segura las claves criptográficas utilizadas por los sistemas de bases de datos.

## Procedimiento

Se elaboró una política de ocho reglas que contempla generación, almacenamiento, acceso, rotación, respaldo, revocación, respuesta ante exposición accidental y eliminación de claves.

## Resultado obtenido

### Regla 1. Generación segura

Todas las claves criptográficas deberán generarse utilizando mecanismos criptográficamente seguros y fuentes de aleatoriedad apropiadas. No se permitirán claves predecibles o reutilizadas sin justificación.

### Regla 2. Almacenamiento protegido

Las claves deberán conservarse mediante soluciones especializadas, como gestores de secretos o KMS. No deberán incorporarse claves reales a scripts SQL, código fuente, documentación ni repositorios Git.

### Regla 3. Control de acceso

El acceso a las claves deberá limitarse a las personas, aplicaciones y servicios que realmente lo necesiten, de acuerdo con el principio de mínimo privilegio.

### Regla 4. Rotación

Las claves deberán renovarse de acuerdo con su criticidad, el nivel de riesgo y las políticas de la organización. Ante una sospecha de compromiso deberá iniciarse su reemplazo.

### Regla 5. Respaldo y recuperación

Las claves necesarias para descifrar información conservada deberán contar con respaldos protegidos. Los procedimientos de recuperación deberán documentarse y verificarse periódicamente.

### Regla 6. Revocación

Las claves comprometidas, obsoletas o que ya no deban utilizarse deberán revocarse o deshabilitarse según corresponda. Los sistemas dependientes deberán actualizarse para impedir su utilización.

### Regla 7. Exposición accidental

Cuando una clave se publique accidentalmente en un repositorio o archivo no autorizado, deberá considerarse potencialmente comprometida. Se notificará el incidente, se evaluará su impacto y se procederá a rotar o revocar la clave.

### Regla 8. Eliminación segura

Las claves que finalicen su ciclo de vida deberán eliminarse mediante procedimientos apropiados, comprobando previamente que no sean necesarias para recuperar información que deba conservarse.

## Análisis

Una clave criptográfica expuesta puede anular la protección proporcionada por un algoritmo de cifrado seguro.

Por ello, su administración debe contemplar todo su ciclo de vida, desde la generación hasta su eliminación definitiva.

La política también debe acompañarse de controles técnicos, registros de auditoría y asignación de responsabilidades.

## Conclusión

La aplicación de una política de gestión de claves permite reducir los riesgos de exposición, pérdida o uso no autorizado de información cifrada. La seguridad de las claves es tan importante como la elección del algoritmo criptográfico.
