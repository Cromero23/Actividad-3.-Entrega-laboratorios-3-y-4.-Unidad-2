# LAB-03 — Actividad 10: Política de retención de datos

## Objetivo

Analizar la importancia de establecer periodos de conservación adecuados para la información personal almacenada en PostgreSQL, considerando los principios de minimización, finalidad y responsabilidad en el tratamiento de datos.

## Escenario

La empresa ficticia Comercializadora Norte S.A. de C.V. propone conservar indefinidamente todos los datos personales de sus clientes, argumentando que podrían resultar útiles en el futuro.

Esta propuesta requiere analizar los riesgos asociados con la conservación excesiva de información y establecer criterios para determinar cuánto tiempo debe mantenerse cada categoría de datos.

## 1. ¿Es compatible la conservación indefinida con el principio de minimización?

No. Conservar información personal indefinidamente sin una finalidad específica y justificada es contrario al principio de minimización y a una gestión adecuada del ciclo de vida de los datos.

La organización debe conservar únicamente la información necesaria para cumplir las finalidades autorizadas y las obligaciones legales aplicables.

En nuestro laboratorio, por ejemplo, no sería adecuado mantener indefinidamente el correo electrónico de un cliente para promociones cuando esa finalidad ya terminó o cuando procede su oposición a dicho tratamiento.

La información necesaria para facturación puede estar sujeta a obligaciones de conservación distintas de las que corresponden a datos utilizados para campañas comerciales.

## 2. ¿Qué riesgos genera conservar información innecesaria?

Conservar datos personales durante más tiempo del necesario incrementa la cantidad de información que puede resultar comprometida ante un incidente de seguridad.

Entre los principales riesgos se encuentran la exposición de datos personales, el acceso no autorizado, el uso de información desactualizada, el tratamiento para finalidades no autorizadas y mayores dificultades para atender solicitudes de derechos ARCO.

También puede generar costos adicionales de almacenamiento, respaldo, protección y administración.

En consecuencia, la conservación innecesaria aumenta tanto los riesgos de privacidad como la complejidad operativa de la organización.

## 3. ¿Qué debería determinar la organización antes de establecer un periodo de retención?

La organización debe identificar la finalidad para la que recopila cada dato, la necesidad de conservarlo, las obligaciones legales aplicables y el momento en que termina su utilidad.

También debe establecer si existen procedimientos de cancelación, bloqueo, anonimización o eliminación que deban aplicarse al concluir el periodo correspondiente.

Para definir estos plazos, el DBA debe coordinarse con las áreas responsables de privacidad, cumplimiento, administración y asesoría jurídica.

No corresponde al DBA establecer unilateralmente los periodos legales de conservación.

### Propuesta de criterios para nuestra base de datos

| Dato | Finalidad principal | Criterio de conservación propuesto |
|---|---|---|
| `id` | Identificación interna | Mientras resulte necesario para la gestión y trazabilidad del registro |
| `nombre` | Atención y administración del cliente | Mientras exista la finalidad autorizada o una obligación de conservación |
| `correo` | Contacto y soporte | Mientras sea necesario para comunicaciones autorizadas |
| `telefono` | Contacto alternativo | Mientras continúe siendo necesario para atención |
| `rfc` | Facturación | Conforme a las obligaciones fiscales aplicables |
| `edad` | Análisis estadístico | Evitar conservarla individualmente cuando basten rangos o datos agregados |
| `ciudad` | Estadísticas y operaciones | Mientras exista una finalidad justificada |
| `codigo_postal` | Logística o distribución | Mientras sea necesario para la finalidad autorizada |
| `fecha_alta` | Gestión del ciclo de vida | Mientras sea necesaria para administrar el registro y acreditar obligaciones |

Los criterios anteriores son propuestas para el ejercicio académico. No constituyen plazos legales definitivos.

## 4. ¿Qué información debería documentarse para justificar el periodo seleccionado?

Para justificar los periodos de conservación, la organización debería documentar la categoría de información, la finalidad del tratamiento, el responsable, la base legal aplicable, el periodo seleccionado y los motivos que lo justifican.

También debería establecer qué ocurre cuando finaliza el plazo, quién autoriza la eliminación o bloqueo y cómo se registra la ejecución del procedimiento.

La documentación debe contemplar los respaldos, copias derivadas, registros de auditoría y sistemas externos que puedan contener información personal.

Además, deben definirse procedimientos para revisar periódicamente la vigencia de la política y actualizarla cuando cambien las obligaciones o finalidades del tratamiento.

## Propuesta de aplicación técnica en PostgreSQL

En nuestra base de datos `db_unidad02_carlos_romero`, la columna `fecha_alta` permite conocer cuándo se registró cada cliente. Sin embargo, esta fecha por sí sola no determina cuándo deben eliminarse sus datos.

Para implementar una política de retención sería necesario asociar las finalidades correspondientes, establecer criterios de conservación aprobados, identificar los registros que hayan cumplido sus plazos y verificar si existe alguna obligación que impida su eliminación inmediata.

Posteriormente podrían utilizarse consultas SQL, procedimientos programados o tareas de mantenimiento para aplicar las medidas autorizadas.

Estas operaciones deberían contar con controles de acceso, revisión de dependencias, auditoría y mecanismos de recuperación.

**Durante esta actividad no se ejecutaron instrucciones de eliminación**, ya que el objetivo fue diseñar y justificar la política antes de implementar cambios en los registros.

## Análisis

Una política de retención adecuada permite reducir la acumulación innecesaria de información y facilita la atención de solicitudes de privacidad.

El tiempo de conservación debe depender de la finalidad y de las obligaciones que resulten aplicables, no únicamente de la posibilidad de que un dato sea útil en el futuro.

La participación del DBA es importante para traducir las decisiones organizacionales en controles técnicos, pero los criterios de cumplimiento deben ser aprobados por las áreas responsables.

## Conclusión

La conservación indefinida de todos los datos personales sin justificación representa un riesgo para la privacidad y la seguridad de la información.

Es necesario establecer políticas documentadas que definan cuánto tiempo debe conservarse cada categoría de datos, quién es responsable de su administración y qué acciones deben realizarse cuando termine su periodo de utilidad.

En PostgreSQL, estas políticas pueden implementarse mediante procedimientos técnicos de identificación, bloqueo y eliminación controlada, complementados con controles administrativos y auditoría.