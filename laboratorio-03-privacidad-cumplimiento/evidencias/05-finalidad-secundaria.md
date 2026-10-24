# LAB-03 — Actividad 5  
## Análisis de una finalidad secundaria

### Escenario
La organización propone utilizar los datos de clientes para una nueva finalidad:

> “Enviar promociones personalizadas basadas en la edad, ciudad y comportamiento de compra.”

---

## 1. ¿El hecho de que la organización ya tenga los datos significa automáticamente que puede utilizarlos para cualquier finalidad?

No. El hecho de que la organización ya posea los datos no significa que pueda utilizarlos libremente para cualquier nueva finalidad. Los datos personales deben tratarse conforme a una finalidad específica, legítima y previamente definida. Si se pretende usar la información para un propósito distinto al original, la organización debe analizar si esa nueva finalidad es compatible con la original, si fue informada al titular y si requiere consentimiento adicional.

En este caso, usar los datos para promociones personalizadas representa una finalidad distinta a la administración operativa de clientes, soporte o facturación. Por ello, no debe asumirse automáticamente como permitida.

---

## 2. ¿Qué preguntas debería realizar la organización antes de implementar este tratamiento?

Antes de implementar esta nueva finalidad, la organización debería preguntarse:

- ¿La finalidad de marketing fue informada previamente al titular?
- ¿Existe consentimiento para utilizar los datos con fines promocionales?
- ¿La nueva finalidad es compatible con la finalidad original de recolección?
- ¿Qué datos son estrictamente necesarios para realizar promociones personalizadas?
- ¿Es posible cumplir el objetivo con datos agregados o parcialmente anonimizados?
- ¿Qué riesgos para la privacidad existen al usar estos datos?
- ¿Qué controles técnicos y administrativos deben aplicarse?
- ¿Quién tendrá acceso a la información?
- ¿Se requiere actualizar el aviso de privacidad?
- ¿Existe algún mecanismo para que el titular se oponga a este tratamiento?

---

## 3. ¿Qué datos serían realmente necesarios?

No todos los datos de la tabla `clientes` son necesarios.

Para promociones personalizadas podrían considerarse necesarios únicamente:

- `id` (como identificador interno)
- `correo` o un medio de contacto autorizado
- `edad` o, preferentemente, un rango de edad
- `ciudad`
- información de comportamiento de compra, si existe y si fue obtenida legítimamente para esa finalidad

No serían necesarios directamente para esta finalidad:

- `rfc`
- `telefono` (si no se usarán llamadas o mensajes)
- `codigo_postal` completo
- `fecha_alta`, salvo que exista una justificación clara
- `nombre`, si la personalización puede realizarse sin identificar nominalmente al cliente

Además, desde el principio de minimización, conviene utilizar rangos de edad en lugar de la edad exacta cuando sea suficiente para el análisis.

---

## 4. ¿Necesitaría el área de marketing acceso directo a `clientes`?

No debería tener acceso directo a la tabla completa `clientes`.

Otorgar acceso directo a esa tabla expondría más información de la necesaria, incluyendo datos que no son relevantes para marketing, como RFC, teléfono o código postal completo. Lo adecuado sería proporcionar una vista, tabla derivada o conjunto de datos controlado que incluya únicamente los campos estrictamente necesarios para la finalidad autorizada.

Esto reduce el riesgo de uso excesivo de datos y aplica el principio de mínimo privilegio.

---

## 5. ¿Qué controles técnicos podrían limitar la información entregada?

Algunos controles técnicos apropiados serían:

- Crear una **vista específica** para marketing con solo los campos necesarios.
- Utilizar **rangos de edad** en vez de edad exacta.
- Mostrar solo la **ciudad** o una región general, en lugar del código postal completo.
- Aplicar **roles y permisos** para que marketing no consulte la tabla `clientes` directamente.
- Restringir el acceso mediante **GRANT SELECT** solo sobre la vista autorizada.
- Registrar accesos mediante **auditoría** o bitácoras.
- Aplicar **seudonimización** o identificadores internos cuando sea posible.
- Limitar exportaciones o copias no autorizadas de la información.
- Definir políticas de **retención** y eliminación de datos para campañas.
- Implementar controles organizacionales complementarios, como autorización formal y revisión de cumplimiento.

---

## Conclusión

La nueva finalidad propuesta no debe asumirse como válida solo porque la organización ya posee los datos. Antes de implementar promociones personalizadas, se debe revisar la base legal o el consentimiento, aplicar el principio de minimización y evitar el acceso directo a la tabla completa de clientes. La mejor práctica es entregar únicamente la información estrictamente necesaria mediante vistas controladas y permisos restringidos.