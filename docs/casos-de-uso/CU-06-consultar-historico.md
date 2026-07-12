# CU-06 — Consultar histórico ante reclamo

> Actor principal: **Analista de calidad** · Implementación actual: **SQL sobre Postgres**
> (dashboard/BI: backlog) · Criterios HU: `1, 9, 16`

## Contexto (minuta)
"Cuando aparece un reclamo: deben revisar cientos de fotografías, buscar manualmente la
evidencia, determinar desde cuándo existe el problema."

## Precondiciones
- Evidencias procesadas y persistidas (CU-01/02/03) con textos, tipo y timestamps.

## Flujo principal
1. Llega un reclamo (ej.: lote con impresión defectuosa).
2. El analista consulta `resultados` + `evidencias` filtrando por **fecha, línea,
   proceso, lote** (los textos leídos están guardados → se busca por `L:117`, un
   vencimiento, etc. — criterio 16).
3. Obtiene el historial: qué se leyó, calidad, coherencia, motivo, quién revisó.
4. Con `imagen_ref` recupera la **imagen original** desde MinIO (criterio 1 — evidencia
   conservada e inmutable).
5. Con `hora_pantalla` vs hora de envío determina **desde cuándo** existe el problema.

## Consulta tipo
```sql
SELECT e.linea, e.capturado_en, r.tipo_foto, r.textos, r.calidad_impresion,
       r.coherencia, r.motivo, r.resultado, e.imagen_ref
FROM resultados r JOIN evidencias e USING (evidence_id)
WHERE r.textos::text ILIKE '%L:117%'
ORDER BY e.capturado_en;
```

## Evolución prevista (backlog)
- Dashboard operativo + BI (`frontend-builder` / `data-builder`, camino custom) para que
  el analista consulte sin SQL: filtros por fecha/línea/equipo/proceso e indicadores
  (volumen, cumplimiento, defectos, tendencias — "Objetivo esperado" de la minuta).

## Postcondición
La evidencia de un reclamo se localiza en minutos, con su historia completa y la imagen
original auditable.
