# CU-03 — Validar coherencia impresión ↔ pantalla

> Actor principal: **Sistema** · Disparador: evidencia `fondo_impresion` interpretada (CU-02)
> Implementación: **WF2**, nodos "Buscar contador reciente" → "Evaluar coherencia"
> Criterios HU: `15` (y sustenta `10`)

## Contexto (minuta)
"Un láser mal calibrado puede imprimir el dato correcto, pero con mala calidad" — y al
revés: la impresión puede verse bien pero llevar **datos que no corresponden** a lo que
la máquina debía imprimir. Por eso la foto del fondo se contrasta contra la evidencia de
la **pantalla/tablero de la misma línea**.

## Precondiciones
- Existe una evidencia `pantalla_contador` de la **misma línea** dentro de la ventana
  de **±90 minutos** (las fotos son horarias).

## Flujo principal
1. El sistema busca la última `pantalla_contador` de la línea en la ventana.
2. Ejecuta **3 chequeos** entre lo impreso en la lata y lo mostrado en pantalla:
   - **① Lote**: `L:xxx` impreso vs `LOTE / LOTE EN IMPRESION` de pantalla.
   - **② Vencimiento**: `V:dd/mm/aa` impreso vs `VTO / VENC EN IMPRESION` de pantalla.
   - **③ Hora**: hora impresa vs hora de pantalla (tolerancia 90 min).
3. Si **todos** los chequeos disponibles pasan → `coherencia = true`.
4. Guarda el resultado con `coherencia` y `motivo` (CU-02 → persistencia).

## Flujos alternativos
- **A1 — Falla cualquier chequeo**: `coherencia = false`, resultado **No OK**, `motivo`
  detallado (ej.: "lote impreso 119 distinto del lote en pantalla 10010-94") → CU-05.
- **A2 — Sin contador en la ventana**: `coherencia = null` (no comparable; no alerta por eso).
- **A3 — La pantalla no muestra lote/vto** (tableros simples): se comparan solo los
  campos disponibles; no se inventan fallas.
- **A4 — Calidad de impresión "mala"** (de CU-02): requiere atención aunque los datos
  coincidan → CU-05.

## Postcondición
Cada lata queda validada contra el "contrato de impresión" de su línea, con motivo
auditable cuando no corresponde.
