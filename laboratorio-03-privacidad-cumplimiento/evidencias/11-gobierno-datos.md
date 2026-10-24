# LAB-03 — Actividad 11: Matriz de gobierno de datos

## Objetivo

Diseñar una matriz de gobierno de datos que establezca las finalidades, responsabilidades, controles de acceso, medidas de protección, criterios de retención y acciones al finalizar el ciclo de vida de la información personal almacenada en PostgreSQL.

## 1. Introducción

El gobierno de datos permite establecer responsabilidades y reglas para administrar la información de una organización de manera segura, ordenada y conforme a las finalidades autorizadas.

En el escenario de la empresa ficticia Comercializadora Norte S.A. de C.V., la base de datos contiene información utilizada por diferentes áreas, como atención al cliente, facturación y analítica.

Sin embargo, no todas las áreas necesitan acceder a los mismos campos. Por esta razón, es necesario identificar quién debe administrar la información, quién puede consultarla y qué medidas de protección deben aplicarse.

## 2. Matriz de gobierno de datos

La siguiente matriz corresponde a los siete campos principales de la tabla `public.clientes`.

| Dato | Finalidad | Responsable | Usuarios autorizados | Protección | Retención | Acción al finalizar |
|---|---|---|---|---|---|---|
| `nombre` | Identificación del cliente y atención de solicitudes | Atención al cliente | Personal de soporte y facturación autorizado | Roles, permisos y acceso limitado | Mientras exista una finalidad operativa o una obligación de conservación | Eliminar o bloquear conforme al procedimiento autorizado |
| `correo` | Comunicación con clientes y atención de solicitudes | Atención al cliente | Soporte y otras áreas con autorización específica | Restricción de acceso, validación y actualización controlada | Mientras sea necesario para comunicaciones autorizadas | Eliminar, bloquear o desvincular de finalidades terminadas |
| `telefono` | Contacto alternativo con el cliente | Atención al cliente | Personal de soporte autorizado | Control de acceso y minimización | Mientras permanezca vigente la necesidad de contacto | Eliminar o bloquear cuando deje de ser necesario |
| `rfc` | Identificación fiscal y facturación | Facturación | Personal autorizado de facturación | Acceso restringido, cifrado cuando corresponda y auditoría | Conforme a las obligaciones fiscales aplicables | Bloquear durante conservación obligatoria y eliminar cuando proceda |
| `edad` | Elaboración de estadísticas por rangos | Analítica | Analistas autorizados mediante vistas o datos agregados | Generalización por rangos y acceso limitado | Evitar conservación individual cuando no sea necesaria | Eliminar el dato individual o conservar únicamente estadísticas suficientemente protegidas |
| `ciudad` | Estadísticas regionales y operaciones justificadas | Analítica y operaciones | Analistas con información limitada y personal operativo autorizado | Minimización, agregación y vistas restringidas | Mientras exista una finalidad documentada | Eliminar o transformar en información agregada según corresponda |
| `codigo_postal` | Logística y análisis regional | Operaciones y logística | Personal operativo autorizado; analítica solo con región general | Restricción de acceso y generalización por región | Mientras sea necesario para la finalidad autorizada | Eliminar o generalizar cuando deje de ser necesario |

**Nota:** Los criterios de retención son propuestas académicas. Los plazos definitivos deben establecerse de acuerdo con las obligaciones y finalidades aplicables.

## 3. Responsabilidades de los diferentes roles

### Atención al cliente

Debe consultar únicamente los datos necesarios para identificar y contactar al cliente, principalmente nombre, correo y teléfono.

No requiere acceso general al RFC ni a la edad para atender solicitudes ordinarias.

### Facturación

Debe acceder a la información estrictamente necesaria para generar y administrar documentos fiscales.

El RFC requiere una protección adecuada y su conservación debe responder a las obligaciones que correspondan.

### Analítica

Debe trabajar preferentemente con información agregada o generalizada, evitando identificar directamente a cada cliente.

Durante el laboratorio se creó el rol `analista` y la vista `v_analitica_clientes`, que limita los campos consultables a `ciudad` y `rango_edad`.

También se comprobó que el rol `analista` cuenta con permiso `SELECT` sobre esa vista, pero no sobre la tabla `clientes`.

### Administrador de bases de datos (DBA)

Es responsable de implementar y mantener controles técnicos de seguridad, como permisos, roles, vistas, respaldos y mecanismos de auditoría.

El acceso administrativo necesario para realizar mantenimiento no significa que deba utilizar los datos personales para finalidades ajenas a sus funciones.

### Dirección y áreas responsables de privacidad

Deben establecer y aprobar las políticas de tratamiento, acceso y conservación de información, con la asesoría jurídica o de cumplimiento que corresponda.

Las decisiones sobre finalidades y periodos de conservación no deben quedar exclusivamente a cargo del DBA.

## 4. Relación con las actividades realizadas

Durante el LAB-03 se aplicaron diferentes medidas relacionadas con el gobierno de datos:

**Minimización:** se creó la tabla `clientes_soporte` con únicamente cuatro campos, en lugar de copiar los nueve de la tabla original.

**Separación por finalidad:** se elaboraron consultas estadísticas por ciudad, rangos de edad y región postal sin mostrar identificadores directos.

**Control de acceso:** se creó el rol `analista` y se le otorgó acceso de lectura únicamente a la vista `v_analitica_clientes`.

**Derecho de acceso:** se comprobó que es posible localizar el registro de un cliente específico.

**Derecho de rectificación:** se actualizó el correo de Ana López y se sincronizó la modificación con la tabla `clientes_soporte`.

**Cancelación y oposición:** se analizaron los procedimientos que deben seguirse para atender solicitudes de los titulares.

**Retención:** se propusieron criterios para evitar conservar información personal de manera indefinida e injustificada.

Los permisos del rol `analista` son controles implementados y comprobados durante el laboratorio. Los demás permisos y políticas descritos en esta matriz constituyen propuestas de gobierno de datos y no deben interpretarse como configuraciones ya implementadas en PostgreSQL.

## 5. Análisis de resultados

La matriz permite identificar que los campos de una base de datos no deben administrarse de la misma manera, debido a que cumplen distintas finalidades y presentan diferentes necesidades de protección.

Por ejemplo, el RFC se relaciona principalmente con facturación, mientras que el correo y teléfono son utilizados para contactar al cliente.

Asimismo, el área de analítica puede utilizar información agregada sin necesidad de acceder a los nombres, correos o RFC.

Establecer responsabilidades funcionales permite aplicar el principio de mínimo privilegio y reducir la exposición innecesaria de datos personales.

También resulta importante definir procedimientos de retención y eliminación, considerando que la información puede existir en varias tablas, respaldos o sistemas relacionados.

La combinación de políticas administrativas y controles técnicos permite mejorar la trazabilidad y la protección de la información.

## 6. Conclusión

La matriz de gobierno de datos permite definir cómo debe administrarse la información personal a lo largo de su ciclo de vida.

Su aplicación facilita identificar las finalidades autorizadas, delimitar responsabilidades, restringir accesos y establecer criterios de conservación adecuados.

El gobierno de datos no depende exclusivamente de herramientas técnicas. Requiere coordinación entre el DBA, las áreas operativas, los responsables de privacidad y la dirección de la organización.

De esta manera, PostgreSQL puede utilizarse como parte de una estrategia integral de protección de datos, en la que la seguridad técnica y las decisiones administrativas se complementan.