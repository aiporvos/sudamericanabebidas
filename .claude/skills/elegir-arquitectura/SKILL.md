---
name: elegir-arquitectura
description: >-
  Usar al decidir CÓMO se construye una solución: flujo n8n, stack custom de microservicios, o
  híbrido. Fija el gate de decisión y qué builders se activan después. Se activa con frases como
  "n8n o custom", "qué arquitectura conviene", "elegí el camino de build", "cómo lo construimos".
allowed-tools: Read, Glob, Grep
---

# Elegir el camino de build: n8n vs custom vs híbrido

> Esta skill es un **gate de decisión** previo a los builders. La decisión se documenta en un
> **ADR** (`arquitecto-infra`), no acá. n8n y custom **no son rivales**: n8n orquesta rápido; el
> custom escala y controla. El **híbrido** (n8n orquestando + servicios custom para lo pesado)
> suele ser el mejor MVP escalable.

## Criterios para decidir
- **Time-to-MVP y equipo:** sin equipo dev/devops estable → n8n o híbrido.
- **Volumen / latencia:** procesamiento de imágenes muy alto o CPU-bound → worker custom.
- **Control de datos y observabilidad fina** → custom.
- **Lógica muy específica** (ML propio, preproceso complejo) → servicio custom, no Code node.
- **Escalado a procesos futuros** (PET, Trazabilidad, CO₂…) sin cambios estructurales → cualquiera
  de los tres, pero explicitá cómo.

## Qué produce la decisión
Un ADR con la ruta elegida y **qué builders se activan**:
- **n8n** → `n8n-builder` (`workflows/`).
- **custom** → `backend-builder`, `vision-builder`, `data-builder`, `frontend-builder`, `devops-sre`.
- **híbrido** → `n8n-builder` + los builders custom de las cajas que n8n no cubra bien.

Definí el **límite exacto**: qué caja del diagrama la hace n8n y cuál un servicio custom.

## Regla
Toda solución custom o híbrida comparte el **contrato de datos** (skill `contrato-datos-vision`)
para que los builders encajen sin reinterpretar. La decisión de stack concreto sigue viniendo de
`arquitecto-infra` ⇄ `dev-tech-lead`; esta skill solo fija el **camino**.
