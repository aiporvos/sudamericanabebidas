---
name: validar-flujo-n8n
description: >-
  Usar al validar, revisar o desplegar un flujo n8n (workflows/*.json) antes de darlo por
  terminado. Corre el checklist de puesta en marcha y la validación de schema con n8n-mcp,
  y verifica el mapeo criterio de aceptación → nodo. Se activa con frases como "validá el
  flujo", "revisá el workflow", "está listo para desplegar".
allowed-tools: Read, Glob, Grep
---

# Validar un flujo n8n antes de cerrarlo

> Esta skill es el **gate de proceso** (checklist + trazabilidad). Para la mecánica de n8n
> (nodos, expresiones, code, binario/visión, errores) usá las **skills oficiales de n8n**
> `n8n-io/skills` (`n8n-node-configuration`, `n8n-expressions`, `n8n-error-handling`,
> `n8n-binary-and-data`, etc.). No dupliques ese conocimiento acá.

Aplicá este procedimiento sobre `workflows/<slug>.json` antes de considerarlo terminado.

1. **Validación de schema:** usá la tool de validación de `n8n-mcp` sobre el JSON. Si hay
   errores, corregilos y revalidá hasta que quede limpio. Nunca inventes nodos ni parámetros.
2. **Checklist funcional:** recorré `docs/plantillas/checklist-n8n.md` para el caso y marcá
   cada punto (recepción → visión IA → OK/No OK → fallback → persistencia sin duplicar →
   alerta con evidencia y timestamp).
3. **Trazabilidad:** confirmá que **cada criterio de aceptación** numerado de la HU
   (`docs/requisitos/HU-<slug>.md`) está mapeado a uno o más nodos. Si algún criterio no
   puede cubrirse en n8n, marcá el gap y devolvelo a `dev-tech-lead`.
4. **Credenciales:** recordá dejar la nota de reconexión (n8n no importa credenciales).
5. **Test (si hay instancia conectada):** ejecutá con datos de muestra vía n8n-mcp y
   auto-corregí lo que falle.

**Hecho** = schema válido, checklist completo, todos los criterios trazados (o gaps marcados).
