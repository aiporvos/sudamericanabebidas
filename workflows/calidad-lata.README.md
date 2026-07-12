# Calidad de Lata — flujo productivo n8n (Telegram + RabbitMQ + Redis + S3 + Postgres + Visión IA)

Solución completa del diagrama "Captura y Gestión de Evidencias de Calidad", implementada como
**3 workflows** en n8n con cola real. Ingesta por **Telegram** (resuelve el bloqueante de
WhatsApp: no hay Groups API oficial de Meta).

## Workflows (creados en la instancia, **inactivos**)

| # | Nombre | ID | Rol |
|---|---|---|---|
| 1 | Calidad de Lata — 1) Ingesta (Telegram → Cola) | `grKAt4YQr6SutRI3` | Recibe la foto, valida, guarda evidencia, publica tarea |
| 2 | Calidad de Lata — 2) Procesamiento IA (Cola → Resultado) | `yCCNYSU11G5hgWPV` | Consume la cola, visión IA, clasifica, alerta |
| 3 | Calidad de Lata — 3) Manejo de Errores | `I59vNrbU4KKGkHXF` | Error Workflow de 1, 2 y 4; avisa a operaciones |
| 4 | Calidad de Lata — 4) Bandeja de revisión manual | `Zcir83zzovfCLQrF` | Formulario web con validación de evidence_id |
| 5 | Calidad de Lata — 5) Reporte y planilla | `5XQdZA48FGN4YHdN` | Diario 07:00: planilla CSV + resumen KPIs al grupo |

JSON exportado: `calidad-lata-1-ingesta.json`, `calidad-lata-2-procesamiento.json`,
`calidad-lata-3-errores.json`, `calidad-lata-4-revision-manual.json`.

Etiqueta común sugerida: `sudamericana-bebidas` (agregar en la UI; el MCP no la pudo asignar).

## Arquitectura (mapeo al diagrama)

```
Telegram (bot en los grupos)
   │  WF1 Ingesta
   ▼
Normalizar (grupo→línea/proceso, evidence_id) → ¿Es foto? → S3 (imagen original)
   → Postgres INSERT evidencias (PK evidence_id = dedup) → RabbitMQ publish → Redis incr (métrica)
                                         │ (duplicado = salida de error) → ignorar
   ─────────────────────────────────────────────────────────────────────────────
RabbitMQ  cola "calidad.lata.procesar"
   │  WF2 Procesamiento
   ▼
Descargar de S3 → Preparar visión (base64) → Visión IA (OpenAI gpt-4o-mini, clasifica tipo de foto
   + OCR + calidad de impresión, JSON estricto) → Parsear (umbral 0.85, tokens)
   → Buscar contador reciente (misma línea, ±90 min) → Evaluar coherencia (fondo ↔ pantalla)
   → Postgres INSERT/UPDATE resultados (todo el contrato + coherencia + tokens)
   → ¿Requiere atención? → Telegram alerta (desvío No OK / revisión manual)
```

## Requisitos de infraestructura (proveés vos)

- **RabbitMQ** con la cola `calidad.lata.procesar` (durable).
- **Redis** (métricas / idempotencia).
- **S3-compatible** (Cloudflare R2 / MinIO / AWS S3): un bucket para las evidencias.
- **Postgres** con las tablas de abajo.
- **Bot de Telegram** agregado a los grupos; los operarios mandan las fotos ahí.
- **API key de OpenAI** (visión / OCR).

### SQL — tablas Postgres

```sql
CREATE TABLE IF NOT EXISTS evidencias (
  evidence_id  text PRIMARY KEY,            -- dedup: la misma evidencia no entra dos veces
  proceso      text NOT NULL,
  linea        text,
  equipo       text,
  capturado_en timestamptz,
  imagen_ref   text,                        -- key del objeto en S3
  origen       jsonb,                        -- grupo, remitente, message_id
  estado       text DEFAULT 'recibido',
  recibido_en  timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS resultados (
  evidence_id     text PRIMARY KEY REFERENCES evidencias(evidence_id),
  estado          text,                      -- procesado | revision_manual | revisado | rechazado
  resultado       text,                      -- OK | No OK | null (si revisión)
  confianza       numeric,
  revision_manual boolean,
  contadores      jsonb,
  defectos        jsonb,
  evaluado_en     timestamptz,
  revisado_por    text,                      -- WF4: operador que revisó
  revisado_en     timestamptz,               -- WF4: cuándo
  comentario      text                        -- WF4: nota de la revisión
);
```

> El **dedup** vive en la DB (`evidence_id` PRIMARY KEY): en WF1 el duplicado hace fallar el
> INSERT y sale por la **salida de error** del nodo Postgres hacia "Duplicado (ignorar)".

### Migración v2 (minuta 25/06 — tipos de foto, hora de pantalla, comparación, tokens)

```sql
ALTER TABLE resultados
  ADD COLUMN IF NOT EXISTS tipo_foto text,
  ADD COLUMN IF NOT EXISTS textos jsonb,
  ADD COLUMN IF NOT EXISTS etiquetas jsonb,
  ADD COLUMN IF NOT EXISTS hora_pantalla text,
  ADD COLUMN IF NOT EXISTS calidad_impresion text,
  ADD COLUMN IF NOT EXISTS coherencia boolean,
  ADD COLUMN IF NOT EXISTS motivo text,
  ADD COLUMN IF NOT EXISTS tokens integer;
```

> ⚠️ Correr ANTES de procesar la próxima foto: el INSERT de "Guardar resultado" ya usa estas columnas.

### Migración v3 + vistas BI (dedup entre grupos, líneas config-driven, parámetros, reportes)

```bash
docker exec -i <contenedor-postgres> psql -U calidad -d calidad < db/migracion-v3.sql
docker exec -i <contenedor-postgres> psql -U calidad -d calidad < db/vistas-bi.sql
```

Crea: `evidencias.imagen_hash` (dedup entre grupos), tabla **`lineas_grupos`** (mapeo
chat_id→línea/equipo/proceso — el cliente agrega filas, sin tocar flujos), tabla **`config`**
(`umbral_confianza`, `ventana_comparacion_min`, `dedup_ventana_horas` — ajustables en caliente)
y las 6 vistas BI (`v_evidencias_completas`, `v_produccion_horaria`, `v_comparativo_lineas`,
`v_defectos_diarios`, `v_cumplimiento_envio`, `v_costo_ia`).

> ⚠️ Correr ANTES de la próxima foto: WF1 v3 consulta `lineas_grupos`/`config` y guarda `imagen_hash`.
> ⚠️ Dedup en demos: reenviar la misma imagen dentro de la ventana la marca `duplicada` (no se procesa).

### Resiliencia de la cola (RabbitMQ — hacer en la UI, 2 min)
1. **Queues** → Add queue → `calidad.lata.procesar.dlq` (Durable).
2. **Admin → Policies** → Add policy: name `calidad-dlq`, pattern `^calidad\.lata\.procesar$`,
   definition: `dead-letter-exchange` = *(vacío)* y `dead-letter-routing-key` = `calidad.lata.procesar.dlq`.
   → los mensajes rechazados/fallidos van a la DLQ en vez de perderse (revisarla ante incidentes).

## Credenciales a reconectar (n8n NO importa credenciales)

Abrí cada nodo y seleccioná la credencial correcta:

| Credencial (tipo) | Nodos |
|---|---|
| Telegram API (bot token) | Recibir foto, Alertar (desvío/revisión), Avisar a operaciones |
| S3 | Guardar imagen original, Descargar imagen |
| Postgres | Registrar evidencia, Guardar resultado, Aplicar revisión (WF4) |
| RabbitMQ | Publicar a cola, Tomar tarea (RabbitMQ) |
| Redis | Contador recibidas (métrica) |
| Header Auth (`Authorization: Bearer <API key OpenAI>`) | Visión IA (OpenAI) |

## Placeholders a completar

- `REEMPLAZAR_BUCKET` → nombre real del bucket (WF1 y WF2).
- `REEMPLAZAR_SUPERVISION_CHAT_ID` → chat de supervisión (alertas).
- `REEMPLAZAR_OPS_CHAT_ID` → chat de operaciones (errores).
- **Mapa grupo→línea**: en el nodo "Normalizar evidencia" (WF1), completar el objeto `mapa`
  con los `chat_id` de los 183 grupos → `{ linea, equipo, proceso }`.
- **Umbral de confianza** (0.85) y **modelo**: nodos "Parsear resultado" / "Preparar visión" (WF2).

## Puesta en marcha (orden)

1. Provisioná RabbitMQ (cola durable), Redis, S3 (bucket) y Postgres (correr el SQL).
2. Reconectá credenciales en los 3 workflows.
3. Completá los placeholders y el mapa grupo→línea.
4. **Activá** en este orden: WF3 (errores) → WF2 (procesamiento) → WF1 (ingesta) → WF4 (revisión).
5. Probá: mandá una foto a un grupo de prueba → debería verse la evidencia en `evidencias`,
   el resultado en `resultados`, y una alerta si es No OK / baja confianza.

## Mapeo criterio de aceptación → nodo

| Criterio (petición Calidad de Lata) | Nodo(s) |
|---|---|
| Recepción con fecha/hora + conservar imagen original | Recibir foto → Normalizar (`capturado_en`) → Guardar imagen original (S3) |
| IA extrae contadores y detecta defectos | Visión IA (OpenAI) → Parsear resultado |
| Clasificación OK / No OK | Parsear resultado (`resultado`) |
| Fallback a revisión manual bajo umbral | Parsear resultado (`revision_manual`) → ¿Requiere atención? → Alertar |
| Revisión manual: operador confirma/corrige/rechaza (autor+timestamp) | WF4 Bandeja de revisión (form → Aplicar revisión) |
| DB única y estructurada, sin duplicación | Registrar evidencia (PK `evidence_id`) + Guardar resultado (upsert) |
| Alertas ante desvío, con evidencia y timestamp | Alertar (desvío/revisión): incluye `evidence_id`, `imagen_ref`, hora |
| Escalable a procesos futuros sin cambios estructurales | Campo `proceso` en modelo y payload (config-driven) |
| 12. Clasificar tipo de foto (tapa/fondo/pantalla/frente) | Preparar visión (prompt v2) → Parsear (`tipo_foto`) |
| 13. Hora visible en la pantalla fotografiada | Preparar visión → Parsear (`hora_pantalla`) |
| 14. Texto impreso + calidad de impresión (láser mal calibrado) | Preparar visión → Parsear (`textos`, `calidad_impresion`) |
| 15. Comparar fondo_impresion ↔ pantalla_contador misma línea (±90 min) | Buscar contador reciente → Evaluar coherencia (`coherencia`, `motivo`) |
| 16. Persistir textos/etiquetas leídos | Guardar resultado (columnas `textos`, `etiquetas`) |
| 17. Medir tokens por inferencia | Parsear resultado (`tokens` de `response.usage`) → Guardar resultado |
| 18. Planilla + reporte automático | WF5: KPIs del día → Detalle → CSV → Telegram |
| 19. Dedup entre grupos (misma imagen) | WF1: Hash imagen → ¿Duplicada en otro grupo? → ¿Encolar? |
| 20. Producción horaria / comparativos | vistas `v_produccion_horaria`, `v_comparativo_lineas` |
| 21. Parámetros y mapeo por datos | tablas `config` (WF2 "Leer config") y `lineas_grupos` (WF1 "Buscar línea") |

## Observabilidad y robustez

- **Error Workflow** (WF3) conectado en Settings de WF1 y WF2 → toda excepción avisa a operaciones.
- **Reintentos** (`retryOnFail`, 3) en S3, Postgres, RabbitMQ, HTTP visión y Telegram.
- **Métrica** de recepción por línea en Redis (`metrics:recibidas:<linea>`).
- Ajustá el **ack** del RabbitMQ Trigger (opciones del nodo) según tu política de requeue.

> ⚠️ **Ingesta**: este flujo asume Telegram. Si el negocio exige WhatsApp, revisar el ADR de
> ingesta antes (Meta no ofrece Groups API oficial; ver `docs/arquitectura/README.md`).

## Organización en carpeta (proyecto Personal)

El MCP de n8n **no puede crear ni asignar carpetas** (solo transfiere entre *proyectos*, feature
enterprise). Para agrupar los 4 workflows en una carpeta `sudamericanabebidas` dentro de **Personal**,
hacelo a mano en la UI (1 minuto):

1. En n8n, entrá al proyecto **Personal**.
2. **New folder** → nombre `sudamericanabebidas`.
3. Seleccioná los 4 workflows "Calidad de Lata — 1..4)" y **arrastralos** (o "Move to folder") a esa carpeta.
4. (Opcional) Agregales la etiqueta `sudamericana-bebidas` para filtrarlos rápido.

Se identifican por el prefijo del nombre "Calidad de Lata — N)" y por los IDs de la tabla de arriba.
