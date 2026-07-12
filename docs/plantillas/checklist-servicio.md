# Checklist de puesta en marcha — servicio `<nombre>` (caso `<slug>`)

## Configuración y seguridad
- [ ] Config por variables de entorno; `.env.example` actualizado.
- [ ] Sin secretos en el repo (hook guard-secrets respetado).

## Contrato y datos
- [ ] Entradas/salidas cumplen el contrato de datos (skill `contrato-datos-vision`).
- [ ] Idempotencia/dedup garantizada (constraint DB / clave de cola).

## Robustez
- [ ] Errores manejados; reintentos/backoff donde aplica; sin fallo silencioso.
- [ ] Tests unitarios del núcleo + 1 test de integración del camino principal.

## Observabilidad
- [ ] Logs estructurados a stdout, sin secretos.
- [ ] Trazas OpenTelemetry con correlation id end-to-end.
- [ ] Métricas base y alertas accionables definidas.

## Despliegue
- [ ] Dockerfile / build reproducible; levanta con un comando en entorno limpio.
- [ ] Runbook (`docs/plantillas/runbook.md`) completado.

## Trazabilidad
- [ ] Cada criterio de aceptación (1..N) mapeado a endpoint/worker/tabla/vista.
- [ ] ADRs referenciados desde el README del servicio.
