# CU-06 — Consultar histórico ante reclamo

> Actor principal: **Analista de calidad** · Implementación actual: **Dashboard web**
> (https://dashboard.cluna.ar — WF6 `cfcBsJ1PcnseFZfu` + SPA `apps/dashboard/`)
> · Criterios HU: `1, 9, 16, 22, 23`

## Contexto (minuta)
"Cuando aparece un reclamo: deben revisar cientos de fotografías, buscar manualmente la
evidencia, determinar desde cuándo existe el problema."

## Precondiciones
- Evidencias procesadas y persistidas (CU-01/02/03) con textos, tipo y timestamps.
- WF6 "API Dashboard" activo (expone los datos y las imágenes con CORS restringido al
  dominio del dashboard).

## Flujo principal (sin SQL — criterio 22)
1. Llega un reclamo (ej.: lote con impresión defectuosa).
2. El analista abre **https://dashboard.cluna.ar** y filtra por **fecha, línea, tipo de
   foto, resultado o estado**, o usa la **búsqueda libre** sobre motivo/textos/ID
   (los textos leídos están indexados → se busca `L:117`, un vencimiento, etc. — criterio 16).
3. La tabla muestra el historial: qué se leyó, calidad, coherencia, motivo, quién revisó.
4. Con **clic en la fila** se abre el **detalle**: la **imagen original** desde MinIO
   (criterio 1 — evidencia conservada y auditable), confianza, latencia, tokens y todos
   los campos de la inferencia.
5. Con `hora_pantalla` vs hora de captura determina **desde cuándo** existe el problema.
6. Los KPIs del período filtrado (evidencias, % OK, No OK, revisión manual, confianza,
   tokens/costo y **latencia p95** — criterio 23) responden el "cómo venimos" sin armar
   nada a mano.

## Flujo alternativo (SQL directo, para el equipo técnico)
```sql
SELECT e.linea, e.capturado_en, r.tipo_foto, r.textos, r.calidad_impresion,
       r.coherencia, r.motivo, r.resultado, e.imagen_ref
FROM resultados r JOIN evidencias e USING (evidence_id)
WHERE r.textos::text ILIKE '%L:117%'
ORDER BY e.capturado_en;
```

## Implementación
- **WF6 "API Dashboard"** (dos endpoints, JSON + imagen binaria):
  - `GET /webhook/dashboard-calidad` → evidencias de los últimos 90 días con
    `latencia_segundos` (= `evaluado_en − capturado_en`).
  - `GET /webhook/dashboard-calidad-imagen?id=<evidence_id>` → foto original desde MinIO
    (404 si no existe).
- **SPA** React+TS (`apps/dashboard/`), deploy en Dokploy desde el repo
  `aiporvos/sudamericanabebidas-dashboard` (nginx, HTTPS vía Cloudflare).
- Diagrama: `../diagramas/calidad-lata-wf6-api-dashboard.drawio`.

## Postcondición
La evidencia de un reclamo se localiza en minutos desde el navegador, con su historia
completa, la imagen original auditable y las métricas del período — sin acceso a Postgres.
