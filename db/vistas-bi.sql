-- Vistas BI — Calidad de Lata (indicadores/reportes/comparativos de la minuta)
-- Correr: docker exec -i <contenedor-postgres> psql -U calidad -d calidad -f - < db/vistas-bi.sql

-- Evidencia + resultado en una sola fila (base de la planilla)
CREATE OR REPLACE VIEW v_evidencias_completas AS
SELECT e.evidence_id, e.proceso, e.linea, e.equipo, e.capturado_en, e.recibido_en,
       e.estado AS estado_ingesta, e.imagen_ref, e.imagen_hash,
       r.tipo_foto, r.estado AS estado_resultado, r.resultado, r.confianza,
       r.revision_manual, r.contadores, r.defectos, r.textos, r.hora_pantalla,
       r.calidad_impresion, r.coherencia, r.motivo, r.tokens,
       r.revisado_por, r.revisado_en, r.comentario
FROM evidencias e
LEFT JOIN resultados r USING (evidence_id);

-- Producción horaria por línea: delta del contador principal entre lecturas consecutivas
CREATE OR REPLACE VIEW v_produccion_horaria AS
SELECT linea, capturado_en, contador,
       contador - LAG(contador) OVER (PARTITION BY linea ORDER BY capturado_en) AS producidas,
       ROUND((EXTRACT(EPOCH FROM capturado_en
             - LAG(capturado_en) OVER (PARTITION BY linea ORDER BY capturado_en)) / 3600.0)::numeric, 2) AS horas_intervalo
FROM (
  SELECT e.linea, e.capturado_en, (r.contadores->>0)::bigint AS contador
  FROM resultados r JOIN evidencias e USING (evidence_id)
  WHERE r.tipo_foto = 'pantalla_contador'
    AND jsonb_array_length(COALESCE(r.contadores, '[]'::jsonb)) > 0
) t;

-- Comparativo entre líneas/máquinas por día (minuta: "comparativos entre máquinas")
CREATE OR REPLACE VIEW v_comparativo_lineas AS
SELECT linea, date_trunc('day', capturado_en)::date AS dia,
       SUM(GREATEST(producidas, 0)) AS produccion_dia,
       ROUND(AVG(CASE WHEN horas_intervalo > 0 THEN producidas / horas_intervalo END)::numeric) AS ritmo_prom_por_hora,
       COUNT(*) AS lecturas
FROM v_produccion_horaria
WHERE producidas IS NOT NULL
GROUP BY 1, 2;

-- Defectos por día y línea
CREATE OR REPLACE VIEW v_defectos_diarios AS
SELECT date_trunc('day', e.capturado_en)::date AS dia, e.linea,
       d.defecto, COUNT(*) AS cantidad
FROM resultados r
JOIN evidencias e USING (evidence_id)
CROSS JOIN LATERAL jsonb_array_elements_text(COALESCE(r.defectos, '[]'::jsonb)) AS d(defecto)
GROUP BY 1, 2, 3;

-- Cumplimiento de envío: cuántas evidencias por hora y línea (la operativa es horaria)
CREATE OR REPLACE VIEW v_cumplimiento_envio AS
SELECT linea, date_trunc('hour', capturado_en) AS hora, COUNT(*) AS fotos_recibidas
FROM evidencias
GROUP BY 1, 2;

-- Costo IA por día (minuta: "medir consumo de tokens")
CREATE OR REPLACE VIEW v_costo_ia AS
SELECT date_trunc('day', e.capturado_en)::date AS dia,
       COUNT(*) AS inferencias,
       COALESCE(SUM(r.tokens), 0) AS tokens,
       ROUND((COALESCE(SUM(r.tokens), 0) * 0.000005)::numeric, 4) AS costo_usd_estimado
FROM resultados r JOIN evidencias e USING (evidence_id)
GROUP BY 1;
