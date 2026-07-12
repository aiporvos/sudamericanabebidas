# Contrato de datos — evidencia → estructura (caso `<slug>`)

> Fuente de verdad compartida por `vision-builder`, `backend-builder` y `data-builder`.
> Ver skill `contrato-datos-vision`. Ajustá campos/tipos según la HU y el ADR de visión.

## Identidad de la evidencia
| campo | tipo | descripción |
|---|---|---|
| evidence_id | string/uuid | id único (correlation id end-to-end) |
| proceso | enum | calidad-lata, pet, trazabilidad, … |
| linea | string | línea de producción |
| equipo | string | equipo/puesto/máquina |
| capturado_en | timestamp | fecha/hora de captura |
| origen | object | grupo/remitente WhatsApp, id de mensaje |
| imagen_ref | string | objeto/URL de la imagen original (inmutable) |

## Extracción (IA)
| campo | tipo | descripción |
|---|---|---|
| contadores | number[] | valores numéricos leídos |
| textos | string[] | OCR / textos |
| etiquetas | string[] | etiquetas/contraetiquetas detectadas |
| defectos | string[] | impresión, centrado, inclinación, deformación, … |

## Clasificación y fallback
| campo | tipo | descripción |
|---|---|---|
| resultado | enum | OK / No OK (sin forzar si revisión manual) |
| confianza | number 0..1 | score del modelo |
| revision_manual | bool | true si confianza < umbral del ADR |

## Auditoría
| campo | tipo | descripción |
|---|---|---|
| modelo | string | proveedor/modelo de visión |
| prompt_version | string | versión del prompt |
| latencia_ms | number | latencia de inferencia |
| revisado_por | string | operador que confirmó/corrigió (si aplica) |
| revisado_en | timestamp | cuándo |

## Idempotencia
- Clave natural: `proceso+linea+equipo+capturado_en` **o** hash de imagen.
- Invariante en DB (constraint/índice único). La misma evidencia no se persiste dos veces.
