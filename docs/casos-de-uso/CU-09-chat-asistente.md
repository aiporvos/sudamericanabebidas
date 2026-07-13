# CU-09 — Consultar evidencias y métricas por chat (Lupa)

> Actor principal: **Analista de calidad / cualquier usuario del dashboard**
> Implementación: **WF7 "Chat Asistente IA"** (`IpHaLdb29KIkMVrn`) + **WF7b "Tool Consultar
> Evidencias"** (`1V5WzKjcmzsrJ9bO`, sub-workflow invocado como tool del AI Agent)
> Criterios HU: `24`

## Contexto
Complementa a CU-06: en vez de aplicar filtros manualmente, el usuario le pregunta a **Lupa**
en lenguaje natural — desde una burbuja de chat flotante en el dashboard — y el agente
consulta la base real antes de responder.

## Precondiciones
- WF7 activo, WF7b **activo** (un sub-workflow-tool inactivo no puede ser invocado por el
  AI Agent — falla en silencio).
- Vista `v_evidencias_completas` existente (`db/vistas-bi.sql`).
- Credencial OpenRouter con saldo disponible.

## Flujo principal
1. El usuario abre el chat (`ChatWidget.tsx` en `apps/dashboard/`) y escribe una pregunta,
   p. ej. *"¿Cuántas evidencias hubo hoy?"*.
2. El dashboard hace `POST /webhook/dashboard-calidad-chat` con `{ session_id, mensaje }`.
3. El **AI Agent** (persona "Lupa", modelo `openai/gpt-4o-mini` vía OpenRouter) interpreta la
   pregunta y decide llamar a la tool **"Consultar evidencias de Calidad"** con los
   parámetros que correspondan:
   - `modo: 'resumen'` para conteos, promedios o comparaciones entre líneas.
   - `modo: 'detalle'` para casos puntuales, defectos o motivos de un desvío.
   - `dias_atras` traducido desde la expresión temporal del usuario ("hoy"→1, "esta
     semana"→7, "este mes"→30).
4. La tool (WF7b) ejecuta la consulta real sobre `v_evidencias_completas` (agregada o
   detallada según el modo) y devuelve el resultado al agente.
5. Lupa redacta la respuesta en texto plano (sin markdown) con los **números reales**
   devueltos por la tool, y el dashboard la muestra en el chat.
6. Si el usuario hace una **pregunta de seguimiento** en la misma sesión (p. ej. *"¿y cuál
   fue el motivo?"*), el agente mantiene el contexto vía **memoria de sesión** (`session_id`
   persistido en `localStorage` del navegador) y puede volver a llamar a la tool en modo
   `detalle` si hace falta el dato puntual.

## Flujos alternativos
- **A1 — Sin datos en el período**: la tool devuelve vacío; Lupa lo dice explícitamente
  ("no hay evidencias en ese período"), nunca inventa cifras (system prompt lo prohíbe).
- **A2 — Pregunta fuera de dominio**: Lupa responde amablemente que solo ayuda con temas de
  Calidad de Lata (no intenta responder con conocimiento general).
- **A3 — Falla de conexión / timeout (30s)**: el widget muestra un mensaje de sistema
  ("No pude conectarme con Lupa…" / "Lupa tardó demasiado…") sin romper el chat.
- **A4 — Nueva sesión**: el botón "Nueva sesión" en la cabecera del chat genera un
  `session_id` nuevo y limpia la memoria — útil para arrancar una conversación sin el
  contexto de la anterior.

## Notas técnicas / gotchas de esta build
- El `queryReplacement` de los nodos Postgres de WF7b usa **formato array**
  (`={{ [a, b] }}`), no comma-string: con parámetros opcionales vacíos (línea/resultado sin
  filtrar) el formato comma-string pierde el parámetro y Postgres tira error.
- Las `typeVersion` de **Simple Memory** y **Execute Workflow Trigger** están fijadas a 1.2
  y 1.1 respectivamente — versiones más nuevas no son soportadas por esta instancia de n8n
  (ícono roto en el canvas, pierde parámetros al abrir/guardar en la UI).
- `openrouter/auto` fue evaluado como modelo de fallback ante falta de créditos y
  **descartado**: no es confiable para tool-calling.

## Postcondición
El usuario obtiene una respuesta conversacional con datos reales y trazables (misma fuente
que el dashboard), sin necesidad de armar filtros ni saber SQL.
