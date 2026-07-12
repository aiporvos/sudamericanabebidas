# ADR-003: Modelo de visión IA, umbral de confianza y fallback

> estado: `aceptada` · autor: `dev` · fecha: `2026-07-07`
> caso: `calidad-lata`

## Contexto
El núcleo del MVP es interpretar la imagen: extraer contadores/textos, detectar defectos y clasificar
OK/No OK con un score de confianza que permita derivar a revisión manual cuando la IA no es confiable.
Impacta los criterios 3, 4, 5, 6 y 7.

## Opciones evaluadas
### Opción A — Modelo multimodal vía API (OpenAI gpt-4o) ✅ elegida
- Pros: entiende imagen + instrucción en un solo llamado (OCR + defectos); devuelve **JSON estructurado**
  (`response_format: json_object`); sin entrenar modelo propio; multiproveedor intercambiable (OpenAI/Claude/Gemini).
- Contras: costo por llamado; depende de un tercero; latencia de red.
- Verificado con context7: `sí — POST /v1/chat/completions, imagen como image_url data URL base64, respuesta en choices[0].message.content`.

### Opción B — OCR clásico + reglas (p. ej. Google Vision OCR)
- Pros: barato para leer números/textos.
- Contras: no clasifica defectos visuales complejos; requiere mucha lógica de reglas propia.

## Decisión
**Opción A con OpenAI, modelo por defecto `gpt-4o-mini`** como interpretación principal (visión + OCR).
La minuta del 25/06 pide explícitamente "priorizar modelos de bajo costo para el MVP" y "medir consumo de
tokens": por eso el default es `gpt-4o-mini` y cada inferencia **registra `tokens`** (de `response.usage`)
en `resultados`. Si la precisión OCR no alcanza, subir a `gpt-4o` es cambiar 1 string en "Preparar visión".

La salida es **JSON estricta** ampliada según la minuta: `tipo_foto` (tapa | fondo_impresion |
pantalla_contador | frente | otro), `contadores`, `textos`, `etiquetas`, `hora_pantalla` (hora visible en la
pantalla fotografiada), `calidad_impresion` (buena/mala — caso "láser mal calibrado"), `defectos`,
`resultado`, `confianza`. **Umbral de confianza inicial = 0.85**: por debajo, `revision_manual=true` y
**no se fuerza** OK/No OK (criterio 6). La revisión manual (criterio 7) registra autor y timestamp.
Además, una etapa posterior **compara** `fondo_impresion` contra la última `pantalla_contador` de la misma
línea (±90 min) para validar coherencia (criterio 15). El proveedor es intercambiable (nodo HTTP + body en
"Preparar visión"). OCR clásico (B) queda como complemento futuro si hace falta abaratar la lectura numérica.

## Consecuencias
- Contrato de salida definido en `docs/plantillas/contrato-datos.md` (skill `contrato-datos-vision`).
- El umbral es **configurable**; ajustarlo con datos reales de precisión.
- Falta la **bandeja de revisión manual** (UI) para cerrar el criterio 7 end-to-end (pendiente).
- Criterios de aceptación afectados: `3, 4, 5, 6, 7, 12, 13, 14, 15, 16, 17`.
