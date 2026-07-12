# CU-07 — Generar reporte e planilla automática

> Actor principal: **Sistema** (WF5) · Disparador: horario programado (07:00, configurable)
> Implementación: **WF5 Reporte y planilla** (`5XQdZA48FGN4YHdN`) + vistas `db/vistas-bi.sql`
> Criterios HU: `18, 20` · Minuta: "Automatice la carga de planillas", "indicadores y reportes
> sin necesidad de reprocesar la información manualmente"

## Precondiciones
- Vistas BI creadas (`db/vistas-bi.sql`). WF5 activo.

## Flujo principal
1. A la hora programada, el sistema calcula los **KPIs de las últimas 24 h**: evidencias,
   OK/No OK, revisiones manuales, duplicadas, incoherencias, tokens y costo estimado.
2. Extrae el **detalle completo** desde `v_evidencias_completas` (una fila por evidencia,
   con lectura, veredicto, motivo y referencia a la imagen).
3. Genera la **planilla CSV** (`planilla-calidad-AAAA-MM-DD.csv`) — reemplaza la planilla
   que hoy se completa a mano.
4. Envía al grupo de Telegram: la **planilla adjunta** + el **resumen de KPIs** formateado.

## Indicadores disponibles además del reporte (consulta directa)
- `v_produccion_horaria` / `v_comparativo_lineas` — producción y comparativos entre máquinas
  a partir de los contadores leídos (criterio 20).
- `v_defectos_diarios`, `v_cumplimiento_envio`, `v_costo_ia`.

## Flujos alternativos
- **A1 — Sin evidencias en el período**: la planilla sale vacía y el resumen muestra ceros
  (señal de que la línea no reportó — también es información).

## Postcondición
Nadie transcribe ni consolida planillas: el dato nace estructurado y el reporte se entrega solo.
