# Plan de cierre del MVP — Calidad de Lata

**Fecha:** 2026-07-13 · **Estado general:** técnica lista para piloto; faltan decisiones del cliente.

Matriz contra el checklist "Preguntas clave para cerrar el MVP". Cada punto tiene su estado,
la evidencia verificable de lo cubierto y lo que falta con responsable.

| # | Punto | Estado |
|---|---|---|
| 1 | Unificar criterios del MVP | 🟡 Parcial — falta matriz aprobada |
| 2 | Línea, equipo y producción | 🟡 Parcial — falta mapa real de grupos |
| 3 | Evitar duplicados | 🟢 Cubierto — falta DLQ y prueba de retry |
| 5 | Correlación pantalla-lata | 🟢 Cubierto — falta aprobación de tolerancias |
| 6 | Precisión, tiempo y costo | 🟡 Instrumentado — faltan umbrales y dataset |
| 7 | Consulta histórica simple | ✅ **Cerrado** |
| 8 | Suite de pruebas y acta | 🟡 Definida — falta ejecutarla y el acta |

---

## 1. Unificar los criterios del MVP — 🟡

**Cubierto (evidencia):**
- HU consolidada con criterios de aceptación 1–21: `docs/requisitos/HU-calidad-lata.md`.
- Fuente de verdad: minuta del 25/06/2026 en `docs/requisitos/minuta-2026-06-25.md`.
- Trazabilidad criterio → caso de uso (`docs/casos-de-uso/` CU-01..CU-08) → prueba
  (`docs/casos-de-prueba/` CP-01..CP-12).

**Falta:**
- [ ] Matriz única **incluido / diferido / descartado** firmada por el cliente. Los temas
      abiertos están en `docs/requisitos/pendientes-cliente.md` (criterios de Jesús, retención,
      destinatarios de alertas, etc.). **Responsable: cliente + Claudio.**

## 2. Identificar línea, equipo y producción — 🟡

**Cubierto (evidencia):**
- WF1 v3 resuelve la línea vía tabla `lineas_grupos` (config-driven) con fallback al
  título del chat; evidencia sin contexto → revisión manual. Ver `db/migracion-v3.sql`.
- El equipo se extrae de los textos del tablero por visión.

**Falta:**
- [ ] Cargar el **mapa real grupo → línea** (183 grupos). **Responsable: cliente.**
- [ ] Definir el origen formal de "equipo" (¿configuración por grupo o lectura del tablero?).
- [ ] Definir qué dato representa **producción**: lote, orden, producto o turno. Hoy se usa el
      lote leído de la impresión/pantalla. **Responsable: cliente.**

## 3. Evitar duplicados — 🟢

**Cubierto (evidencia):**
- Evento único: `evidence_id = proceso:grupo:chat_id:message_id` como PRIMARY KEY; el
  duplicado sale por la rama de error del INSERT y no se encola (sin segunda inferencia ni alerta).
- Imagen reenviada: hash SHA-256 + ventana configurable (`config.dedup_ventana_horas`),
  detecta el mismo archivo incluso en otro grupo → estado `duplicada`.
- Resultado idempotente: `INSERT … ON CONFLICT` en `resultados`.
- Prueba: CP-02 (descarte de duplicado).

**Falta:**
- [ ] Configurar la **DLQ en RabbitMQ** (pasos en `workflows/calidad-lata.README.md`).
      **Responsable: Claudio (UI de RabbitMQ).**
- [ ] Prueba formal "un retry del consumidor no genera segunda alerta" (registrar en la
      planilla de CP-12).

## 5. Validar la correlación pantalla-lata — 🟢

**Cubierto (evidencia):**
- "Evaluar coherencia" (WF2) compara **por línea** con 3 chequeos: LOTE (acepta lote compuesto
  y ambos formatos de impresión), VTO (fechas normalizadas) y HORA (±90 min, ventana
  configurable en `config`).
- Sin referencia → `coherencia = null` (**no comparable**, no penaliza).
- Regla operativa documentada: el tablero se envía **antes** que la lata (la búsqueda mira
  hacia atrás).
- Casos: CP-04 (coherente), CP-05 (hora incoherente), CP-06 (lote+vto incorrectos),
  CP-07 (cambio de lote).

**Falta:**
- [ ] Aprobación del cliente de las tolerancias (¿90 min? ¿aceptar pantallas posteriores?).
- [ ] Ejecutar y registrar los 4 casos (correcto / incorrecto / ambiguo / sin referencia).

## 6. Medir precisión, tiempo y costo — 🟡

**Cubierto (evidencia):**
- **Costo:** tokens por evidencia en `resultados.tokens`; costo estimado visible en el
  dashboard (KPI "Tokens IA") y en el reporte diario (WF5).
- **Tiempo:** `latencia_segundos` (= `evaluado_en − capturado_en`) expuesta por WF6 y
  **KPI "Latencia p95"** en el dashboard (agregado 2026-07-13). Valores reales del piloto: ~9 s.
- Modelo (gpt-4o) y prompt versionados en `workflows/calidad-lata-2-procesamiento.json`.

**Falta:**
- [ ] Dataset real **etiquetado** para medir precisión y falsos OK. **Responsable: cliente
      (etiquetas) + Claudio (corrida).**
- [ ] Umbrales acordados: máximo de falsos OK, % de fallback, latencia p95 máxima, costo
      máximo por imagen/día.
- [ ] Informe de cierre con esas métricas.

## 7. Habilitar una consulta histórica simple — ✅ CERRADO

**Cubierto (evidencia):**
- **`https://dashboard.cluna.ar`** (SPA React + nginx en Dokploy, deploy automático desde
  `aiporvos/sudamericanabebidas-dashboard`).
- Filtros: fecha desde/hasta, línea (multi), tipo de foto (multi), resultado, estado y
  búsqueda libre. KPIs y 4 gráficos.
- Detalle por evidencia (clic en la fila): **foto original desde MinIO**, resultado,
  confianza, motivo, coherencia, defectos, textos leídos, latencia y tokens
  (agregado 2026-07-13 vía endpoint `GET /webhook/dashboard-calidad-imagen`).
- Criterio de cierre cumplido: *"un analista encuentra evidencia, motivo e imagen sin usar SQL"*.
- La planilla convive: WF5 manda el CSV diario a las 07:00 por Telegram.

**Decisión pendiente (no bloquea):**
- [ ] Cuándo se retira la planilla CSV en favor del dashboard. **Responsable: cliente.**

## 8. Ejecutar pruebas y aceptar el piloto — 🟡

**Cubierto (evidencia):**
- Suite definida: CP-01..CP-12 con planilla de resultados (`docs/casos-de-prueba/README.md`).
- Versiones auditables: workflows exportados en `workflows/*.json` (repo git), IDs de la
  instancia documentados; front de control = dashboard + bandeja WF4.
- Aislamiento: cada ejecución queda en Executions de n8n con su ID.

**Falta:**
- [ ] **Ejecutar la suite completa** registrando IDs de ejecución y resultados.
- [ ] Definir aprobador y condición bloqueante del Go. **Responsable: cliente.**
- [ ] **Acta final** Go / Ajustar / No Go con métricas, fallas y riesgos.

---

## Plan de acción consolidado

| # | Acción | Responsable | Estado |
|---|---|---|---|
| 1 | Imagen en el detalle del dashboard | Claudio (IA) | ✅ hecho 2026-07-13 |
| 2 | Latencia medida + KPI p95 | Claudio (IA) | ✅ hecho 2026-07-13 |
| 3 | DLQ RabbitMQ + prueba de retry | Claudio | ☐ |
| 4 | Ejecutar suite CP-01..CP-12 y registrar | Claudio | ☐ |
| 5 | Matriz incluido/diferido/descartado | Cliente + Claudio | ☐ |
| 6 | Mapa grupos→línea + dato de producción | Cliente | ☐ |
| 7 | Dataset etiquetado + umbrales de métricas | Cliente + Claudio | ☐ |
| 8 | Acta final Go/Ajustar/No Go | Cliente | ☐ |

> **Regla de cierre:** cada decisión necesita responsable, evidencia verificable y criterio de
> aceptación cumplido. Las evidencias técnicas de este documento son verificables en el repo
> (`aiporvos/sudamericanabebidas`), la instancia n8n (n8n.aiporvos.com) y el dashboard
> (dashboard.cluna.ar).
