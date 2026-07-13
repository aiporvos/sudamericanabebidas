# Casos de uso — Calidad de Lata

> Derivados de la **minuta 25/06/2026** (`docs/requisitos/minuta-2026-06-25.md`) y la
> **HU** (`docs/requisitos/HU-calidad-lata.md`). Cada caso traza a criterios de aceptación
> y a su implementación real en n8n.

## Actores
- **Operario de planta** — saca y envía las fotos cada hora (por línea).
- **Supervisor / operador de calidad** — recibe alertas y resuelve la revisión manual.
- **Analista de calidad** — consulta histórico ante reclamos y arma indicadores.
- **Sistema** — n8n (WF1–WF7b) + OpenAI visión + MinIO/Postgres/RabbitMQ + dashboard web
  (https://dashboard.cluna.ar) + chat "Lupa" (AI Agent sobre OpenRouter).

## Índice

| CU | Nombre | Actor principal | Estado |
|---|---|---|---|
| [CU-01](CU-01-enviar-evidencia.md) | Enviar y registrar evidencia fotográfica | Operario | ✅ WF1 |
| [CU-02](CU-02-interpretar-con-ia.md) | Interpretar evidencia con IA | Sistema | ✅ WF2 |
| [CU-03](CU-03-validar-coherencia.md) | Validar coherencia impresión ↔ pantalla | Sistema | ✅ WF2 |
| [CU-04](CU-04-revision-manual.md) | Resolver revisión manual (fallback) | Supervisor | ✅ WF4 |
| [CU-05](CU-05-alertar-desvio.md) | Alertar desvío en tiempo real | Sistema | ✅ WF2/WF3 |
| [CU-06](CU-06-consultar-historico.md) | Consultar histórico ante reclamo | Analista | ✅ WF6 + dashboard.cluna.ar |
| [CU-07](CU-07-reporte-planilla.md) | Generar reporte y planilla automática | Sistema | ✅ WF5 + vistas BI |
| [CU-08](CU-08-dedup-entre-grupos.md) | Detectar misma foto en varios grupos | Sistema | ✅ WF1 v3 (hash) |
| [CU-09](CU-09-chat-asistente.md) | Consultar evidencias y métricas por chat | Analista | ✅ WF7 + WF7b (Lupa) |

## Diagramas relacionados
- Proceso (BPMN): `../diagramas/calidad-lata-bpmn.drawio`
- Arquitectura: `../diagramas/calidad-lata-arquitectura.drawio`
- Flujos: `../diagramas/calidad-lata-wf1-ingesta.drawio`, `../diagramas/calidad-lata-wf2-procesamiento.drawio`,
  `../diagramas/calidad-lata-wf5-reporte.drawio`, `../diagramas/calidad-lata-wf6-api-dashboard.drawio`,
  `../diagramas/calidad-lata-wf7-chat-asistente.drawio`
- Exportados a imagen: `../diagramas/png/`
