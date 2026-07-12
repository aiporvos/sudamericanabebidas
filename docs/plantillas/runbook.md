# Runbook — servicio `<nombre>` (caso `<slug>`)

## Resumen
- Qué hace, de qué caja del diagrama es responsable, de qué depende (DB, cola, storage, APIs).

## Despliegue
- Cómo se buildea y despliega (comando / pipeline).
- Variables de entorno requeridas (ver `.env.example`).

## Operación
- Cómo escalar (p. ej. réplicas del worker de la cola).
- Health checks / endpoints de estado.

## Rollback
- Cómo volver a la versión anterior; migraciones reversibles (si aplica).

## Alertas y on-call
| alerta | umbral | acción |
|---|---|---|
| latencia alta | `<definir>` | `<acción>` |
| tasa de error | `<definir>` | `<acción>` |
| rechazos frecuentes | `<definir>` | `<acción>` |

## Observabilidad
- Dónde ver logs (ELK/OpenSearch), trazas (OpenTelemetry) y dashboards (Grafana/Datadog).
- Cómo seguir una evidencia por su `evidence_id` end-to-end.
