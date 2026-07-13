# Historia de Usuario — Calidad de Lata (captura y gestión de evidencias con IA)

> slug: `calidad-lata` · prioridad: `Alta` · fecha: `2026-07-04`

## Supuestos
- ⚠️ **Canal de ingesta:** la vía por la que llegan las fotos se decide en `adr/ADR-001-ingesta-telegram.md`.
  Meta **no** ofrece una Groups API oficial para WhatsApp; se recomienda **Telegram**. _(crítico — confirmar con el cliente)_
- ⚠️ **Mapeo evidencia→línea:** existe un grupo/canal por línea, o un metadato que permite asociar
  cada foto a su línea/equipo/proceso. _(crítico)_
- Los operarios envían las fotos con frecuencia horaria (operativa actual: 183 grupos, 3 líneas).
- El umbral de confianza para el fallback es configurable (valor inicial en `ADR-003`).
- La imagen original se conserva como evidencia para auditoría y reclamos.

## Historia
**Como** responsable de Calidad y Producción,
**quiero** automatizar la captura, interpretación y gestión de las evidencias de calidad mediante IA de visión,
**para** reducir el trabajo manual, centralizar la información, mejorar la trazabilidad y detectar desvíos en tiempo real.

## Descripción del caso de negocio
Hoy el control se hace manual: los operarios sacan fotos de contadores y controles y las comparten en
grupos de mensajería; luego otras personas reprocesan lo mismo para consolidar datos, generar indicadores
y responder reclamos. Esto genera duplicación, alto esfuerzo, errores de transcripción, dificultad para
localizar evidencias históricas y baja reacción ante desvíos. El **MVP es Calidad de Lata**, dejando la
solución preparada para PET, Trazabilidad, Arranques de Línea, Cambios de Producto, Paradas No Planificadas y CO₂.

## Criterios de Aceptación
> Numerados y testeables. Trazabilidad criterio→nodo en `workflows/calidad-lata.README.md`.

1. Al recibir una evidencia, el sistema **registra fecha y hora de captura** y **conserva la imagen original
   sin modificar**, recuperable para auditoría.
2. Cada evidencia queda **asociada a proceso, línea y equipo/puesto** de origen.
3. El sistema **extrae automáticamente los valores de contadores** presentes en la imagen.
4. El sistema **detecta defectos visuales** de las categorías definidas: impresión, centrado, inclinación,
   deformación, etiqueta, contraetiqueta.
5. El sistema **clasifica** cada evidencia como **OK** o **No OK** según los criterios de calidad.
6. Cuando la **confianza** de la interpretación es **menor al umbral definido**, la evidencia se **deriva a
   revisión manual** y **no se fuerza** una clasificación.
7. En revisión manual, un operador puede **confirmar, corregir o rechazar** el resultado sugerido, y la
   decisión queda **registrada con autor y timestamp**.
8. La información se persiste en un **repositorio único y estructurado**, **sin duplicar** una misma
   evidencia (cada evidencia se procesa una sola vez).
9. Se puede **consultar el histórico** filtrando por fecha, línea, equipo y proceso.
10. Ante un **desvío** (resultado No OK o medición fuera de parámetros), el sistema **emite una alerta** que
    incluye la **evidencia** y su **timestamp**.
11. La solución permite **incorporar nuevos procesos** (PET, Trazabilidad, etc.) **sin cambios estructurales**.

> Criterios 12–17 derivados de la **minuta del 25/06/2026** (`docs/requisitos/minuta-2026-06-25.md`),
> sección "Controles actuales — Latas" (tapa, impresión del fondo, pantalla del contador, frente),
> "Información importante de las fotos" y "Consideraciones técnicas".

12. El sistema **clasifica el tipo de foto** recibida: `tapa` | `fondo_impresion` |
    `pantalla_contador` | `frente` | `otro`, y lo registra con la evidencia.
13. Cuando la foto es de una **pantalla/contador**, el sistema extrae la **hora visible en la
    pantalla** (además de la hora de envío del mensaje), para poder determinar **desde cuándo**
    comenzó un problema.
14. Cuando la foto es de la **impresión del fondo**, el sistema extrae el **texto impreso**
    (lote, hora, vencimiento) y califica la **calidad de impresión** (`buena`/`mala`) además de
    los defectos visuales — un dato correcto con mala impresión debe detectarse (caso "láser mal
    calibrado").
15. El sistema **compara** la impresión del fondo con la evidencia de `pantalla_contador` más
    reciente de la **misma línea** (ventana ±90 min): si el dato impreso es **incoherente** con la
    pantalla, o la calidad de impresión es mala, el resultado es **No OK** con **motivo** registrado.
16. Los **textos y etiquetas leídos** por la IA se **persisten** en la base (búsqueda ante reclamos
    sin revisar cientos de fotos).
17. Cada inferencia registra los **tokens consumidos** (la minuta pide modelos de bajo costo y
    **medir consumo de tokens**).

> Criterios 18–21 derivados de la auditoría contra la minuta (11/07): planillas, duplicación
> entre grupos, comparativos y parámetros operativos.

18. El sistema **genera automáticamente la planilla** del período (CSV con el detalle de
    evidencias) y un **resumen de indicadores** (OK/No OK, revisiones, duplicadas,
    incoherencias, producción, costo IA), y los envía sin intervención manual.
19. Si la **misma imagen** llega por **más de un grupo** dentro de la ventana configurada,
    la segunda se registra como **duplicada** y **no se vuelve a procesar** (minuta:
    "eliminar información duplicada").
20. Los **contadores** alimentan vistas de **producción horaria** y **comparativos entre
    líneas/máquinas** consultables sin reprocesar fotos.
21. Los **parámetros operativos** (umbral de confianza, ventana de comparación, ventana de
    dedup) y el **mapeo grupo→línea** se ajustan **por datos** (tablas `config` y
    `lineas_grupos`), sin modificar ni re-desplegar flujos.

> Criterios 22–23 derivados del checklist de cierre del MVP (13/07): consulta sin SQL con
> imagen, y medición de latencia (`docs/plan-cierre-mvp.md`).

22. Un analista **consulta el histórico sin SQL** desde el **dashboard web**
    (https://dashboard.cluna.ar): filtros por fecha/línea/tipo/resultado/estado y búsqueda
    libre, y el **detalle de cada evidencia muestra la imagen original** (desde MinIO),
    motivo, coherencia, textos leídos y confianza.
23. El sistema **mide la latencia** de punta a punta (foto en Telegram → resultado IA,
    `evaluado_en − capturado_en`) y la expone por evidencia y como **p95** en el dashboard,
    para aprobar el piloto con métricas objetivas.

> Criterio 24: entregable adicional, no pedido explícitamente en la minuta pero derivado del
> objetivo de "consulta rápida sin reprocesar" — un canal conversacional sobre el mismo dato.

24. Un usuario puede **consultar evidencias y métricas en lenguaje natural** desde un
    **chat integrado al dashboard** ("Lupa"): preguntas de conteos/comparaciones entre
    líneas responden con **datos reales** (no inventados), preguntas sobre casos puntuales
    devuelven el **motivo** registrado, y el chat **mantiene contexto** dentro de una misma
    sesión (preguntas de seguimiento sin repetir el contexto).

## Alcance del MVP
- Proceso **Calidad de Lata** únicamente.
- Captura → interpretación IA → clasificación OK/No OK → fallback a revisión manual → persistencia → alerta.
- Consulta histórica básica y evidencia auditable.

**Fuera del MVP (procesos futuros):** Calidad PET, Trazabilidad, Arranques de Línea, Cambios de Producto,
Paradas No Planificadas, CO₂.

## Beneficios esperados
- Menos trabajo manual y reproceso de los operadores.
- Información única, sin duplicación, con búsqueda rápida de evidencias.
- Detección de desvíos en tiempo real, con evidencia y timestamp.
- Trazabilidad completa para auditoría y reclamos.

## Diagramas
- Proceso (BPMN): `docs/diagramas/calidad-lata-bpmn.drawio`
- Arquitectura: `docs/diagramas/calidad-lata-arquitectura.drawio`
- API + dashboard (WF6): `docs/diagramas/calidad-lata-wf6-api-dashboard.drawio`
- Chat "Lupa" (WF7 + WF7b): `docs/diagramas/calidad-lata-wf7-chat-asistente.drawio`

## Fuente de verdad
- `docs/requisitos/minuta-2026-06-25.md` — minuta textual de la reunión con el cliente (25/06/2026).

## Casos de uso
- `docs/casos-de-uso/` — CU-01 enviar evidencia · CU-02 interpretar con IA · CU-03 validar
  coherencia impresión↔pantalla · CU-04 revisión manual · CU-05 alertar desvío · CU-06
  consultar histórico en el dashboard · CU-07 reporte y planilla · CU-08 dedup entre grupos ·
  CU-09 consultar por chat con Lupa (índice en `docs/casos-de-uso/README.md`).

## Decisiones relacionadas (ADR)
- `adr/ADR-001-ingesta-telegram.md` — canal de ingesta.
- `adr/ADR-002-arquitectura-n8n-hibrida.md` — n8n vs custom vs híbrido.
- `adr/ADR-003-vision-ia-umbral-fallback.md` — modelo de visión, umbral y fallback.
- `adr/ADR-004-dedup-idempotencia.md` — no-duplicación de evidencias.
