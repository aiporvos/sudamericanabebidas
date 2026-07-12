---
name: contrato-datos-vision
description: >-
  Usar al definir o revisar el contrato de datos que la IA de visión produce y que backend, DB y
  front consumen: campos, tipos, OK/No OK, confianza, fallback e idempotencia. Fuente de verdad
  compartida entre vision-builder, backend-builder y data-builder. Se activa con "contrato de
  datos", "qué JSON devuelve la IA", "cómo dedup", "shape de la evidencia".
allowed-tools: Read, Write, Glob
---

# Contrato de datos: evidencia → estructura

> Único punto de verdad del **shape** que la visión produce y todos consumen. Si cambia acá, se
> actualiza en vision, backend y data a la vez. Base editable en `docs/plantillas/contrato-datos.md`.

## Debe definir
- **Identidad de la evidencia:** id, proceso (calidad-lata, pet, …), línea, equipo/puesto,
  timestamp de captura, remitente/grupo origen, referencia al objeto de la imagen original.
- **Extracción:** contadores (numérico), textos/OCR, etiquetas, lista de defectos detectados.
- **Clasificación:** `resultado` OK/No OK; `confianza` (0..1); `revision_manual` (bool).
- **Fallback:** bajo el **umbral** del ADR → `revision_manual=true` y `resultado` sin forzar.
- **Auditoría:** modelo/proveedor, versión de prompt, latencia y (tras revisión) quién
  confirmó/corrigió y cuándo.

## Idempotencia / dedup (invariante)
- **Clave natural** (p. ej. `proceso+linea+equipo+timestamp`) **o hash de imagen**; la misma
  evidencia no se procesa ni persiste dos veces.
- El invariante vive en la **DB** (constraint/índice único), no solo en la app o la cola.

## Reglas
- Salida **estructurada y validada** (esquema explícito); nunca texto libre entre servicios.
- Tipos y unidades explícitos; nulos permitidos solo donde el negocio lo admite.
- Compatible multiproceso: agregar un proceso nuevo = nueva fila de config, no cambiar el shape.
