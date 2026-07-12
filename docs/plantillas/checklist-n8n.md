# Checklist de puesta en marcha — flujo `<slug>`

## Validación del flujo
- [ ] `workflows/<slug>.json` validado por n8n-mcp sin errores de schema.
- [ ] Todos los criterios de aceptación de la HU mapeados a nodos (o gaps marcados).
- [ ] Nodos usan nombres/propiedades reales del schema (nada inventado).

## Cobertura funcional del caso
- [ ] Recepción de evidencia (imagen) + registro de fecha/hora.
- [ ] Conservación de la imagen original (storage de evidencia).
- [ ] Visión IA: extracción de valores de contadores.
- [ ] Visión IA: detección de defectos visuales definidos.
- [ ] Clasificación OK / No OK.
- [ ] Fallback a revisión manual bajo umbral de confianza (evento registrado).
- [ ] Persistencia en DB estructurada, sin duplicación.
- [ ] Alerta ante desvío, con evidencia y timestamp de inicio.

## Importación en n8n
- [ ] Flujo importado en la instancia.
- [ ] Credenciales reconectadas nodo por nodo (n8n no importa credenciales).
- [ ] Prueba con datos de muestra ejecutada correctamente.

## Trazabilidad
- [ ] Cada criterio de aceptación (1..N) trazado a nodo/decisión.
- [ ] ADRs referenciados desde el flujo o su README.
