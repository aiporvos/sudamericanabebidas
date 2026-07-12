---
name: estandares-observabilidad
description: >-
  Usar al instrumentar cualquier servicio del stack custom con logs, trazas o métricas, o al
  definir alertas. Fija convenciones de observabilidad end-to-end (correlation id, OpenTelemetry,
  nombres). Se activa con "logs", "trazas", "métricas", "observabilidad", "alertas", "OpenTelemetry".
allowed-tools: Read, Glob, Grep
---

# Estándares de observabilidad end-to-end

> Convenciones para que evidencia → cola → worker → DB → alerta sea trazable en toda la cadena.
> La mecánica del SDK/collector va con **context7**.

## Correlation id
- Un `evidence_id` (o `trace_id`) se genera en la ingesta y **viaja** por header/atributo de
  mensaje en cada salto: webhook → cola → vision worker → persistencia → alerta.
- Todo log y span incluye ese id; permite reconstruir el ciclo de una evidencia.

## Logs
- **Estructurados** (JSON), a stdout (12-factor). Sin secretos ni imágenes en el log.
- Campos mínimos: timestamp, nivel, servicio, evidence_id, proceso, línea, mensaje.

## Trazas y métricas (OpenTelemetry)
- Un span por etapa; atributos: proceso, línea, modelo/proveedor, confianza, resultado.
- Métricas base: throughput de evidencias, latencia por etapa, tasa de fallback, tasa de error.

## Alertas (accionables, con evidencia y timestamp)
- De sistema: caídas, latencia, errores.
- De negocio: rechazos frecuentes, máquinas fuera de rango, errores de envío, incumplimientos.
- Cada alerta enlaza la **evidencia** y su **timestamp** (requisito del negocio).
