
# Evidencia 03 — Gestión de claves criptográficas

## Objetivo

Identificar los riesgos de almacenar claves criptográficas directamente en scripts SQL y proponer medidas para su administración segura.

## Procedimiento

Se analizó el uso de una frase de cifrado escrita directamente dentro de una consulta `pgp_sym_decrypt()`.

El ejemplo utilizó únicamente la frase ficticia `CLAVE-DE-PRUEBA`.

La actividad permitió identificar los riesgos de divulgar claves en repositorios, documentación, registros de ejecución y archivos compartidos.

## Resultado obtenido

Se identificó que una consulta SQL puede funcionar técnicamente y, aun así, representar una práctica insegura si contiene una clave real.

Se determinó que un archivo de demostración que exponga una clave no debe conservarse como parte de la entrega final.

Las claves privadas utilizadas por PostgreSQL para TLS permanecieron fuera del directorio del proyecto y no se incluyeron en los archivos preparados para GitHub.

## Análisis

Si una organización publica accidentalmente una clave real utilizada para cifrar información, una persona no autorizada podría utilizarla para intentar recuperar datos protegidos.

Eliminar la clave de un archivo después de publicarlo no garantiza eliminarla del historial de Git. Por ese motivo, una clave comprometida debe rotarse o revocarse según corresponda.

En un entorno real se recomienda:

- Emplear un gestor de secretos o un KMS.
- Aplicar el principio de mínimo privilegio.
- Controlar quién puede utilizar las claves.
- Establecer procedimientos de rotación y revocación.
- Mantener respaldos protegidos de las claves necesarias.
- Evitar claves reales en consultas, documentación y capturas.

## Conclusión

La gestión de claves forma parte esencial de la seguridad criptográfica. Utilizar un algoritmo seguro no es suficiente si la clave se encuentra expuesta. Los secretos reales deben mantenerse fuera de los repositorios y gestionarse mediante controles específicos.
