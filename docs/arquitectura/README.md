# Arquitectura de referencia — solución custom (microservicios)

Este documento describe el **segundo camino de build** del equipo: además de generar flujos n8n,
el equipo puede construir la solución custom completa del diagrama "MVP Captura y Gestión de
Evidencias de Calidad". Corresponde al escalado descrito en el glosario de `CLAUDE.md`.

## Tres caminos de build

La elección se hace con la skill **`elegir-arquitectura`** y se documenta en un **ADR** de
`arquitecto-infra`:

- **n8n** (rápido, MVP): `n8n-builder`.
- **custom** (control/escala): builders por capa (abajo).
- **híbrido** (recomendado como MVP escalable): n8n orquesta + servicios custom para lo pesado.

## Capas del diagrama → builder → carpeta

| Capa del diagrama | Builder | Carpeta |
|---|---|---|
| Ingesta + Backend + Orquestación + Cola | `backend-builder` | `services/backend/` |
| Procesamiento con IA (visión/OCR) | `vision-builder` | `services/vision/` |
| Almacenamiento (Postgres, S3/R2) + BI | `data-builder` | `db/`, `bi/` |
| Presentación (dashboard + revisión manual) | `frontend-builder` | `apps/dashboard/` |
| Observabilidad + despliegue | `devops-sre` | `deploy/` |

La decisión de stack (infra) y los componentes custom (dev) siguen viniendo de `arquitecto-infra`
y `dev-tech-lead` — igual que en el camino n8n. El **contrato de datos**
(skill `contrato-datos-vision`, plantilla `docs/plantillas/contrato-datos.md`) es la fuente de
verdad compartida entre todos los builders.

## ⚠️ Riesgo transversal: ingesta de WhatsApp

Meta **no** ofrece una "WhatsApp Groups API" oficial para leer mensajes de grupos arbitrarios. La
WhatsApp Business Cloud API es conversaciones 1:1, no grupos. La ingesta de los **183 grupos** debe
resolverse en un ADR (WhatsApp Business Cloud API, o un bridge que cumpla términos) **antes** de
construir el backend. Aplica a n8n y a custom por igual.

## Escalado a procesos futuros

El modelo de datos y los servicios se diseñan **multiproceso** (proceso como dimensión de config):
PET, Trazabilidad, Arranques de Línea, Cambios de Producto, Paradas No Planificadas y CO₂ se
agregan sin cambios estructurales (ver glosario en `CLAUDE.md`).
