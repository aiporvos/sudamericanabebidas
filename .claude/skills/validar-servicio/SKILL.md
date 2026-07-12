---
name: validar-servicio
description: >-
  Usar al validar o dar por terminado un microservicio del stack custom (backend, vision, data,
  front) antes de desplegar. Corre el checklist de puesta en marcha del servicio y el mapeo
  criterio de aceptación → componente. Se activa con "validá el servicio", "está listo para
  deploy", "revisá el backend/worker".
allowed-tools: Read, Glob, Grep
---

# Validar un servicio antes de cerrarlo

> Gate de proceso (checklist + trazabilidad) para el camino custom, análogo a `validar-flujo-n8n`.
> La mecánica del lenguaje/framework va con **context7**, no acá.

Aplicá sobre el servicio (`services/*`, `apps/*`, `db/`, `bi/`, `deploy/`) antes de considerarlo
hecho. Base: `docs/plantillas/checklist-servicio.md`.

1. **Config por entorno:** nada hardcodeado; variables en `.env.example`; secretos fuera del repo.
2. **Contrato de datos:** entradas/salidas cumplen la skill `contrato-datos-vision`; validado.
3. **Idempotencia:** la misma evidencia no duplica efecto (constraint DB / clave de cola).
4. **Errores:** fallos manejados; reintentos/backoff donde aplica; nada de fallo silencioso.
5. **Observabilidad:** logs estructurados + trazas OpenTelemetry con correlation id end-to-end
   (skill `estandares-observabilidad`).
6. **Tests:** unitarios del núcleo + al menos un test de integración del camino principal.
7. **Contenedor:** build reproducible; levanta con un comando en entorno limpio.
8. **Trazabilidad:** cada criterio de aceptación de la HU mapeado a endpoint/worker/tabla/vista;
   gaps marcados y devueltos a `dev-tech-lead`.

**Hecho** = checklist completo, contrato cumplido, criterios trazados (o gaps marcados).
