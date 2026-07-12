# CU-02 — Interpretar evidencia con IA

> Actor principal: **Sistema** (WF2 + OpenAI gpt-4o) · Disparador: tarea en la cola
> Implementación: **WF2** (`yCCNYSU11G5hgWPV`), nodos "Preparar visión" → "Visión IA" → "Parsear resultado"
> Criterios HU: `3, 4, 5, 6, 12, 13, 14, 17`

## Precondiciones
- Evidencia registrada y encolada (CU-01). API key de OpenAI vigente.

## Flujo principal
1. El sistema toma la tarea de la cola y descarga la imagen original de MinIO.
2. La IA de visión **clasifica el tipo de foto** (criterio 12):
   `tapa` | `fondo_impresion` | `pantalla_contador` | `frente` | `otro`.
3. Extrae datos **según el tipo**:
   - `pantalla_contador` → **contadores** (producción, prod/hora, lote) y **hora visible
     en la pantalla** (criterio 13 — permite saber desde cuándo empezó un problema).
   - `fondo_impresion` → **textos impresos** (lote `L:`, hora, vencimiento `V:`) y
     **calidad de impresión** buena/mala (criterio 14 — caso "láser mal calibrado").
   - `tapa` / `frente` → **defectos visuales** (impresión, centrado, inclinación,
     deformación, etiqueta, contraetiqueta).
4. Clasifica **OK / No OK** con un score de **confianza** (0–1).
5. Registra los **tokens consumidos** (criterio 17 — medición de costo, minuta).
6. Continúa a la validación de coherencia (CU-03) y persistencia.

## Flujos alternativos
- **A1 — Confianza < 0.85 (umbral)**: no se fuerza OK/No OK; la evidencia queda en
  `revision_manual` y se dispara CU-04 (criterio 6 — fallback de la minuta:
  "registrar eventos cuando falle la lectura").
- **A2 — Respuesta ilegible del modelo**: se trata como lectura fallida → A1.

## Postcondición
La evidencia tiene interpretación estructurada (tipo, datos, confianza, tokens) lista
para validar y guardar.
