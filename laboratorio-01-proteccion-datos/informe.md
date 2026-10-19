# LAB-01 — Protección y privacidad de datos

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Unidad:** II — Seguridad, privacidad y control de acceso  
**Tema:** Datos sensibles, privacidad y protección de la información  
**Estudiante:** Carlos Romero  
**Grupo:** 4  

---

## 1. Clasificación de los datos

### 1.1 Objetivo

Antes de implementar mecanismos de protección, se realizó una clasificación de los atributos almacenados en la tabla `clientes`.

El propósito fue identificar qué campos pueden identificar directamente a una persona, cuáles pueden actuar como cuasi-identificadores y cuáles requieren medidas de protección debido al riesgo de exposición o reidentificación.

### 1.2 Matriz de clasificación

| Campo | ¿Identifica directamente? | ¿Puede contribuir a identificar? | ¿Requiere protección? | Justificación |
|---|---|---|---|---|
| `id` | No directamente | Sí | Sí | Identifica de forma única un registro dentro del sistema y puede relacionarse con otros datos. |
| `nombre` | Sí | Sí | Sí | Permite identificar directamente a una persona. |
| `correo` | Sí | Sí | Sí | Puede asociarse directamente con una persona determinada. |
| `telefono` | Sí | Sí | Sí | Puede identificar o permitir contactar directamente al titular. |
| `rfc` | Sí | Sí | Sí | Es un identificador relacionado directamente con una persona. |
| `edad` | No | Sí | Sí | Puede funcionar como cuasi-identificador al combinarse con otros atributos. |
| `ciudad` | No | Sí | Sí | Puede reducir el conjunto de personas posibles cuando se combina con otros datos. |
| `codigo_postal` | No | Sí | Sí | Permite aproximar la ubicación de una persona y puede contribuir a su reidentificación. |
| `fecha_alta` | No | Sí | Sí | Puede contribuir a distinguir registros cuando se combina con otros atributos. |

### 1.3 Preguntas de la actividad

**1. ¿Qué campos identifican directamente a una persona?**

Los campos que pueden identificar directamente a una persona son principalmente `nombre`, `correo`, `telefono` y `rfc`.

El campo `id` identifica de forma única un registro dentro del sistema, pero por sí solo no necesariamente revela la identidad de la persona fuera de la base de datos.

**2. ¿Qué campos no identifican por sí solos pero podrían contribuir a hacerlo?**

Los campos `edad`, `ciudad`, `codigo_postal` y `fecha_alta` pueden actuar como cuasi-identificadores.

Individualmente pueden no identificar a una persona, pero al combinarse pueden reducir significativamente el grupo de individuos posibles y aumentar el riesgo de reidentificación.

**3. ¿Qué combinación de campos podría incrementar el riesgo de reidentificación?**

Una combinación como:

`edad + ciudad + codigo_postal`

puede incrementar el riesgo de reidentificación debido a que reduce el número de personas que coinciden con esas características.

También podrían existir otras combinaciones, como `edad + codigo_postal + fecha_alta`, que permitan distinguir a una persona dentro de un conjunto reducido.

**4. ¿Todos los datos que deben protegerse son necesariamente datos personales sensibles desde el punto de vista jurídico?**

No.

Existen datos que requieren protección debido a riesgos de privacidad, confidencialidad o seguridad, aunque jurídicamente no pertenezcan necesariamente a una categoría de datos personales sensibles.

La necesidad de protección también depende del contexto, la finalidad del tratamiento y la posibilidad de combinar diferentes atributos para identificar a una persona.

### 1.4 Resultado

Se creó la tabla `clientes` y se insertaron cinco registros ficticios para realizar las actividades del laboratorio.

La clasificación permitió identificar datos que pueden actuar como identificadores directos y otros que pueden funcionar como cuasi-identificadores.

Este análisis será utilizado en las siguientes actividades para determinar qué mecanismos de protección deben aplicarse a cada tipo de información.

### 1.5 Evidencia

La evidencia correspondiente a esta actividad se encuentra en:

[Ver evidencia de clasificación](evidencias/01-clasificacion.pdf)

El script SQL utilizado se encuentra en:

`sql/01-clasificacion.sql`

---

## 2. Enmascaramiento

### 2.1 Objetivo

El área de soporte necesita consultar información que permita identificar a los clientes durante la atención de solicitudes, pero no requiere visualizar completamente datos como el correo electrónico, el teléfono y el RFC.

Para reducir la exposición de esta información se implementó un mecanismo de enmascaramiento mediante una vista de PostgreSQL.

El objetivo es permitir que el área de soporte consulte únicamente la información necesaria para realizar sus funciones, siguiendo el principio de mínimo privilegio y evitando el acceso directo a los datos originales almacenados en la tabla `clientes`.

### 2.2 Implementación

Se creó una vista denominada:

`v_clientes_soporte`

La vista conserva los campos `id` y `nombre`, mientras que los datos de correo electrónico, teléfono y RFC se muestran parcialmente enmascarados.

En el caso del correo electrónico, se conservan únicamente los primeros caracteres y el dominio.

Por ejemplo:

```text
ana.lopez@example.test
```

se presenta de forma similar a:

```text
an*****@example.test
```

Para el teléfono se conservan solamente los últimos cuatro dígitos.

Por ejemplo:

```text
6671234567
```

se presenta como:

```text
******4567
```

En el caso del RFC, únicamente permanecen visibles los últimos cuatro caracteres.

De esta forma, el dato original continúa almacenado en la tabla `clientes`, pero el usuario de soporte solamente puede visualizar una representación parcialmente protegida.

### 2.3 Adaptación al entorno compartido de FICLabs

Durante la implementación se intentó crear el rol solicitado originalmente en el laboratorio:

```sql
CREATE ROLE soporte NOLOGIN;
```

Sin embargo, PostgreSQL indicó que el rol `soporte` ya existía en el servidor.

Debido a que FICLabs utiliza un servidor PostgreSQL compartido entre varios estudiantes, se decidió utilizar un nombre de rol único para evitar conflictos con otros usuarios:

```text
soporte_23101075
```

El rol fue creado mediante:

```sql
CREATE ROLE soporte_23101075 NOLOGIN;
```

La opción `NOLOGIN` permite utilizar el rol como una función o conjunto de privilegios sin utilizarlo directamente como una cuenta de inicio de sesión.

Posteriormente se otorgaron los permisos necesarios:

```sql
GRANT USAGE
ON SCHEMA public
TO soporte_23101075;
```

```sql
GRANT SELECT
ON v_clientes_soporte
TO soporte_23101075;
```

También se retiró cualquier acceso directo a la tabla original:

```sql
REVOKE ALL
ON clientes
FROM soporte_23101075;
```

De esta manera, el rol cuenta con acceso a la vista protegida, pero no a la tabla que contiene los valores originales.

### 2.4 Verificación de privilegios

Se verificaron los privilegios mediante la función `has_table_privilege`.

La consulta utilizada fue:

```sql
SELECT
    has_table_privilege(
        'soporte_23101075',
        'public.v_clientes_soporte',
        'SELECT'
    ) AS puede_ver_vista,
    has_table_privilege(
        'soporte_23101075',
        'public.clientes',
        'SELECT'
    ) AS puede_ver_clientes;
```

El resultado obtenido fue:

```text
puede_ver_vista     = true
puede_ver_clientes  = false
```

Esto demuestra que el rol puede consultar la vista `v_clientes_soporte`, pero no tiene permiso de lectura sobre la tabla original `clientes`.

### 2.5 Verificación mediante `SET ROLE`

Para comprobar directamente el comportamiento de los permisos, fue necesario permitir que el usuario de la práctica pudiera asumir temporalmente el rol de soporte.

La membresía se otorgó mediante:

```sql
GRANT soporte_23101075
TO u_23101075_carlos_romero;
```

Posteriormente se ejecutó:

```sql
SET ROLE soporte_23101075;
```

Para verificar que el cambio de rol se había realizado correctamente se utilizó:

```sql
SELECT current_user, session_user;
```

El resultado permitió comprobar que `current_user` correspondía al rol:

```text
soporte_23101075
```

mientras que `session_user` continuaba correspondiendo al usuario original utilizado para iniciar la sesión en FICLabs.

Esto demuestra que las pruebas posteriores se realizaron utilizando los privilegios efectivos del rol de soporte.

### 2.6 Consulta permitida

Con el rol `soporte_23101075` activo se ejecutó:

```sql
SELECT *
FROM v_clientes_soporte;
```

La consulta fue ejecutada correctamente.

El resultado mostró los cinco registros de clientes, pero el correo electrónico, teléfono y RFC fueron presentados parcialmente enmascarados.

Esto demuestra que el rol cuenta con los privilegios necesarios para utilizar la información requerida por el área de soporte.

### 2.7 Acceso directo rechazado

Con el rol `soporte_23101075` todavía activo se intentó consultar directamente la tabla original:

```sql
SELECT *
FROM clientes;
```

PostgreSQL rechazó la consulta y presentó el mensaje:

```text
ERROR: permission denied for table clientes
SQL state: 42501
```

Este resultado demuestra que el rol no puede acceder directamente a los valores originales almacenados en la tabla `clientes`.

Por lo tanto, el acceso del área de soporte queda limitado a la vista enmascarada.

Una vez terminada la prueba se utilizó:

```sql
RESET ROLE;
```

para regresar al usuario original de la sesión.

### 2.8 Preguntas de la actividad

**1. ¿Qué información continúa existiendo en la tabla original?**

La tabla original `clientes` conserva los datos completos de los clientes, incluyendo:

- `id`
- `nombre`
- `correo`
- `telefono`
- `rfc`
- `edad`
- `ciudad`
- `codigo_postal`
- `fecha_alta`

El enmascaramiento no elimina ni modifica necesariamente los valores almacenados.

Su objetivo consiste en modificar la forma en que determinados usuarios pueden visualizar la información.

**2. ¿Qué información puede visualizar el usuario de soporte?**

El rol `soporte_23101075` puede visualizar el identificador y el nombre de los clientes.

Además, mediante la vista `v_clientes_soporte`, puede visualizar versiones parcialmente ocultas del correo electrónico, teléfono y RFC.

Por lo tanto, el área de soporte obtiene únicamente la información necesaria para realizar sus funciones sin visualizar completamente determinados datos personales.

**3. ¿Por qué no es suficiente ocultar los datos únicamente en la aplicación?**

Ocultar los datos únicamente en la interfaz de una aplicación no garantiza que permanezcan protegidos dentro de la base de datos.

Si un usuario conserva permisos directos sobre la tabla original, podría evitar la interfaz de la aplicación y realizar consultas directamente sobre la base de datos para obtener los valores completos.

Por esta razón, los controles de protección también deben implementarse en el nivel de la base de datos mediante mecanismos como vistas, roles, `GRANT` y `REVOKE`.

**4. ¿Qué ocurriría si `soporte` tuviera acceso directo a `clientes`?**

Si el rol de soporte tuviera permiso de lectura directo sobre la tabla `clientes`, podría consultar los datos completos sin utilizar la vista enmascarada.

Esto haría ineficaz el mecanismo de protección implementado mediante `v_clientes_soporte` y aumentaría el riesgo de exposición de información personal.

Por esta razón, se aplica el principio de mínimo privilegio, otorgando únicamente los permisos necesarios para realizar las funciones correspondientes.

### 2.9 Conclusión de la actividad

La implementación del enmascaramiento fue exitosa.

Mediante la vista `v_clientes_soporte` se ocultaron parcialmente el correo electrónico, teléfono y RFC de los clientes, sin modificar los valores originales almacenados en la tabla `clientes`.

Los permisos asignados al rol `soporte_23101075` permiten consultar la vista protegida, pero impiden el acceso directo a la tabla original.

La verificación mediante `has_table_privilege` confirmó que el rol posee permiso de lectura sobre la vista y no sobre la tabla `clientes`.

Además, la prueba realizada mediante `SET ROLE soporte_23101075` permitió comprobar el comportamiento real de los permisos.

La consulta sobre la vista protegida fue permitida, mientras que el acceso directo a `clientes` fue rechazado por PostgreSQL.

Esto demuestra que el enmascaramiento debe combinarse con mecanismos de control de acceso y con el principio de mínimo privilegio para proteger correctamente la información almacenada.

### 2.10 Evidencia

La evidencia correspondiente a esta actividad se encuentra en:

[Ver evidencia de enmascaramiento](evidencias/02-enmascaramiento.pdf)

El script SQL utilizado se encuentra en:

`sql/02-enmascaramiento.sql`

---

## 3. Seudonimización

## 3. Seudonimización y separación de funciones

### 3.1 Objetivo

El área de analítica necesita utilizar información de los clientes para realizar análisis y detectar tendencias, pero no requiere conocer directamente la identidad de cada persona.

Para reducir la exposición de identificadores directos se implementó un mecanismo de seudonimización mediante identificadores sustitutos denominados tokens.

### 3.2 Creación de los esquemas

Se utilizaron dos esquemas diferentes:

- `pii`: destinado a almacenar información que permite volver a relacionar el token con el cliente original.
- `analitica`: destinado a contener la información que puede utilizar el área de análisis.

La separación de los esquemas permite aplicar controles de acceso diferentes de acuerdo con el nivel de sensibilidad de la información.

### 3.3 Tabla de correspondencia

Dentro del esquema `pii` se utilizó la tabla:

`pii.mapa_cliente`

Esta tabla contiene:

- `token`: identificador UUID utilizado como seudónimo.
- `cliente_id`: identificador correspondiente al registro original en `public.clientes`.

La relación puede representarse de la siguiente forma:

```text
token → cliente_id
```

Esta información es especialmente sensible porque permite volver a relacionar un registro seudonimizado con su identidad original.

Por esta razón, la tabla de correspondencia debe mantenerse separada y con controles de acceso más estrictos.

### 3.4 Generación de tokens

Para generar los identificadores sustitutos se utilizó la función:

```sql
gen_random_uuid()
```

Cada cliente recibió un UUID diferente.

La consulta de verificación mostró cinco tokens asociados respectivamente con los cinco clientes almacenados en la tabla original.

El uso de tokens permite sustituir el identificador directo por un valor que no revela directamente la identidad del cliente.

### 3.5 Conjunto de datos para analítica

Se creó la tabla:

`analitica.clientes`

El conjunto contiene únicamente los siguientes atributos:

- `cliente_token`
- `edad`
- `ciudad`
- `codigo_postal`
- `fecha_alta`

Los identificadores directos:

- `nombre`
- `correo`
- `telefono`
- `rfc`

no forman parte del conjunto destinado al área de analítica.

De esta forma, el analista puede trabajar con información relacionada con los clientes sin conocer directamente su identidad.

### 3.6 Separación de funciones

La seudonimización pierde gran parte de su utilidad si la misma persona puede consultar tanto los datos seudonimizados como la tabla que permite recuperar la identidad.

Por esta razón se implementó una separación de funciones.

Debido a que FICLabs utiliza un servidor PostgreSQL compartido, se utilizó un nombre de rol único:

`analista_23101075`

El rol recibió permiso de lectura únicamente sobre:

`analitica.clientes`

No recibió acceso a:

`pii.mapa_cliente`

ni a:

`public.clientes`

### 3.7 Verificación de privilegios

Se verificaron los permisos mediante `has_table_privilege`.

El resultado esperado y obtenido fue equivalente a:

```text
puede_ver_analitica = true
puede_ver_mapa      = false
puede_ver_clientes  = false
```

Esto demuestra que el rol puede consultar únicamente el conjunto preparado para analítica.

### 3.8 Prueba con el rol analista

Para comprobar directamente los permisos se otorgó al usuario de la práctica membresía sobre el rol:

```sql
GRANT analista_23101075
TO u_23101075_carlos_romero;
```

Posteriormente se utilizó:

```sql
SET ROLE analista_23101075;
```

La consulta:

```sql
SELECT *
FROM analitica.clientes;
```

fue permitida.

En cambio, los intentos de consultar:

```sql
SELECT *
FROM pii.mapa_cliente;
```

y:

```sql
SELECT *
FROM public.clientes;
```

fueron rechazados por PostgreSQL debido a la falta de privilegios.

Esto demuestra que el analista puede utilizar los datos seudonimizados pero no puede recuperar directamente la identidad de los clientes.

### 3.9 Preguntas de la actividad

**1. ¿Qué ocurriría si `analista` pudiera consultar también `pii.mapa_cliente`?**

Si el analista pudiera consultar la tabla `pii.mapa_cliente`, podría relacionar cada token con el `cliente_id` original.

Esto reduciría significativamente la protección proporcionada por la seudonimización y permitiría recuperar la relación entre los datos utilizados para análisis y la identidad original del cliente.

**2. ¿Qué principio de seguridad se está aplicando al separar ambos accesos?**

Se aplica principalmente el principio de separación de funciones.

También se relaciona con el principio de mínimo privilegio, ya que cada rol recibe únicamente los permisos necesarios para realizar sus actividades.

**3. ¿Por qué la seudonimización no equivale a anonimización?**

La seudonimización no equivale a anonimización porque continúa existiendo información adicional que permite volver a asociar el token con el registro original.

En este caso, la tabla `pii.mapa_cliente` conserva dicha relación.

Por lo tanto, la identidad puede recuperarse si existe autorización y acceso a la información adicional.

**4. ¿Qué información permite volver a relacionar el token con una persona?**

La tabla `pii.mapa_cliente` mantiene la correspondencia entre el `token` y el `cliente_id`.

Mediante esta relación y el acceso a la tabla original `public.clientes`, sería posible volver a asociar el token con la identidad del cliente.

### 3.10 Conclusión de la actividad

La seudonimización permitió sustituir los identificadores directos de los clientes por tokens UUID.

El conjunto `analitica.clientes` permite realizar análisis utilizando información como edad, ciudad, código postal y fecha de alta, sin exponer directamente el nombre, correo electrónico, teléfono o RFC.

La tabla `pii.mapa_cliente` conserva la relación necesaria para recuperar la identidad cuando existe autorización, razón por la cual debe mantenerse protegida.

La separación de funciones aplicada al rol `analista_23101075` evita que el mismo usuario pueda consultar simultáneamente el conjunto analítico y la tabla de correspondencia.

La práctica demuestra que la seudonimización reduce la exposición de identificadores directos, pero no equivale a una anonimización irreversible.

### 3.11 Evidencia

La evidencia correspondiente a esta actividad se encuentra en:

[Ver evidencia de seudonimización](evidencias/03-seudonimizacion.pdf)

El script SQL utilizado se encuentra en:

`sql/03-seudonimizacion.sql`


---

## 4. Anonimización y riesgo de reidentificación

## 4. Anonimización y riesgo de reidentificación

### 4.1 Objetivo

El área de dirección requiere información estadística para apoyar la toma de decisiones, pero no necesita consultar información individual de los clientes.

Para reducir el riesgo de identificación se aplicaron técnicas de generalización, agregación y supresión de grupos pequeños sobre atributos que pueden funcionar como cuasi-identificadores.

### 4.2 Generalización de la edad

La edad exacta fue sustituida por rangos.

Se utilizaron inicialmente los siguientes grupos:

- `18-30`
- `31-45`
- `46+`

El resultado mostró que cuatro clientes pertenecen al rango `31-45` y uno pertenece al rango `46+`.

Esta transformación reduce el nivel de detalle respecto a utilizar la edad exacta de cada persona.

### 4.3 Generalización de la región

El código postal también fue generalizado.

En lugar de utilizar el código completo se conservaron únicamente sus primeros dos caracteres.

Los resultados fueron:

```text
Región 80 → 3 registros
Región 81 → 1 registro
Región 82 → 1 registro
```

La reducción del nivel de precisión geográfica contribuye a disminuir la posibilidad de distinguir directamente a una persona.

### 4.4 Combinación de atributos

Posteriormente se combinaron el rango de edad y la región.

Los resultados fueron:

```text
31-45 / 80 → 3 registros
31-45 / 81 → 1 registro
46+   / 82 → 1 registro
```

La combinación demuestra que, aunque los datos hayan sido generalizados, algunos grupos todavía contienen solamente una persona.

Los grupos pequeños aumentan el riesgo de reidentificación debido a que resulta más sencillo distinguir un registro dentro del conjunto.

### 4.5 Supresión de grupos pequeños

Se utilizó el criterio didáctico:

```sql
HAVING COUNT(*) >= 5
```

La consulta no devolvió registros debido a que ninguno de los grupos obtenidos contenía cinco o más personas.

Este resultado demuestra que el conjunto inicial contiene grupos demasiado pequeños para cumplir el umbral utilizado en la actividad.

El criterio `k = 5` se utiliza únicamente como ejercicio didáctico y no garantiza por sí mismo que un conjunto de información sea completamente anónimo.

### 4.6 Análisis del riesgo de reidentificación

**1. ¿Qué identificadores directos fueron eliminados?**

Los identificadores directos que no forman parte de la información agregada son principalmente:

- `nombre`
- `correo`
- `telefono`
- `rfc`

Estos atributos permiten identificar directamente o relacionar de manera inmediata un registro con una persona.

**2. ¿Qué cuasi-identificadores permanecen?**

Los principales cuasi-identificadores presentes en el conjunto original son:

- `edad`
- `ciudad`
- `codigo_postal`
- `fecha_alta`

Aunque individualmente pueden no identificar directamente a una persona, su combinación puede reducir significativamente el número de individuos posibles.

**3. ¿Qué combinaciones de atributos podrían reducir el anonimato?**

Una combinación como:

`edad + ciudad + codigo_postal`

puede aumentar considerablemente el riesgo de reidentificación.

También podrían utilizarse combinaciones como:

`edad + codigo_postal + fecha_alta`

especialmente cuando existen pocos registros con las mismas características.

**4. ¿Qué sucede cuando un grupo contiene pocos registros?**

Cuando un grupo contiene pocos registros resulta más sencillo distinguir a una persona dentro del conjunto.

Un grupo formado por un solo registro representa un riesgo especialmente elevado, ya que las características utilizadas para formar el grupo corresponden únicamente a una persona dentro de los datos analizados.

**5. ¿Qué atributos deberían generalizarse?**

Los atributos que pueden generalizarse incluyen principalmente la edad, el código postal y, dependiendo del análisis realizado, la fecha de alta y la ciudad.

Por ejemplo, una edad exacta puede convertirse en un rango y un código postal completo puede sustituirse por una región más amplia.

**6. ¿Qué información debería suprimirse?**

Podrían suprimirse grupos que contengan muy pocos registros o atributos cuyo nivel de detalle no sea necesario para la finalidad del análisis.

La supresión debe realizarse considerando la utilidad de la información y el riesgo de reidentificación.

**7. ¿Es correcto afirmar que el conjunto de datos es “100 % anónimo”? ¿Por qué?**

No.

No es correcto afirmar que un conjunto es completamente anónimo únicamente porque se eliminaron identificadores directos o porque se alcanzó un determinado tamaño mínimo de grupo.

El riesgo de reidentificación depende del contexto, de los atributos disponibles, de las combinaciones posibles y de la existencia de otras fuentes de información que puedan utilizarse para volver a identificar a una persona.

### 4.7 Reto — Reducción adicional del riesgo

Para reducir todavía más el riesgo de reidentificación se aumentó el nivel de generalización.

El rango de edad fue ampliado a:

```text
18-50
51+
```

y la región postal se redujo únicamente al primer carácter del código postal.

La consulta aplicada fue:

```sql
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 50 THEN '18-50'
        ELSE '51+'
    END AS rango_edad_amplio,
    LEFT(codigo_postal, 1) AS region_amplia,
    COUNT(*) AS total
FROM public.clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;
```

El resultado fue:

```text
18-50 | 8 | 5
```

**Cambio realizado:** se amplió el rango de edad y se redujo la precisión del código postal.

**Motivo:** disminuir el nivel de detalle disponible y evitar la formación de grupos demasiado pequeños.

**Resultado obtenido:** los cinco registros quedaron agrupados dentro de una misma combinación de rango de edad y región.

**Riesgo que se pretende reducir:** la posibilidad de distinguir o reidentificar a una persona utilizando la combinación de edad y ubicación geográfica.

Este resultado no implica que los datos sean automáticamente anónimos. El umbral debe interpretarse únicamente como una medida utilizada dentro del ejercicio para analizar el efecto de la generalización y la supresión de grupos pequeños.

### 4.8 Conclusión de la actividad

La actividad permitió comprobar que eliminar los identificadores directos no es suficiente para garantizar la anonimización de un conjunto de datos.

Los atributos que funcionan como cuasi-identificadores pueden combinarse y generar grupos pequeños que faciliten la reidentificación.

La generalización de la edad y del código postal redujo el nivel de detalle disponible. Sin embargo, la primera combinación generó grupos de uno y tres registros.

Al ampliar aún más la generalización fue posible formar un único grupo de cinco registros, reduciendo la posibilidad de distinguir individuos utilizando dichos atributos.

Aun así, el cumplimiento de un umbral `k = 5` no representa una garantía absoluta de anonimización. La evaluación del riesgo debe considerar el contexto, los atributos disponibles y las posibles fuentes externas de información.

### 4.9 Evidencia

La evidencia correspondiente a esta actividad se encuentra en:

[Ver evidencia de anonimización](evidencias/04-anonimizacion.pdf)

El script SQL utilizado se encuentra en:

`sql/04-anonimizacion.sql`


---

## 5. Retención de datos

## 5. Retención de datos

### 5.1 Objetivo

La conservación indefinida de información puede aumentar innecesariamente los riesgos de privacidad y seguridad.

Por esta razón se analizó una política de retención basada en la antigüedad de los registros almacenados en la tabla `clientes`.

Para fines del laboratorio se utilizó un periodo de cinco años.

### 5.2 Identificación de registros candidatos

Se utilizó la siguiente consulta:

```sql
SELECT *
FROM public.clientes
WHERE fecha_alta <
CURRENT_DATE - INTERVAL '5 years';
```

La consulta permite identificar los registros cuya fecha de alta es anterior al límite establecido por la política de retención.

Con los datos utilizados durante el laboratorio no se encontraron registros que cumplieran este criterio.

Esto se debe a que los cinco clientes fueron registrados recientemente.

### 5.3 Fecha límite utilizada

Para determinar el límite correspondiente a cinco años se ejecutó:

```sql
SELECT
    CURRENT_DATE AS fecha_actual,
    CURRENT_DATE - INTERVAL '5 years'
        AS fecha_limite_retencion;
```

Esta consulta permite determinar de manera explícita la fecha utilizada para evaluar la antigüedad de los registros.

### 5.4 Verificación de registros candidatos

También se realizó un conteo mediante:

```sql
SELECT
    COUNT(*) AS registros_candidatos_eliminacion
FROM public.clientes
WHERE fecha_alta <
CURRENT_DATE - INTERVAL '5 years';
```

El resultado obtenido fue:

```text
0 registros
```

Por lo tanto, actualmente ningún cliente cumple con el criterio establecido para una posible eliminación.

### 5.5 Preguntas de la actividad

**1. ¿Qué registros serían afectados por una política de retención de cinco años?**

Serían afectados aquellos registros cuya `fecha_alta` sea anterior a la fecha actual menos cinco años.

En el conjunto utilizado durante el laboratorio no existe ningún registro que cumpla este criterio.

**2. ¿Cómo se justificaría el periodo de retención?**

El periodo de retención debe establecerse de acuerdo con la finalidad para la cual se recopilaron los datos, las necesidades operativas y las obligaciones legales, contractuales o regulatorias aplicables.

La información no debería conservarse durante un periodo superior al necesario para cumplir con dichas finalidades.

**3. ¿Qué aprobación debería existir antes de eliminar información?**

Antes de ejecutar una eliminación definitiva debería existir una autorización formal por parte del responsable de la información o del área correspondiente.

La eliminación no debería depender únicamente de una decisión técnica del administrador de la base de datos.

**4. ¿Qué respaldo debería existir antes de realizar la eliminación?**

Debe existir un mecanismo de respaldo adecuado y previamente verificado.

El respaldo debe permitir recuperar la información en caso de que la eliminación haya sido incorrecta, accidental o requiera revertirse por razones operativas.

**5. ¿Qué evidencia debería conservarse de una eliminación?**

Debería conservarse información como:

- fecha y hora de la operación;
- responsable de la eliminación;
- criterio o política utilizada;
- registros afectados;
- autorización correspondiente;
- resultado de la operación;
- referencia al respaldo existente.

Esta evidencia permite mantener trazabilidad sobre las acciones realizadas.

**6. ¿Cómo podría recuperarse información eliminada accidentalmente?**

La recuperación debería realizarse mediante los mecanismos de respaldo establecidos por la organización.

Por esta razón, antes de realizar una eliminación definitiva es necesario comprobar que el respaldo sea válido, accesible y que exista un procedimiento documentado de restauración.

### 5.6 Consideraciones de seguridad

Durante esta actividad no se ejecutó ninguna instrucción `DELETE` sobre la tabla `clientes`.

Únicamente se identificaron los registros que potencialmente serían afectados por la política de retención.

Una eliminación real requeriría previamente validar la política, obtener autorización, asegurar la existencia de respaldos y conservar evidencia de la operación.

### 5.7 Conclusión de la actividad

La actividad permitió analizar la importancia de establecer periodos definidos para la conservación de información.

Mantener datos durante más tiempo del necesario aumenta la cantidad de información expuesta ante posibles incidentes de seguridad y puede contradecir principios relacionados con la minimización de datos.

La consulta aplicada demostró que actualmente ninguno de los registros utilizados en el laboratorio supera el periodo de cinco años.

También se comprobó que una política de retención no debe limitarse a ejecutar una instrucción de eliminación. Debe existir un proceso controlado que incluya autorización, respaldo, trazabilidad y mecanismos de recuperación.

### 5.8 Evidencia

La evidencia correspondiente a esta actividad se encuentra en:

[Ver evidencia de retención](evidencias/05-retencion.pdf)

El script SQL utilizado se encuentra en:

`sql/05-retencion.sql`



## 6. Conclusiones

## 6. Conclusiones

### 6.1 ¿Qué técnica utilizarías para un área de soporte?

Para un área de soporte utilizaría principalmente **enmascaramiento de datos combinado con control de acceso**.

El personal de soporte puede necesitar información suficiente para reconocer a un cliente y atender una solicitud, pero no necesariamente debe visualizar completamente datos como correo electrónico, teléfono o RFC.

En el laboratorio se implementó la vista `v_clientes_soporte`, que conserva información útil como `id` y `nombre`, mientras presenta de forma parcialmente oculta el correo, teléfono y RFC.

Además, el rol `soporte_23101075` solamente puede consultar dicha vista y no tiene acceso directo a la tabla `clientes`.

Esto permite aplicar el principio de mínimo privilegio y reducir la exposición innecesaria de información personal.

### 6.2 ¿Qué técnica utilizarías para un área de analítica?

Para un área de analítica utilizaría **seudonimización y separación de funciones**.

El área de analítica necesita trabajar con información de los clientes para identificar patrones y tendencias, pero no requiere conocer directamente su identidad.

En el laboratorio se sustituyó la identificación directa mediante tokens UUID y se creó el conjunto `analitica.clientes`.

La relación entre el token y el identificador original se mantiene de forma separada en `pii.mapa_cliente`.

El rol `analista_23101075` puede consultar el conjunto analítico, pero no puede acceder al mapa de correspondencia ni a la tabla original `public.clientes`.

Esta separación reduce el riesgo de identificación directa y aplica los principios de mínimo privilegio y separación de funciones.

### 6.3 ¿Qué técnica utilizarías para publicar estadísticas?

Para publicar estadísticas utilizaría técnicas de **anonimización, generalización, agregación y supresión de grupos pequeños**.

La información publicada no debería contener identificadores directos y los cuasi-identificadores deberían presentar un nivel de detalle suficientemente reducido.

En la práctica se generalizó la edad mediante rangos y el código postal mediante regiones.

También se analizaron los tamaños de los grupos y se utilizó un umbral didáctico de cinco registros para estudiar el riesgo de reidentificación.

Sin embargo, cumplir con un determinado tamaño mínimo de grupo no garantiza por sí mismo que los datos sean completamente anónimos, por lo que debe evaluarse también el contexto y la posibilidad de combinar la información con otras fuentes.

### 6.4 ¿Por qué ninguna de estas técnicas sustituye al control de acceso?

El enmascaramiento, la seudonimización y la anonimización permiten reducir la exposición de los datos, pero no sustituyen al control de acceso.

Un usuario que conserve privilegios innecesarios podría acceder directamente a las tablas originales y evitar las protecciones aplicadas mediante vistas o conjuntos derivados.

Por esta razón, la protección de datos debe complementarse con roles, permisos, `GRANT`, `REVOKE`, separación de funciones y el principio de mínimo privilegio.

El laboratorio demostró esta situación al impedir que `soporte_23101075` accediera directamente a `clientes` y que `analista_23101075` consultara tanto `pii.mapa_cliente` como `public.clientes`.

En conclusión, cada técnica resuelve un problema diferente y debe formar parte de una estrategia de seguridad en capas.

---

## 7. Preguntas de reflexión

## 7. Preguntas de reflexión

### 1. ¿Cuál es la diferencia entre enmascaramiento y seudonimización?

El enmascaramiento modifica la forma en que un dato es presentado a determinados usuarios sin necesariamente sustituir el valor almacenado en la tabla original.

Por ejemplo, en el laboratorio el correo electrónico, teléfono y RFC continúan almacenados completos en `clientes`, pero el rol de soporte solamente puede observar versiones parcialmente ocultas mediante `v_clientes_soporte`.

La seudonimización, en cambio, sustituye un identificador por otro valor, como un token UUID. La relación con la identidad original todavía puede recuperarse mediante información adicional, como `pii.mapa_cliente`.

### 2. ¿Por qué la seudonimización no significa anonimización?

La seudonimización no significa anonimización porque continúa existiendo información que permite volver a relacionar los datos con una persona.

En este laboratorio, `pii.mapa_cliente` contiene la relación entre cada token y el `cliente_id`.

Mientras exista esta correspondencia y sea posible acceder a la tabla original, la identidad puede recuperarse por parte de usuarios autorizados.

### 3. ¿Por qué eliminar `nombre` y `RFC` no garantiza que un conjunto de datos sea anónimo?

Porque pueden permanecer otros atributos que, al combinarse, permitan distinguir o volver a identificar a una persona.

Datos como edad, ciudad, código postal y fecha de alta pueden funcionar como cuasi-identificadores.

Aunque ninguno identifique directamente a una persona por sí solo, su combinación puede producir grupos muy pequeños o incluso registros únicos.

### 4. ¿Qué función tienen los cuasi-identificadores?

Los cuasi-identificadores son atributos que no necesariamente identifican directamente a una persona, pero pueden contribuir a hacerlo cuando se combinan con otros datos.

En el laboratorio se identificaron como posibles cuasi-identificadores la edad, ciudad, código postal y fecha de alta.

Su análisis es importante al evaluar el riesgo de reidentificación.

### 5. ¿Por qué es importante separar el mapa de seudonimización?

El mapa contiene la correspondencia entre el token utilizado en el conjunto seudonimizado y el identificador original.

Si cualquier usuario que puede consultar los datos seudonimizados también pudiera consultar el mapa, podría recuperar fácilmente la relación con los registros originales.

Por esta razón, `pii.mapa_cliente` debe contar con controles de acceso más estrictos que `analitica.clientes`.

### 6. ¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?

Se aplica principalmente el principio de **separación de funciones**.

También se aplica el principio de **mínimo privilegio**, porque el analista recibe únicamente los permisos necesarios para trabajar con el conjunto analítico y no aquellos que permitirían recuperar directamente la identidad del cliente.

### 7. ¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?

Una vista permite controlar qué columnas y qué representación de los datos puede consultar un usuario.

En el laboratorio, `v_clientes_soporte` permite mostrar información útil para soporte mientras mantiene parcialmente ocultos correo, teléfono y RFC.

Si se otorgara acceso directo a `clientes`, el usuario podría consultar los valores completos y evitar el mecanismo de enmascaramiento.

### 8. ¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?

Proteger un dato para visualización consiste en limitar o modificar la forma en que se presenta, por ejemplo mediante enmascaramiento.

Protegerlo contra acceso no autorizado implica controlar quién puede consultar, modificar o utilizar realmente la información.

Por ello, una vista enmascarada debe complementarse con permisos de base de datos. No sería suficiente ocultar el valor si el mismo usuario conserva acceso directo a la tabla original.

### 9. ¿Por qué la retención forma parte de la protección de datos?

La retención forma parte de la protección de datos porque conservar información durante más tiempo del necesario aumenta la cantidad de datos expuestos ante incidentes de seguridad.

Una política de retención permite definir durante cuánto tiempo debe mantenerse la información y establecer un procedimiento controlado para su eliminación cuando deje de ser necesaria.

### 10. ¿Qué riesgo existe si una organización conserva información indefinidamente?

Conservar información indefinidamente incrementa el volumen de datos expuestos y, por lo tanto, el impacto potencial de una brecha o acceso no autorizado.

Además, pueden conservarse datos que ya no sean necesarios para la finalidad original.

Una política adecuada de retención reduce esta exposición y debe incluir criterios de eliminación, autorización, respaldos, trazabilidad y procedimientos de recuperación.