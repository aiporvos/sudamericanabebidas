# ADR-004: No-duplicación de evidencias (idempotencia)

> estado: `aceptada` · autor: `dev` · fecha: `2026-07-04`
> caso: `calidad-lata`

## Contexto
El dolor actual incluye **duplicación**: la misma foto se reprocesa varias veces. El sistema debe
garantizar que una evidencia se procese y persista **una sola vez**, incluso ante reenvíos o reintentos
de cola. Impacta el criterio 8.

## Opciones evaluadas
### Opción A — Clave natural con constraint único en la DB
- Pros: invariante fuerte y **atómico** en la base (no depende de la app); simple.
- Contras: hay que definir bien la clave natural.
- Verificado con context7: `sí — PRIMARY KEY / UNIQUE + ON CONFLICT en Postgres`.

### Opción B — Dedup solo en la aplicación / cola (cache Redis)
- Pros: rápido, evita llegar a la DB.
- Contras: **no atómico**; ante carreras o reinicios puede colar duplicados; no es garantía.

## Decisión
**Opción A** como autoridad: `evidence_id = proceso:linea:chat_id:message_id` es **PRIMARY KEY** en la
tabla `evidencias`. Un duplicado hace fallar el INSERT y se enruta por la **salida de error** del nodo a
"ignorar". Redis (B) se usa como **métrica/idempotencia rápida best-effort**, no como garantía. Así el
invariante vive en la DB (según skill `contrato-datos-vision`).

## Consecuencias
- Requiere el `evidence_id` determinístico calculado en la ingesta (nodo "Normalizar evidencia").
- Robusto ante reintentos de RabbitMQ y reenvíos del operario.
- Criterios de aceptación afectados: `8`.
