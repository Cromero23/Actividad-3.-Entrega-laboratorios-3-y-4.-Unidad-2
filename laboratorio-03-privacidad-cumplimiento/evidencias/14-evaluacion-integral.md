# LAB-03 — Actividad 14: Evaluación integral de privacidad y cumplimiento

## Objetivo

Identificar y analizar los principales riesgos de privacidad, seguridad y cumplimiento relacionados con la administración de datos personales de una organización, proponiendo controles técnicos y administrativos para reducir su impacto.

## 1. Descripción del escenario

Una empresa ficticia administra una base de datos que contiene información de aproximadamente 50,000 clientes.

La tabla `clientes` almacena nombres, correos electrónicos, teléfonos, RFC, edades, ciudades y códigos postales.

Actualmente, todos los empleados del área de analítica pueden consultar directamente la tabla completa, aunque su función consiste únicamente en generar estadísticas mensuales.

Además, la organización conserva información desde hace 12 años sin una política de retención documentada.

Los desarrolladores reciben copias completas de la base de datos para realizar pruebas, y dichas copias contienen información personal real.

Por otra parte, marketing utiliza los correos electrónicos para enviar campañas promocionales, mientras que la empresa no dispone de documentación clara que relacione cada dato con su finalidad.

Estas condiciones requieren evaluar los riesgos y proponer medidas que permitan administrar la información de manera responsable.

## 2. Matriz de evaluación integral

Se identificaron 13 problemas o riesgos relacionados con el escenario planteado.

| N.º | Problema identificado | Principio afectado | Riesgo | Control propuesto |
|---|---|---|---|---|
| 1 | Todos los analistas consultan directamente la tabla `clientes`. | Mínimo privilegio y confidencialidad | Exposición de datos personales que no necesitan para generar estadísticas. | Revocar el acceso directo y permitir consultas mediante vistas o conjuntos de datos autorizados. |
| 2 | Todos los empleados de analítica reciben el mismo nivel de acceso. | Necesidad de conocer y control de acceso | Incremento del número de personas capaces de consultar información personal. | Implementar roles diferenciados y asignar permisos de acuerdo con las funciones reales. |
| 3 | Analítica puede consultar nombres de los clientes. | Minimización de datos | Identificación innecesaria de personas en procesos estadísticos. | Excluir nombres de las consultas destinadas a analítica. |
| 4 | Los correos electrónicos y teléfonos están disponibles para analítica. | Limitación de finalidad y minimización | Acceso innecesario a medios de contacto personales. | Eliminar esos campos de las vistas y conjuntos de datos estadísticos. |
| 5 | El RFC se encuentra accesible para usuarios que no realizan funciones fiscales. | Confidencialidad y control de acceso | Exposición de identificadores fiscales a personal sin necesidad funcional. | Restringir su consulta al personal autorizado de facturación y aplicar protección criptográfica cuando corresponda. |
| 6 | Analítica puede consultar edades y códigos postales detallados. | Minimización y proporcionalidad | Posible identificación de personas al combinar atributos demográficos y geográficos. | Utilizar rangos de edad, regiones postales y agrupaciones suficientemente amplias. |
| 7 | Para generar estadísticas mensuales se utiliza directamente información individual. | Limitación de finalidad y minimización | Tratamiento de más información de la necesaria para obtener resultados estadísticos. | Crear vistas agregadas o tablas de resultados estadísticos sin identificadores directos. |
| 8 | Se conservan datos desde hace 12 años sin justificar cada categoría. | Limitación de conservación | Exposición prolongada de información que podría haber dejado de ser necesaria. | Revisar las finalidades y obligaciones de conservación, estableciendo periodos justificados por categoría. |
| 9 | No existe una política documentada de retención. | Responsabilidad y gobierno de datos | Conservación inconsistente y dificultad para determinar cuándo bloquear o eliminar información. | Aprobar una política de retención que incluya responsables, periodos y procedimientos de disposición final. |
| 10 | Los desarrolladores reciben copias completas de la base de datos. | Minimización y seguridad | Multiplicación de ubicaciones donde puede exponerse información personal. | Utilizar bases de prueba con datos sintéticos o adecuadamente anonimizados y limitar las copias. |
| 11 | Las copias utilizadas en desarrollo contienen datos reales. | Confidencialidad y privacidad por diseño | Posible filtración de información personal desde entornos de desarrollo y pruebas. | Sustituir los datos reales por información ficticia o transformada de manera que no permita identificar titulares. |
| 12 | Marketing utiliza correos electrónicos para promociones sin una finalidad claramente documentada. | Limitación de finalidad y transparencia | Posible utilización de información para un propósito no autorizado o no informado. | Revisar el aviso de privacidad, la base que legitima el tratamiento, las preferencias y los mecanismos de oposición. |
| 13 | No existe documentación clara de la finalidad de cada dato. | Responsabilidad, finalidad y gobierno de datos | Dificultad para justificar la recopilación, uso, acceso y conservación de información. | Elaborar un inventario de datos con finalidades, responsables, accesos autorizados y reglas de retención. |

## 3. Análisis de los principales riesgos

### 3.1 Acceso excesivo a información personal

Uno de los problemas más importantes es que todos los empleados del área de analítica pueden consultar directamente la tabla completa de clientes.

Esta situación contradice el principio de mínimo privilegio, debido a que los usuarios reciben acceso a más información de la necesaria para desempeñar sus funciones.

Si analítica únicamente genera estadísticas mensuales, no necesita consultar nombres, correos electrónicos, teléfonos ni RFC.

Durante las actividades anteriores del LAB-03 se aplicó una solución relacionada con este problema: se creó el rol `analista` y se le otorgó acceso a la vista `v_analitica_clientes`, sin permitirle consultar directamente `public.clientes`.

Para un entorno productivo sería recomendable avanzar hacia vistas verdaderamente agregadas, incluyendo conteos y reglas que reduzcan el riesgo de identificar personas en grupos pequeños.

### 3.2 Conservación excesiva de datos

La empresa conserva información desde hace 12 años y no dispone de una política documentada de retención.

La antigüedad de los datos no demuestra automáticamente que su conservación sea ilegal, porque algunas categorías pueden estar sujetas a obligaciones específicas.

Sin embargo, conservarlos sin justificar su finalidad y periodo incrementa los riesgos de exposición, uso indebido y administración incorrecta.

Por este motivo, se propone establecer periodos de conservación de acuerdo con las finalidades y obligaciones aplicables.

También deben definirse procedimientos de bloqueo, eliminación y protección de respaldos cuando finalice el periodo correspondiente.

### 3.3 Uso de datos reales en desarrollo

Los desarrolladores reciben copias completas de la base de datos y utilizan información personal real durante las pruebas.

Este procedimiento incrementa la superficie de exposición, porque los datos dejan de encontrarse únicamente en el entorno principal y pueden distribuirse entre diferentes sistemas.

Los entornos de desarrollo pueden requerir controles distintos de los utilizados en producción, por lo que es importante evitar la distribución innecesaria de información personal.

Se recomienda utilizar datos sintéticos o información adecuadamente anonimizada, verificando que no sea posible identificar nuevamente a los clientes mediante la combinación de atributos.

También deben establecerse restricciones de acceso, protección de los entornos y procedimientos para eliminar las copias cuando dejen de ser necesarias.

### 3.4 Tratamiento con finalidades secundarias

Marketing utiliza los correos electrónicos de clientes para realizar campañas promocionales.

Antes de continuar con este tratamiento, la empresa debe verificar si la finalidad fue informada y si existe una base jurídica adecuada para utilizar la información.

El hecho de que una organización almacene datos personales para soporte o facturación no significa automáticamente que pueda emplearlos para cualquier otra finalidad.

Se recomienda separar las finalidades mediante controles de acceso, revisar las preferencias de privacidad y establecer mecanismos para atender las solicitudes de oposición cuando procedan.

### 3.5 Ausencia de documentación de gobierno de datos

La organización no cuenta con documentación clara sobre la finalidad asociada a cada campo.

Esta deficiencia dificulta determinar qué información es realmente necesaria, qué empleados deben consultarla y durante cuánto tiempo debe conservarse.

También complica la atención de solicitudes de derechos ARCO y la demostración de decisiones de privacidad.

Para corregir este problema se propone elaborar un inventario y una matriz de gobierno de datos, como los desarrollados durante las actividades anteriores de este laboratorio.

## 4. Plan de acciones prioritarias

### Prioridad alta: reducir la exposición inmediata

La primera medida consiste en revisar los permisos actuales y restringir el acceso directo a la tabla `clientes`.

También debe detenerse la distribución innecesaria de copias completas con datos reales hacia los entornos de desarrollo.

Es recomendable identificar a los usuarios y sistemas que actualmente pueden consultar información personal y validar si sus accesos están justificados.

### Prioridad media: establecer controles de privacidad

Una vez reducidos los accesos excesivos, la empresa debe implementar vistas y conjuntos de datos limitados por finalidad.

Para analítica deben utilizarse resultados agregados y evitar la exposición de identificadores directos.

Además, marketing debe contar con reglas claras para utilizar únicamente información correspondiente a finalidades autorizadas.

### Prioridad organizacional: formalizar el gobierno de datos

La organización debe establecer una política documentada de retención y una matriz que identifique las finalidades de cada dato.

Asimismo, deben definirse responsables, mecanismos de supervisión, procedimientos de atención de derechos ARCO y controles de auditoría.

Estas medidas permitirán mantener una administración más consistente de la información personal.

## 5. Relación con las actividades realizadas

La evaluación integral permite aplicar conocimientos desarrollados durante el LAB-03.

En la Actividad 1 se identificaron los datos personales y se relacionaron con sus finalidades.

En la Actividad 2 se aplicó la minimización mediante la creación de `clientes_soporte` con únicamente cuatro columnas.

En la Actividad 3 se generaron estadísticas por ciudad, rangos de edad y región postal sin mostrar identificadores directos.

En la Actividad 4 se creó el rol `analista` y se restringió su acceso a una vista específica.

Posteriormente se analizaron los derechos ARCO, la retención de datos, el gobierno de la información y la privacidad por diseño.

Estos conocimientos permiten identificar que muchos problemas de privacidad pueden originarse en decisiones de diseño, administración o uso de datos, incluso cuando existe una infraestructura tecnológica funcional.

## 6. Resultado de la evaluación

La evaluación permitió identificar 13 problemas o riesgos relacionados con el acceso excesivo, la minimización, el uso de información para distintas finalidades, la retención y los entornos de desarrollo.

Para cada situación se propuso al menos una medida que podría reducir su impacto.

Las propuestas incluyen controles técnicos, como vistas, roles, permisos y transformación de datos, y controles administrativos, como políticas, inventarios, autorización de finalidades y procedimientos de conservación.

Los controles descritos corresponden a una propuesta de mejora para el escenario ficticio. No significa que todos hayan sido implementados en nuestra base de datos local.

## 7. Conclusión

La evaluación integral demuestra que la protección de datos personales requiere más que implementar contraseñas, cifrado o permisos básicos.

Una organización también debe justificar la recopilación y utilización de la información, limitar los accesos según las funciones, evitar copias innecesarias y establecer periodos de conservación apropiados.

La ausencia de políticas documentadas y la utilización excesiva de información personal incrementan los riesgos de privacidad, seguridad y cumplimiento.

Por tanto, se recomienda aplicar una estrategia de gobierno de datos que combine controles técnicos y administrativos, con responsabilidades claramente definidas y procedimientos verificables.

El DBA participa en la implementación de estos controles, pero las decisiones sobre finalidades, conservación y cumplimiento deben coordinarse con las áreas responsables de la organización.