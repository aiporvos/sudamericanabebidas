# ADR-001: Canal de ingesta de evidencias

> estado: `propuesta` · autor: `infra` · fecha: `2026-07-04`
> caso: `calidad-lata`

## Contexto
La operativa actual usa **183 grupos de WhatsApp** donde los operarios comparten fotos. Necesitamos
recibir esas imágenes en el sistema de forma automática, confiable y que cumpla términos. Impacta los
criterios de aceptación 1, 2 y 11.

## Opciones evaluadas
### Opción A — Telegram (Bot API)
- Pros: **API oficial y gratuita para grupos**; un bot en cada grupo recibe las fotos por webhook;
  metadatos limpios (grupo, remitente, message_id, fecha); nodo nativo en n8n; sin riesgo de baneo.
- Contras: los operarios hoy usan WhatsApp → **costo de adopción** (cambiar de app).
- Costo / esfuerzo operativo: bajo. Sin costo por mensaje.
- Verificado con context7/WebSearch: `sí — Telegram Bot API soporta lectura de mensajes de grupos`.

### Opción B — WhatsApp Business Cloud API (Meta)
- Pros: los operarios ya usan WhatsApp.
- Contras: **no existe Groups API oficial** para leer mensajes de grupos arbitrarios (es 1:1);
  costo por conversación; no cubre el caso real.
- Costo / esfuerzo operativo: alto y con bloqueante funcional.

### Opción C — Proveedor no oficial (Evolution API / WPPConnect)
- Pros: permite leer grupos de WhatsApp sin cambiar de app.
- Contras: **fuera de términos de Meta**, riesgo de baneo del número, frágil de operar.

## Decisión
**Opción A — Telegram.** Es la única que resuelve la lectura de grupos con una API oficial, gratuita y
sin riesgo de baneo, y tiene integración nativa en n8n. Se descarta B por bloqueante funcional (sin
Groups API) y C por incumplimiento de términos y fragilidad. El desafío pasa a ser **de adopción**
(que los operarios envíen por Telegram), no técnico.

## Consecuencias
- Requiere un bot de Telegram agregado a los grupos y un plan de adopción con los operarios.
- Habilita el mapeo evidencia→línea vía grupo/canal (supuesto crítico de la HU).
- Criterios de aceptación afectados: `1, 2, 11`.
