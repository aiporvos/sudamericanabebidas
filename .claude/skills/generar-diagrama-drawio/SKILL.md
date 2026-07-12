---
name: generar-diagrama-drawio
description: >-
  Usar al crear diagramas .drawio para un caso (BPMN del proceso, arquitectura de la
  solución o secuencia). Define las convenciones y el uso del MCP de draw.io. Se activa con
  frases como "hacé el diagrama", "diagrama BPMN", "diagrama de arquitectura", "diagrama de
  secuencia".
allowed-tools: Read, Write, Glob
---

# Generar diagramas con el MCP de draw.io

Guardá siempre en `docs/diagramas/` con nombre `<slug>-<tipo>.drawio` y enlazalos desde la HU.

## Antes de construir el XML
- Usá la tool **`search_shapes`** del MCP de draw.io para obtener los **estilos reales** de
  las formas (BPMN, UML, cloud) por keyword. No inventes estilos.

## Tipos y convenciones
- **`<slug>-bpmn.drawio`** — proceso de negocio en notación **BPMN**: eventos (inicio/fin),
  tareas, gateways (decisiones OK/No OK, fallback), lanes por rol/sistema.
- **`<slug>-arquitectura.drawio`** — componentes de la solución y sus relaciones (ingesta,
  storage de evidencia, visión IA, DB, alertas). Alto nivel; dejá marcados los componentes
  que infra/dev refinan.
- **`<slug>-secuencia.drawio`** — diagrama de secuencia del caso principal (actor → sistema
  → IA → DB → alerta), con el camino de fallback.

## Reglas
- Un diagrama por archivo; nombres consistentes con el `slug` del caso.
- Formatos aceptados por el MCP: XML nativo, CSV o Mermaid.
- Verificá que el archivo abra correctamente en draw.io antes de darlo por hecho.
