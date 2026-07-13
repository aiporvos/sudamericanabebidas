# Casos de prueba — Calidad de Lata (demo con cliente)

> Se ejecutan **enviando las fotos de `docs/sudamericana_photos/` al grupo Telegram** de la
> línea, en el orden indicado. El resultado se ve en las **alertas de Telegram** y en la
> base (`resultados`). Trazan a los casos de uso (`docs/casos-de-uso/`) y criterios de la HU.

## Kit de imágenes (qué contiene cada una)

| Imagen | Contenido | Rol en la prueba |
|---|---|---|
| `sudamericana_tablero1.png` | LLENADORA · LOTE **118** · HORA **18:40** · FECHA 11/07/26 | referencia p/ incoherencia de hora |
| `sudamericana_tablero2.png` | ETIQUETADORA · LOTE **119** · HORA **14:02** · FECHA 24/12/26 | referencia p/ caso coherente |
| `sudamericana_tablero3.png` | CODIFICADORA · LOTE **024** · HORA **14:49:28** · FECHA 23/07/26 | referencia p/ cambio de lote |
| `sudamericana_tablero4.png` | SISTEMA DE CODIFICACIÓN · **LOTE EN IMPRESIÓN 10010-94** · **VTO EN IMPRESIÓN 29/03/27** · HORA SISTEMA 14:22:33 | referencia p/ lote+vto incorrectos |
| `sudamericana_latas1.png` | Fondo impreso **L:119 14:02 · V:24/12/26** — nítida | lata "correcta" |
| `sudamericana_latas2.png` | Fondo impreso **L:118 10:15 · V:224/11/26** — nítida (dígito de más en V) | lata con hora vieja |
| `sudamericana_latas3.png` | Fondo impreso **L:117 13:55 · V:24/10/26** — **borrosa** | lata mal impresa |
| `sudamericana_latas_originales1..3.jpeg` | Fotos **reales** de fondo de lata | prueba de OCR real |
| `sudamericana_latas_juntas.png` | Varias latas juntas | clasificación "otro"/frente |

## Precondiciones (checklist previo a la demo)
- [ ] WF1, WF2, WF3, WF4 (y WF5 si se prueba el reporte) **activados** en n8n.
- [ ] Migración v3 y vistas BI corridas (`db/migracion-v3.sql` + `db/vistas-bi.sql`).
- [ ] MinIO, Postgres, RabbitMQ y Redis arriba; API key de OpenAI vigente.
- [ ] Bot en el grupo de prueba; alertas apuntando al grupo (`-1003908341093`).
- [ ] ⚠️ La comparación usa el **último tablero recibido en la misma línea (ventana 90 min)**:
      respetar el orden tablero → lata y hacer la demo sin pausas largas.

---

## CP-01 — Ingesta y registro de evidencia
**CU-01 · criterios 1, 2** · Imagen: `sudamericana_tablero2.png`
1. Enviar la foto al grupo.
2. **Esperado:** ejecución WF1 success; fila en `evidencias` (línea, hora de envío);
   imagen visible en MinIO (`calidad-lata/...`); tarea publicada en la cola. Sin alerta.

## CP-02 — Mensaje que no es evidencia
**CU-01 A1** · Sin imagen (enviar un texto: "hola")
1. Enviar el texto al grupo.
2. **Esperado:** WF1 lo descarta (rama "sin foto"); no se crea evidencia; sin alerta.

## CP-03 — Lectura de tablero (pantalla_contador)
**CU-02 · criterios 3, 12, 13, 17** · Imagen: `sudamericana_tablero2.png` (ya enviada en CP-01)
1. Ver la ejecución de WF2 correspondiente.
2. **Esperado:** `tipo_foto = pantalla_contador`; `contadores = [45230, 235, 119]`;
   `hora_pantalla = "14:02..."`; confianza ≥ 0.85; `tokens` registrados. **Sin alerta** (OK).

## CP-04 — Lata correcta y coherente (caso feliz ✅)
**CU-03 · criterios 5, 14, 15** · Imágenes: `tablero2` → `latas1`
1. Enviar `sudamericana_latas1.png` (después del tablero2).
2. **Esperado:** `tipo_foto = fondo_impresion`; textos `L:119 14:02 | V:24/12/26`;
   calidad **buena**; coherencia **true** (lote 119 = 119; hora 14:02 ≈ 14:02).
   **Sin alerta** — el silencio es el resultado correcto.
   *(Validado en la prueba del 11/07: coherencia true, confianza 95%.)*

## CP-05 — Incoherencia de HORA 🚨
**CU-03 A1, CU-05 · criterios 10, 15** · Imágenes: `tablero1` → `latas2`
1. Enviar `sudamericana_tablero1.png` (LOTE 118, HORA 18:40).
2. Enviar `sudamericana_latas2.png` (L:118 **10:15**).
3. **Esperado:** lote pasa (118 = 118) pero la hora falla (10:15 vs 18:40 ≈ 8 hs) →
   **alerta "Desvío No OK"** con motivo *"hora impresa (10:15) lejos de la pantalla (18:40)..."*.
   Bonus: la IA puede marcar defecto de impresión por el `V:224/11/26` (dígito de más).

## CP-06 — LOTE y VENCIMIENTO incorrectos 🚨 (el caso que detectó el cliente)
**CU-03 A1 · criterio 15** · Imágenes: `tablero4` → `latas1`
1. Enviar `sudamericana_tablero4.png` (LOTE EN IMPRESIÓN 10010-94 · VTO 29/03/27).
2. Enviar `sudamericana_latas1.png` (L:119 · V:24/12/26).
3. **Esperado:** hora pasa (14:02 vs 14:22 = 20 min) pero **lote falla** (119 ≠ 10010-94)
   y **vto falla** (24/12/26 ≠ 29/03/27) → **alerta No OK con ambos motivos**.
   Demuestra que la máquina "dice" qué debía imprimirse y la lata no lo cumple.

## CP-07 — Cambio de lote no reflejado 🚨
**CU-03 A1 · criterio 15** · Imágenes: `tablero3` → `latas1`
1. Enviar `sudamericana_tablero3.png` (CODIFICADORA, LOTE **024**, HORA 14:49).
2. Enviar `sudamericana_latas1.png` (L:**119**).
3. **Esperado:** hora pasa (14:02 vs 14:49 = 47 min) pero **lote falla** (119 ≠ 024) →
   alerta: la línea cambió de lote y la lata sigue impresa con el anterior.

## CP-08 — Mala calidad de impresión ("láser mal calibrado") 🚨
**CU-02 · criterio 14** · Imagen: `sudamericana_latas3.png` (borrosa)
1. Enviar la foto.
2. **Esperado:** `calidad_impresion = mala` → **alerta** aunque el dato sea legible.
   (Puede sumar motivo de lote/hora según el último tablero enviado — es correcto.)

## CP-09 — OCR sobre fotos reales + fallback
**CU-02 A1, CU-04 · criterios 3, 6, 7** · Imágenes: `latas_originales1..3.jpeg`
1. Enviar las fotos reales una a una.
2. **Esperado:** textos extraídos correctamente (`L:117 13:55 | V:24/10/26`) y guardados.
   Si alguna da confianza < 85% → alerta **"Revisión manual"**:
3. Abrir el **formulario WF4**, cargar el `evidence_id` de la alerta + resultado + nombre.
4. **Esperado:** `resultados` queda `revisado` con **autor y timestamp** (criterio 7).

## CP-10 — Consulta histórica ante reclamo (dashboard, sin SQL)
**CU-06 · criterios 9, 16, 22** · Sin imagen (usa lo generado por CP-01..09)
1. Abrir **https://dashboard.cluna.ar** y buscar en **Búsqueda libre** un texto leído en la
   demo (ej.: `L:117`) o filtrar por línea/fecha/resultado.
2. **Esperado:** aparecen las evidencias coincidentes con lectura, veredicto, motivo y
   confianza; los KPIs del período se recalculan según el filtro. Los `tokens` permiten
   estimar el costo por foto.
3. (Alternativa técnica) La misma consulta por SQL:
```sql
SELECT e.linea, e.capturado_en, r.tipo_foto, r.textos, r.calidad_impresion,
       r.coherencia, r.motivo, r.resultado, r.tokens, e.imagen_ref
FROM resultados r JOIN evidencias e USING (evidence_id)
ORDER BY e.capturado_en DESC;
```

## CP-11 — Reporte y planilla automática
**CU-07 · criterios 18, 20** · Sin imagen (usa lo generado por los CP anteriores)
1. En n8n, abrir **WF5 "Reporte y planilla"** → **Execute workflow** (o esperar a las 07:00).
2. **Esperado:** llegan al grupo **2 mensajes**: la **planilla CSV** adjunta
   (`planilla-calidad-AAAA-MM-DD.csv` con una fila por evidencia) y el **resumen de KPIs**
   (evidencias, OK/No OK, revisiones, duplicadas, incoherencias, tokens y costo).

## CP-12 — Misma foto enviada dos veces (dedup entre grupos) ♻️
**CU-08 · criterio 19** · Imagen: cualquiera del kit **ya enviada hoy**
1. Reenviar al grupo una foto que ya se procesó (misma imagen, mensaje nuevo).
2. **Esperado:** WF1 la registra con `estado = 'duplicada'` (con `duplicada_de` apuntando a la
   original) y **NO la encola**: sin gasto de IA, sin alerta repetida. Verificar:
```sql
SELECT evidence_id, estado, duplicada_de IS NOT NULL AS es_dup FROM evidencias ORDER BY recibido_en DESC LIMIT 3;
```
> ⚠️ Consecuencia para la demo: las fotos del kit **no se pueden reutilizar** dentro de la
> ventana (24 h default). Para repetir casos: usar otra foto o bajar `config.dedup_ventana_horas`.

## CP-13 — Detalle de evidencia con foto y latencia (dashboard) 🖼️
**CU-06 · criterios 1, 22, 23** · Sin imagen (usa lo generado por CP-01..09)
1. En **https://dashboard.cluna.ar**, hacer **clic en una fila** de la tabla de evidencias.
2. **Esperado:** se abre el detalle con la **foto original** (servida desde MinIO vía
   `GET /webhook/dashboard-calidad-imagen?id=…`), resultado, confianza, estado,
   línea/equipo, tipo de foto, **latencia IA** de esa evidencia, tokens, motivo,
   coherencia y textos leídos.
3. Verificar el KPI **"Latencia p95"** en la cabecera (Telegram → resultado IA; en el
   piloto ronda los **8–10 s**).
4. Con un `evidence_id` inexistente, el endpoint de imagen responde **404** y el modal
   muestra el aviso "No se pudo cargar la imagen" (sin romper la página).

## CP-14 — Chat "Lupa": consulta agregada (modo resumen) 💬
**CU-09 · criterio 24** · Sin imagen (usa lo generado por CP-01..09)
1. En **https://dashboard.cluna.ar**, abrir la burbuja de chat (abajo a la derecha) y
   preguntar: *"¿Cuántas evidencias hubo hoy?"*.
2. **Esperado:** Lupa responde en **texto plano** (sin asteriscos ni markdown) con números
   reales — total, OK, No OK, revisión manual, incoherentes, confianza media y tokens —
   coincidentes con los KPIs del dashboard para ese mismo período.
3. Verificar en n8n → **Executions** de WF7b ("Tool Consultar Evidencias") que hubo una
   ejecución real asociada a la pregunta (confirma que Lupa consultó la base y no inventó
   la cifra).

## CP-15 — Chat "Lupa": detalle + memoria de sesión 💬
**CU-09 · criterio 24** · Sin imagen (usa lo generado por CP-01..09)
1. En la misma conversación de CP-14, preguntar: *"¿Cuál fue el motivo de las
   incoherencias?"* (pregunta de seguimiento, sin repetir "de hoy").
2. **Esperado:** Lupa entiende el contexto de la pregunta anterior (memoria de sesión por
   `session_id`) y responde con el **motivo real** de cada incoherencia (lote/vencimiento/
   hora impresos vs. pantalla), usando el modo `detalle` de la tool.
3. Probar el botón **"Nueva sesión"**: debe limpiar la conversación y volver solo al
   mensaje de bienvenida.
4. Preguntar algo fuera de dominio (ej. "¿qué día es hoy en Japón?") — Lupa debe declinar
   amablemente en vez de responder con conocimiento general.
5. (Opcional, para probar el manejo de error) Desactivar WF7b momentáneamente y repetir
   CP-14: Lupa debe reportar que no pudo consultar los datos, **nunca inventar cifras**.

---

## Planilla de resultados (completar en la demo)

| CP | Descripción corta | Esperado | Resultado | ✔/✘ | Observaciones |
|---|---|---|---|---|---|
| CP-01 | Ingesta y registro | evidencia + MinIO + cola | | | |
| CP-02 | Texto sin foto | descartado | | | |
| CP-03 | Lectura de tablero | contadores + hora pantalla | | | |
| CP-04 | Lata coherente | sin alerta (OK) | | | |
| CP-05 | Hora incoherente | alerta motivo hora | | | |
| CP-06 | Lote+VTO incorrectos | alerta 2 motivos | | | |
| CP-07 | Cambio de lote | alerta motivo lote | | | |
| CP-08 | Impresión borrosa | alerta calidad mala | | | |
| CP-09 | Fotos reales + WF4 | OCR ok / revisión firmada | | | |
| CP-10 | Consulta histórica (dashboard) | búsqueda sin SQL | | | |
| CP-11 | Reporte automático | CSV + resumen KPIs | | | |
| CP-12 | Foto repetida | marcada duplicada, sin reproceso | | | |
| CP-13 | Detalle con foto + latencia | imagen desde MinIO, KPI p95 | | | |
| CP-14 | Chat Lupa — resumen | datos reales, coincide con dashboard | | | |
| CP-15 | Chat Lupa — detalle + memoria | motivo real, contexto de sesión | | | |
