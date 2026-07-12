-- Migración v3 — Calidad de Lata (dedup cross-grupo, líneas config-driven, parámetros)
-- Correr: docker exec -i <contenedor-postgres> psql -U calidad -d calidad -f - < db/migracion-v3.sql

-- 1) Hash de imagen para detectar la MISMA foto enviada a distintos grupos (minuta: "eliminar información duplicada")
ALTER TABLE evidencias ADD COLUMN IF NOT EXISTS imagen_hash text;
CREATE INDEX IF NOT EXISTS idx_evidencias_hash ON evidencias (imagen_hash, capturado_en);

-- 2) Mapeo grupo → línea/equipo/proceso (el cliente solo agrega filas; sin tocar flujos)
CREATE TABLE IF NOT EXISTS lineas_grupos (
  chat_id  text PRIMARY KEY,   -- ID del grupo de Telegram (negativo)
  linea    text NOT NULL,
  equipo   text NOT NULL DEFAULT '',
  proceso  text NOT NULL DEFAULT 'calidad-lata'
);
INSERT INTO lineas_grupos (chat_id, linea, equipo, proceso)
VALUES ('-1003908341093', 'linea-prueba', '', 'calidad-lata')
ON CONFLICT (chat_id) DO NOTHING;

-- 3) Parámetros operativos ajustables sin re-deploy (WF2 los lee en cada ejecución)
CREATE TABLE IF NOT EXISTS config (
  clave text PRIMARY KEY,
  valor text NOT NULL
);
INSERT INTO config (clave, valor) VALUES
  ('umbral_confianza', '0.85'),
  ('ventana_comparacion_min', '90'),
  ('dedup_ventana_horas', '24')
ON CONFLICT (clave) DO NOTHING;
