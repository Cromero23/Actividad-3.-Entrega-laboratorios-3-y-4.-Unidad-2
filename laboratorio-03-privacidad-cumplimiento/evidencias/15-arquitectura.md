# LAB-03 — Actividad 15: Propuesta de arquitectura de datos protegidos

## Objetivo

Diseñar una arquitectura conceptual para la administración de datos personales en PostgreSQL, separando la información de acuerdo con su finalidad y estableciendo controles técnicos y administrativos relacionados con acceso, minimización, confidencialidad, retención, trazabilidad, eliminación y atención de los derechos ARCO.

## 1. Introducción

La administración adecuada de datos personales requiere que las organizaciones establezcan estructuras y mecanismos de seguridad adaptados a las necesidades de cada área.

No todos los departamentos necesitan acceder a la misma información. Mientras que atención al cliente requiere datos de contacto, analítica necesita principalmente información estadística y auditoría requiere registros que permitan verificar las operaciones realizadas.

Por esta razón, se propone una arquitectura que separe la información en tres componentes principales: operación, analítica y auditoría.

La propuesta se basa en el escenario de la empresa ficticia Comercializadora Norte S.A. de C.V. y en las prácticas realizadas durante el LAB-03 utilizando PostgreSQL 16.

## 2. Esquema conceptual de la arquitectura

La arquitectura propuesta divide el tratamiento de datos de la siguiente manera:

**BASE DE DATOS — PostgreSQL 16**

- **Operación:** información necesaria para soporte, atención al cliente y facturación.
- **Analítica:** información agregada y generalizada para generar estadísticas sin identificar directamente a los clientes.
- **Auditoría:** registros y evidencias de operaciones que permitan verificar accesos, modificaciones y atención de solicitudes.

Los tres componentes se relacionan con un conjunto de políticas de gobierno de datos que determinan quién puede utilizar la información, con qué finalidad, durante cuánto tiempo y qué medidas deben aplicarse al finalizar su ciclo de vida.

### Flujo de información propuesto

| Componente | Origen de información | Tratamiento | Resultado |
|---|---|---|---|
| Operación | Tabla principal `clientes` | Selección de campos necesarios por función | Datos limitados para soporte y facturación |
| Analítica | Datos autorizados de `clientes` | Generalización y agregación | Estadísticas por ciudad, edad y región postal |
| Auditoría | Eventos de acceso y modificación | Registro, protección y revisión | Evidencias de operaciones y trazabilidad |
| Gobierno de datos | Inventario, finalidades y políticas | Autorización y supervisión | Reglas aplicables a los tres componentes |

Esta separación debe permitir que cada proceso acceda únicamente a los datos necesarios para cumplir sus funciones.

## 3. Componente de operación

### Finalidad

Administrar la información utilizada por las áreas operativas para atender solicitudes de clientes y realizar procesos de facturación.

### Datos requeridos

Para atención al cliente se requieren principalmente:

- Identificador interno.
- Nombre.
- Correo electrónico.
- Teléfono, cuando sea necesario.

Para facturación pueden requerirse otros datos, como el RFC y la información fiscal correspondiente.

### Implementación realizada

Durante el laboratorio se creó la tabla `public.clientes_soporte`, que almacena únicamente cuatro columnas:

`id`, `nombre`, `correo` y `telefono`.

Esta estructura demuestra el principio de minimización, porque evita copiar información innecesaria para las funciones ordinarias de soporte.

También se comprobó que, al rectificar el correo de un cliente, era necesario mantener la consistencia entre `clientes` y `clientes_soporte`.

### Controles propuestos

Se recomienda establecer roles diferenciados para soporte y facturación, restringir la consulta de datos fiscales, controlar las modificaciones y proteger las comunicaciones.

También deben definirse procedimientos para sincronizar rectificaciones y gestionar solicitudes de los titulares.

## 4. Componente de analítica

### Finalidad

Proporcionar información estadística para apoyar la toma de decisiones sin exponer innecesariamente los datos personales.

### Datos requeridos

El área de analítica necesita información relacionada con:

- Ciudad.
- Rangos de edad.
- Región postal.
- Cantidades de clientes por categoría.

No necesita consultar directamente nombres, correos electrónicos, teléfonos ni RFC para generar las estadísticas del escenario.

### Implementación realizada

Durante la Actividad 3 se elaboraron consultas SQL que agruparon clientes por ciudad, rango de edad y región postal.

Posteriormente, en la Actividad 4, se creó el rol `analista` y la vista `public.v_analitica_clientes`.

El rol recibió acceso de lectura a esa vista y no a la tabla principal `public.clientes`.

Las verificaciones de privilegios demostraron que el rol podía consultar la vista, pero no tenía permiso directo de lectura sobre la tabla completa.

### Mejoras propuestas

La vista implementada en la práctica presenta ciudad y rango de edad por registro. Aunque elimina identificadores directos, todavía no es una vista completamente agregada.

Para un entorno productivo se recomienda crear vistas que devuelvan conteos estadísticos, evitando exponer registros individuales.

También deberían aplicarse controles para reducir el riesgo de identificación de personas cuando un grupo estadístico contiene muy pocos registros.

## 5. Componente de auditoría

### Finalidad

Mantener trazabilidad sobre las operaciones que afectan a los datos personales, permitiendo verificar qué acciones fueron realizadas, por quién y en qué momento.

### Información que debería registrarse

El sistema de auditoría debería contemplar eventos como:

- Accesos a información personal.
- Modificaciones de datos.
- Cambios en roles y privilegios.
- Solicitudes de derechos ARCO.
- Operaciones autorizadas de eliminación o bloqueo.
- Incidentes de seguridad relevantes.

Los registros deben protegerse contra alteraciones y accesos no autorizados.

### Propuesta de implementación

PostgreSQL puede complementarse con mecanismos de registro y auditoría apropiados para conservar información sobre operaciones administrativas y cambios relevantes.

La organización debe definir qué eventos registrar, quién puede consultar las evidencias y durante cuánto tiempo deben conservarse.

Durante este laboratorio se ejecutaron consultas de rectificación y comprobación de permisos, pero no se implementó un sistema completo de auditoría de operaciones.

Por lo tanto, este componente se presenta como una propuesta de mejora.

## 6. Controles de protección de datos

### 6.1 Control de acceso

Se propone utilizar roles y privilegios diferenciados según las responsabilidades del personal.

Cada área deberá tener acceso exclusivamente a la información necesaria para sus funciones.

En el laboratorio se demostró este mecanismo mediante el rol `analista`, que tiene permiso para consultar `v_analitica_clientes`, pero no acceso directo a `clientes`.

### 6.2 Minimización de datos

Cada tabla, vista y procedimiento deberá utilizar únicamente los campos necesarios para su finalidad.

La tabla `clientes_soporte` constituye un ejemplo práctico, ya que contiene cuatro columnas frente a las nueve de la tabla original.

### 6.3 Protección de información sensible

Los campos que requieran protección reforzada deberán contar con controles de confidencialidad, como permisos restringidos y cifrado cuando resulte apropiado.

Durante el LAB-02 se utilizó la extensión `pgcrypto` para demostrar el cifrado de un RFC ficticio.

También se configuró TLS 1.3 para proteger las comunicaciones con PostgreSQL.

Estos mecanismos técnicos deben complementarse con políticas de administración de claves y validación adecuada de las conexiones.

### 6.4 Retención de información

La organización deberá establecer periodos de conservación documentados para las distintas categorías de datos.

Los periodos tendrán que responder a la finalidad del tratamiento y a las obligaciones legales aplicables.

No se recomienda conservar indefinidamente información personal únicamente porque podría ser útil en el futuro.

### 6.5 Trazabilidad

Las operaciones relevantes deberán contar con registros que permitan identificar al responsable, la fecha, el tipo de acción y, cuando corresponda, la solicitud que justificó su ejecución.

Los registros de auditoría deben protegerse y estar sujetos a sus propias políticas de conservación.

### 6.6 Eliminación controlada

Antes de eliminar datos, deberá verificarse si existen dependencias, copias, respaldos u obligaciones que requieran su conservación.

La eliminación deberá realizarse únicamente cuando corresponda y exista autorización.

También será necesario verificar las copias derivadas y evitar que una restauración de respaldo reintroduzca indebidamente información cancelada.

### 6.7 Atención de derechos ARCO

La arquitectura deberá permitir localizar, consultar, rectificar y gestionar solicitudes de cancelación u oposición relacionadas con los datos personales.

La atención de estas solicitudes requiere procedimientos de verificación de identidad, autorización, ejecución controlada y documentación.

El DBA debe colaborar con las áreas responsables para aplicar los cambios autorizados.

## 7. Flujo propuesto para solicitudes ARCO

La atención de una solicitud deberá seguir un procedimiento controlado.

| Etapa | Responsable principal | Acción |
|---|-------|--------------------------------------------------------|
| Recepción | Área de privacidad | Registrar la solicitud del titular |
| Verificación | Área responsable | Confirmar identidad y procedencia |
| Identificación | DBA y áreas involucradas | Localizar datos en tablas y sistemas |
| Autorización | Privacidad y cumplimiento | Determinar las acciones permitidas |
| Ejecución | Personal técnico autorizado | Aplicar consultas o modificaciones |
| Comprobación | DBA y responsable del tratamiento | Verificar resultados y copias relacionadas |
| Cierre | Área de privacidad | Documentar y comunicar la resolución |

Durante el LAB-03 se realizaron pruebas relacionadas con el derecho de acceso y la rectificación de un correo electrónico.

Las actividades de cancelación y oposición se analizaron conceptualmente, sin eliminar registros de la base de datos.

## 8. Gobierno de datos y responsabilidades

Para que la arquitectura funcione correctamente, deben establecerse responsabilidades claras.

**Atención al cliente:** administrar únicamente los datos necesarios para proporcionar soporte.

**Facturación:** utilizar información fiscal autorizada y cumplir las obligaciones correspondientes.

**Analítica:** elaborar estadísticas utilizando información agregada o limitada.

**DBA:** implementar permisos, vistas, medidas de seguridad, respaldos y mecanismos técnicos de trazabilidad.

**Área de privacidad y cumplimiento:** determinar las reglas relacionadas con finalidades, solicitudes de titulares y conservación de información.

**Dirección:** aprobar políticas, asignar responsabilidades y proporcionar los recursos necesarios para la protección de datos.

La definición de políticas debe realizarse de manera coordinada, evitando que las decisiones jurídicas y organizacionales dependan exclusivamente del administrador de bases de datos.

## 9. Diferencias entre lo implementado y lo propuesto

| Componente | Estado durante el LAB-03 |
|---|---|
| Tabla original `clientes` | Existente |
| Tabla minimizada `clientes_soporte` | Implementada |
| Consultas estadísticas por categorías | Ejecutadas |
| Vista `v_analitica_clientes` | Implementada |
| Rol `analista` | Creado |
| Acceso restringido del analista | Verificado |
| Derecho de acceso | Simulado mediante consulta SQL |
| Rectificación de correo | Ejecutada y comprobada |
| Sincronización del correo en soporte | Ejecutada y comprobada |
| Sistema completo de auditoría | Propuesto |
| Automatización de retención y eliminación | Propuesta |
| Gestión integral de solicitudes ARCO | Propuesta |
| Separación completa de ambientes productivos y de desarrollo | Propuesta |

La arquitectura es conceptual. Su objetivo es representar cómo deberían organizarse los procesos, no afirmar que todos los mecanismos ya se encuentran implementados.

## 10. Análisis de la propuesta

La arquitectura planteada permite relacionar los principios de privacidad con decisiones técnicas concretas.

La separación por finalidad reduce la exposición innecesaria de información, mientras que la definición de roles restringe las operaciones disponibles para cada usuario.

El uso de datos agregados favorece la elaboración de estadísticas sin proporcionar información personal detallada.

Asimismo, los mecanismos de auditoría, retención y atención de solicitudes permiten establecer responsabilidades y administrar la información durante su ciclo de vida.

Sin embargo, estas medidas requieren una implementación coordinada y políticas aprobadas por la organización.

La seguridad técnica no reemplaza las decisiones relacionadas con la legitimidad de las finalidades ni las obligaciones de conservación.

## 11. Conclusión

La propuesta demuestra que una base de datos puede organizarse según las finalidades de operación, analítica y auditoría, aplicando controles específicos a cada componente.

El diseño combina minimización, acceso restringido, protección de información sensible, retención, trazabilidad, eliminación y atención de derechos ARCO.

Las actividades realizadas durante el LAB-03 permitieron implementar parcialmente esta separación mediante tablas limitadas, consultas estadísticas, vistas y roles de PostgreSQL.

Para un entorno productivo se requiere complementar estos mecanismos con auditoría, procedimientos formales, políticas de retención y una adecuada coordinación institucional.

De esta manera, el gobierno de datos y la privacidad pueden incorporarse desde el diseño y durante todo el ciclo de vida de la información.