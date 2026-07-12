---
name: revisar-hu
description: >-
  Usar al escribir o revisar una Historia de Usuario para asegurar que los criterios de
  aceptación sean testeables y trazables antes de pasar a infra/dev/n8n. Se activa con
  frases como "revisá la HU", "los criterios de aceptación están bien", "documentá el
  requisito".
allowed-tools: Read, Write, Glob
---

# Revisar una Historia de Usuario

Aplicá al escribir/validar `docs/requisitos/HU-<slug>.md` (base: `docs/plantillas/HU.md`).

## Checklist de calidad
- [ ] Formato **Como / quiero / para** completo (rol, capacidad, beneficio de negocio).
- [ ] **Supuestos explícitos** al inicio; los críticos marcados con ⚠️ para confirmación.
- [ ] Criterios de aceptación **numerados** y **testeables**: cada uno se verifica
      objetivamente (evitá "el sistema debe ser rápido/amigable"; poné condición medible).
- [ ] Cada criterio se puede **mapear a un nodo del flujo o a una decisión (ADR)**.
- [ ] Alcance del MVP acotado; procesos futuros listados aparte (no MVP).
- [ ] Sin decisiones tecnológicas concretas (eso es de infra/dev): la HU dice **QUÉ**, no CÓMO.
- [ ] Diagramas enlazados (BPMN + arquitectura como mínimo).

## Señales de criterio mal escrito
- No se puede escribir una prueba que lo apruebe/repruebe → reescribir con condición medible.
- Mezcla varios requisitos en uno → separar en criterios numerados independientes.
- Presupone una tecnología → mover esa decisión al ADR de infra/dev.
