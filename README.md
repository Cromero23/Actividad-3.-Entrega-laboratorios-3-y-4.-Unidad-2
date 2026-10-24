# Unidad II — Entrega de Laboratorios 3 y 4

## Descripción

Este repositorio contiene las actividades de la Unidad II de la materia **Gestión de Seguridad y Desempeño de Bases de Datos**, enfocadas en la seguridad, privacidad, cumplimiento y configuración segura de bases de datos mediante PostgreSQL 16.

La entrega se centra en los **Laboratorios 3 y 4**, donde se desarrollaron prácticas relacionadas con el gobierno de datos, derechos ARCO, minimización de información, hardening, autenticación, autorización y protección de servidores de bases de datos.

Se incluyen los scripts SQL, documentación en Markdown, informes, resultados y capturas de pantalla obtenidas durante las actividades realizadas en PostgreSQL 16, pgAdmin 4 y Windows.

El repositorio también conserva los Laboratorios 1 y 2 como parte del trabajo previo de la Unidad II.

## Laboratorio 03 — Privacidad, cumplimiento y gobierno de los datos

Desarrollo de 15 actividades relacionadas con la administración responsable de datos personales, su protección y las finalidades autorizadas de tratamiento.

Entre los principales temas abordados se encuentran:

- Identificación, clasificación e inventario de datos personales.
- Aplicación del principio de minimización de datos.
- Separación de información según su finalidad.
- Implementación de roles, vistas y permisos restringidos.
- Análisis de finalidades secundarias.
- Simulación de los derechos ARCO: acceso, rectificación, cancelación y oposición.
- Evaluación del ciclo de vida y retención de la información.
- Elaboración de matrices de gobierno de datos.
- Aplicación de los principios de privacidad por diseño.
- Identificación de controles técnicos y administrativos.
- Evaluación integral de riesgos de privacidad.
- Propuesta de una arquitectura de datos protegidos.

Las actividades incluyen consultas SQL, documentación de análisis y 11 capturas de pantalla que demuestran los resultados obtenidos en PostgreSQL.

**Archivos principales:**
- 3 scripts SQL.
- 8 documentos Markdown de evidencias.
- 11 capturas de pantalla.
- README con desarrollo, resultados y preguntas de reflexión.

[Consultar Laboratorio 03](https://github.com/Cromero23/Actividad-3.-Entrega-laboratorios-3-y-4.-Unidad-2/blob/main/laboratorio-03-privacidad-cumplimiento/README.md)

## Laboratorio 04 — Hardening y configuración segura de PostgreSQL

Desarrollo de 19 actividades enfocadas en la inspección, evaluación y fortalecimiento de la seguridad de un servidor PostgreSQL 16 instalado localmente en Windows.

Entre los principales temas abordados se encuentran:

- Identificación de la superficie de ataque del servidor.
- Inspección de archivos de configuración.
- Revisión de interfaces de escucha mediante `listen_addresses`.
- Análisis de reglas de autenticación en `pg_hba.conf`.
- Evaluación de reglas permisivas y propuestas de mínimo privilegio.
- Verificación de autenticación SCRAM-SHA-256.
- Revisión de usuarios, roles y privilegios administrativos.
- Separación conceptual de cuentas DBA, aplicación y consulta.
- Inspección de extensiones instaladas.
- Evaluación de límites de conexiones y tiempos de espera.
- Revisión de permisos NTFS mediante PowerShell.
- Comprobación de la exposición de red y conectividad local.
- Diseño de políticas restrictivas de firewall.
- Verificación de comunicaciones cifradas mediante TLS 1.3.
- Comparación de configuraciones iniciales y finales.
- Elaboración de un checklist de hardening de 18 controles.
- Evaluación integral de riesgos y medidas correctivas.
- Construcción de una línea base de seguridad de PostgreSQL.

Se realizaron verificaciones reales mediante pgAdmin 4 y PowerShell, documentando los controles existentes y distinguiendo las mejoras propuestas de las configuraciones efectivamente implementadas.

**Archivos principales:**
- 4 scripts SQL.
- 2 documentos de configuración: `baseline.md` y `cambios.md`.
- 18 capturas de pantalla.
- Informe técnico con preguntas de reflexión y conclusiones.
- README con resultados, hallazgos y evidencias.

[Consultar Laboratorio 04](https://github.com/Cromero23/Actividad-3.-Entrega-laboratorios-3-y-4.-Unidad-2/blob/main/laboratorio-04-hardening/README.md)

## Herramientas utilizadas

- **PostgreSQL 16:** administración y verificación de configuraciones de seguridad.
- **pgAdmin 4:** ejecución de consultas SQL, revisión de roles y comprobación de resultados.
- **Windows PowerShell:** inspección de servicios, permisos NTFS y conexiones de red.
- **Visual Studio Code:** elaboración de scripts SQL, informes y documentación Markdown.
- **OpenSSL:** generación y administración de certificados utilizados en las prácticas previas de TLS.
- **Git y GitHub:** control de versiones y publicación de los laboratorios.

## Resultados generales

Los laboratorios permitieron aplicar conocimientos relacionados con la protección integral de bases de datos.

En el **Laboratorio 3** se implementaron mecanismos de minimización y acceso restringido, además de analizar las responsabilidades relacionadas con la privacidad y el ciclo de vida de los datos personales.

En el **Laboratorio 4** se verificaron los principales controles de seguridad de PostgreSQL 16, incluyendo interfaces locales, autenticación SCRAM-SHA-256, privilegios de usuarios y conexiones TLS 1.3.

También se identificaron oportunidades de mejora relacionadas con auditoría, tiempos de espera, gestión de cuentas y mantenimiento.

Las actividades permitieron comprender que la seguridad de una base de datos requiere tanto controles técnicos como políticas y procedimientos administrativos.

## Consideraciones de seguridad

Los datos personales y las credenciales utilizadas en las demostraciones son ficticios y tienen fines exclusivamente académicos.

No se incluyen contraseñas reales, claves privadas, tokens de acceso ni otros secretos en los archivos del repositorio.

Las configuraciones propuestas durante los laboratorios se encuentran documentadas y no deben interpretarse como modificaciones implementadas cuando solamente fueron objeto de análisis.

## Autor

**Carlos Romero**  
Licenciatura en Informática  
Facultad de Informática Culiacán  
Universidad Autónoma de Sinaloa