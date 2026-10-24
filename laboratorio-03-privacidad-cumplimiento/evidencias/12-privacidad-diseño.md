# LAB-03 — Actividad 12: Privacidad por diseño

## Objetivo

Analizar un diseño de base de datos que recopila información personal excesiva y proponer mejoras basadas en los principios de privacidad por diseño, privacidad por defecto, minimización de datos y limitación de finalidad.

## Escenario

Una empresa ficticia está desarrollando una aplicación para registrar clientes.

El desarrollador propone crear una tabla que almacene nombre, correo, teléfono, RFC, edad, dirección, ciudad, código postal, fecha de nacimiento, ocupación, salario y estado civil.

La justificación es que resulta conveniente almacenar toda la información disponible porque podría ser útil en el futuro.

Esta propuesta debe analizarse antes de implementar la base de datos, ya que recopilar información innecesaria incrementa los riesgos de privacidad y seguridad.

## 1. ¿Qué problemas identificas?

El problema principal es la recopilación excesiva de información personal sin una finalidad específica para cada campo.

El diseño propuesto incluye datos que podrían no ser necesarios para registrar a un cliente, como salario, ocupación, estado civil y fecha de nacimiento.

Además, el almacenamiento de numerosos datos personales incrementa la exposición de información ante incidentes de seguridad y dificulta la administración de permisos, periodos de retención y solicitudes relacionadas con los derechos ARCO.

También se identifica una posible duplicidad entre edad y fecha de nacimiento, pues ambos campos pueden utilizarse para obtener información relacionada con la edad del cliente.

Otro problema es que no se definen responsabilidades, medidas de protección ni criterios de conservación para cada categoría de información.

En consecuencia, el diseño no demuestra que la recopilación de todos esos datos sea proporcional y necesaria para el funcionamiento de la aplicación.

## 2. ¿Qué principio de privacidad se está ignorando?

Principalmente se ignora el principio de minimización de datos, que establece que solamente debe recopilarse la información adecuada y necesaria para las finalidades del tratamiento.

También se compromete el principio de finalidad, porque el desarrollador propone almacenar información para posibles usos futuros que todavía no están definidos.

Además, la propuesta es contraria al enfoque de privacidad por diseño, ya que considera la recopilación de datos como una decisión técnica inicial sin evaluar previamente sus implicaciones para los titulares.

La privacidad debe incorporarse desde el análisis de requisitos y el diseño de las estructuras, no solamente después de desarrollar la aplicación.

## 3. ¿Qué preguntas realizarías antes de aprobar el diseño?

Antes de autorizar la estructura propuesta, sería necesario responder lo siguiente:

1. ¿Cuál es la finalidad específica de la aplicación?
2. ¿Qué información es indispensable para registrar al cliente?
3. ¿Por qué se requiere cada uno de los campos propuestos?
4. ¿Qué datos son obligatorios y cuáles deberían ser opcionales?
5. ¿Qué áreas necesitan consultar la información?
6. ¿Se han informado claramente las finalidades al titular?
7. ¿Existe una base jurídica apropiada para cada tratamiento?
8. ¿Cuánto tiempo debe conservarse cada categoría de datos?
9. ¿Qué medidas de seguridad se implementarán?
10. ¿Cómo se atenderán las solicitudes de acceso, rectificación, cancelación y oposición?
11. ¿Es posible cumplir la finalidad utilizando menos información?
12. ¿Qué ocurrirá con los datos cuando termine la relación con el cliente?

Estas preguntas permiten evaluar la necesidad, proporcionalidad y seguridad de la información antes de implementar la base de datos.

## 4. ¿Qué datos eliminarías?

Para una aplicación cuyo único objetivo inicial sea registrar clientes y mantener un medio de contacto, eliminaría de la estructura básica los siguientes campos:

| Campo | Justificación |
|--------|-----------------------|
| `ocupacion` | No es indispensable para el registro básico de clientes. |
| `salario` | Representa información financiera que no es necesaria para identificar o contactar al cliente. |
| `estado_civil` | No tiene una relación directa con la finalidad básica de registro. |
| `fecha_nacimiento` | No debe solicitarse si no existe una necesidad específica de conocer la fecha exacta. |
| `edad` | Puede omitirse cuando el servicio no requiere verificar edades o aplicar restricciones relacionadas. |
| `direccion` | No debe recopilarse si la aplicación no realiza entregas u operaciones que requieran un domicilio. |

Estos campos podrían evaluarse posteriormente si existe una finalidad específica, justificada y autorizada.

No sería adecuado recopilar toda la información desde el principio únicamente por la posibilidad de utilizarla en el futuro.

## 5. ¿Qué datos requerirían una justificación adicional?

Algunos campos podrían ser necesarios dependiendo de los servicios ofrecidos por la empresa.

**RFC:** requeriría justificarse mediante una finalidad fiscal o de facturación. No debería solicitarse automáticamente a todos los usuarios cuando no sea necesario.

**Teléfono:** podría utilizarse como medio alternativo de contacto, pero debería determinarse si es realmente indispensable o si basta con el correo electrónico.

**Dirección y código postal:** podrían justificarse cuando exista un servicio de entrega de productos, logística u otra actividad que requiera conocer la ubicación.

**Edad o fecha de nacimiento:** podrían ser necesarias en servicios sujetos a restricciones de edad, pero debería elegirse la alternativa menos invasiva para cumplir el objetivo.

**Ciudad:** podría utilizarse para ofrecer servicios regionales, aunque debería evaluarse si es suficiente trabajar con información generalizada.

En todos los casos, la organización debe documentar la finalidad y limitar el acceso a los datos correspondientes.

## 6. ¿Cómo aplicarías privacidad por defecto?

La privacidad por defecto implica que la configuración inicial de la aplicación proteja los datos personales sin exigir que el usuario modifique manualmente numerosas opciones.

Para aplicarla, propondría las siguientes medidas:

- Solicitar únicamente los campos indispensables durante el registro inicial.
- Mantener como opcionales los datos adicionales que no sean necesarios.
- No activar automáticamente el uso de información para campañas publicitarias cuando se requiera autorización del titular.
- Restringir el acceso a los datos mediante roles y permisos.
- Evitar que los usuarios internos puedan consultar toda la información sin una necesidad funcional.
- Utilizar vistas específicas para las áreas de soporte, facturación y analítica.
- Establecer criterios documentados para la conservación y eliminación de información.
- Impedir la exposición innecesaria de datos personales en reportes y registros.
- Aplicar cifrado y otros controles de seguridad cuando corresponda.
- Permitir que los titulares consulten y administren sus preferencias de privacidad.

De esta manera, las configuraciones iniciales reducirían la recopilación y exposición innecesaria de información.

## 7. Propuesta de estructura mínima

Para la finalidad de registro básico y contacto, se propone una estructura conceptual más limitada:

| Campo | Tipo de dato propuesto | Justificación |
|---|---------------------------|--------------------------------------------|
| `id` | BIGSERIAL PRIMARY KEY | Identificador interno del cliente. |
| `nombre` | VARCHAR(120) NOT NULL | Identificación básica. |
| `correo` | VARCHAR(150) NOT NULL | Medio de contacto autorizado. |
| `telefono` | VARCHAR(20) | Medio alternativo opcional. |
| `fecha_alta` | DATE NOT NULL | Administración del registro y seguimiento del ciclo de vida. |

Esta propuesta supone que el registro básico necesita identificación y contacto, pero no requiere información fiscal, financiera ni datos demográficos detallados.

Si posteriormente se implementan funciones de facturación, logística o analítica, deberían diseñarse estructuras y controles específicos para esas finalidades.

La propuesta es conceptual y no sustituye automáticamente la tabla `public.clientes` utilizada en las actividades prácticas anteriores.

## 8. Relación con las actividades del LAB-03

La propuesta se relaciona directamente con las medidas aplicadas previamente.

En la Actividad 2 se creó `clientes_soporte` con únicamente cuatro columnas para evitar proporcionar información innecesaria al área de atención al cliente.

En la Actividad 3 se realizaron consultas estadísticas sin mostrar directamente nombres, correos ni RFC.

En la Actividad 4 se creó el rol `analista` y se comprobó que su acceso estuviera limitado a la vista `v_analitica_clientes`.

Estas prácticas demuestran que la privacidad puede incorporarse mediante decisiones sobre estructuras de datos, finalidades y permisos de acceso.

## Análisis de resultados

El diseño original prioriza la recopilación de información sobre la necesidad real de utilizarla, lo cual aumenta los riesgos de privacidad.

En cambio, la estructura propuesta limita la información solicitada durante el registro e identifica los datos que requerirían finalidades adicionales.

Aplicar privacidad por diseño permite anticipar problemas antes de implementar la aplicación. Esto puede reducir costos de mantenimiento, facilitar la atención de derechos ARCO y mejorar el cumplimiento de las políticas de protección de datos.

También es importante reconocer que la privacidad no depende exclusivamente de utilizar menos columnas. Deben establecerse medidas complementarias de autorización, seguridad, retención y administración de la información.

## Conclusión

La privacidad por diseño establece que la protección de los datos personales debe considerarse desde las primeras etapas de desarrollo de un sistema.

No resulta adecuado recopilar información únicamente porque podría ser útil en el futuro. Cada dato debe tener una finalidad definida y una justificación documentada.

La propuesta de estructura mínima demuestra que es posible registrar clientes utilizando menos información y reservando los datos adicionales para los procesos que realmente los necesiten.

La combinación de minimización, limitación de finalidad, privacidad por defecto y controles de acceso permite desarrollar sistemas más responsables y seguros.