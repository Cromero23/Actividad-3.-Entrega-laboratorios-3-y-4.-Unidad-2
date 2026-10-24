# LAB-03 — Actividad 8: Derecho de cancelación y ciclo de vida de los datos

## Objetivo

Analizar las implicaciones técnicas de una solicitud de cancelación de datos personales, considerando que la información puede encontrarse en diversas tablas, respaldos y sistemas relacionados.

## Escenario

Un cliente solicita la cancelación de sus datos personales y el área responsable autoriza la solicitud.

Antes de realizar cualquier eliminación en PostgreSQL, el DBA debe identificar dónde se almacena o utiliza la información, determinar posibles dependencias y comprobar si existen obligaciones que justifiquen conservar determinados registros.

## Análisis del ciclo de vida de los datos

Durante el laboratorio se identificaron las siguientes estructuras:

- `public.clientes`: tabla principal con datos personales de los clientes.
- `public.clientes_soporte`: tabla derivada que almacena datos de contacto utilizados por soporte.
- `public.v_analitica_clientes`: vista que obtiene información de la tabla principal para analítica, sin crear una copia física independiente de los registros.

Además, en un entorno empresarial deben revisarse otros posibles destinos de información, como respaldos, réplicas, reportes, exportaciones, registros de auditoría y sistemas externos.

No se ha comprobado que todos estos destinos existan en nuestro entorno local; se consideran como parte del análisis de riesgos.

## Mapa del ciclo de vida

```text
                   public.clientes
                          |
          +---------------+---------------+
          |               |               |
          v               v               v
 clientes_soporte   v_analitica_clientes  Otros destinos
  (copia física)       (vista SQL)         potenciales
                                             |
                              +--------------+--------------+
                              |              |              |
                           Respaldos      Reportes       Exportaciones
                              |
                        Posibles réplicas
                        y sistemas externos
```

## ¿Por qué eliminar un registro de una tabla no significa que toda la información haya desaparecido?

Eliminar un registro de `public.clientes` no garantiza que todos sus datos hayan desaparecido de la organización.

En nuestro laboratorio, la tabla `clientes_soporte` contiene una copia de ciertos datos personales. Por tanto, la eliminación del registro principal no implica automáticamente la eliminación de esa copia.

La vista `v_analitica_clientes`, en cambio, consulta información de la tabla original y no conserva por sí misma otra copia física de los registros.

En un sistema empresarial también pueden existir respaldos históricos, exportaciones, reportes o aplicaciones externas que mantengan información previamente obtenida.

Por este motivo, una solicitud de cancelación necesita un procedimiento que permita identificar los distintos lugares donde se utiliza la información, determinar qué datos deben bloquearse o eliminarse y verificar la ejecución de las medidas autorizadas.

## Procedimiento recomendado

1. Verificar la identidad del titular y confirmar la autorización de la solicitud.
2. Identificar todas las tablas, aplicaciones y sistemas que utilizan sus datos.
3. Revisar las obligaciones legales o administrativas de conservación.
4. Determinar qué datos pueden eliminarse y cuáles requieren bloqueo o conservación justificada.
5. Ejecutar las operaciones autorizadas de manera controlada.
6. Revisar los respaldos y las políticas para impedir una restauración indebida de datos cancelados.
7. Registrar las acciones realizadas y sus responsables.
8. Verificar los resultados y comunicar la atención de la solicitud al área correspondiente.

## Análisis

El derecho de cancelación requiere coordinar controles técnicos y administrativos. El DBA puede ejecutar operaciones sobre las tablas, pero no debe decidir de forma independiente si existen obligaciones legales de conservación.

Eliminar información sin analizar dependencias puede generar inconsistencias. Asimismo, conservar copias innecesarias incrementa el riesgo de exposición de datos personales.

En un entorno real deben existir procedimientos documentados para gestionar el ciclo de vida de la información y responder a las solicitudes de los titulares.

## Conclusión

La cancelación de datos personales no consiste únicamente en ejecutar una instrucción `DELETE`. Requiere identificar todas las ubicaciones donde se conserva o procesa la información, evaluar las obligaciones aplicables y aplicar las medidas correspondientes de manera controlada y verificable.

Este análisis demuestra la importancia del gobierno de datos, la trazabilidad y la coordinación entre el DBA y las áreas responsables de privacidad y cumplimiento.