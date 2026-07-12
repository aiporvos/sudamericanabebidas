# CLAUDE.md — Equipo de agentes "NL → n8n"

Este repositorio implementa un **equipo de subagentes de Claude Code** que transforma
peticiones en lenguaje natural (historias de usuario) en soluciones automatizadas sobre
**n8n**, con documentación funcional, decisiones de infraestructura y flujos validados.

El **hilo principal actúa de orquestador**: recibe la petición, la descompone y delega en
los subagentes especialistas mediante el Agent tool, respetando el pipeline y los handoffs.

---

## Pipeline y handoffs

```
Petición en lenguaje natural
        │
        ▼
1) analista-funcional  ──►  docs/requisitos/HU-<slug>.md  +  docs/diagramas/<slug>-*.drawio
        │
        ▼
2) arquitecto-infra  ◄────►  3) dev-tech-lead      (round-trip: se validan mutuamente)
        │  adr/ADR-<n>-*.md          │  recomendaciones de stack + componentes custom
        ▼                            ▼
4) n8n-builder  ──►  workflows/<slug>.json  (validado por n8n-mcp, importable)
        │
        ▼
Orquestador consolida + corre el checklist de puesta en marcha
```

### Cuándo delegar en cada subagente

| Necesidad | Subagente | Escribe en |
|---|---|---|
| Entender/estructurar la petición, HU, criterios de aceptación, diagramas | `analista-funcional` | `docs/` |
| Elegir hosting, storage, DB, ingesta, modelo de visión, escalado | `arquitecto-infra` | `adr/` |
| Elegir librerías/lenguaje y definir componentes que n8n no cubre | `dev-tech-lead` | `adr/` (sección) + snippets |
| Construir/validar el flujo n8n | `n8n-builder` | `workflows/` |
| Construir backend/ingesta/orquestación/cola (custom) | `backend-builder` | `services/backend/` |
| Construir el worker de visión IA/OCR (custom) | `vision-builder` | `services/vision/` |
| Definir esquema DB, storage de evidencia y datasets BI (custom) | `data-builder` | `db/`, `bi/` |
| Construir dashboard operativo + bandeja de revisión (custom) | `frontend-builder` | `apps/dashboard/` |
| Contenerizar, CI/CD, secretos y observabilidad (custom) | `devops-sre` | `deploy/` |

**Regla de handoff:** cada subagente lee los artefactos de la etapa anterior (no repite el
análisis) y produce los suyos en su carpeta. El orquestador no escribe código de negocio;
coordina, consolida y verifica trazabilidad.

**Round-trip infra ↔ dev:** infra propone la topología; dev valida que las tecnologías
elegidas encajan y define los componentes custom; si hay conflicto, se itera antes de
llamar a los builders.

---

## Dos caminos de build: n8n, custom o híbrido

El pipeline anterior produce la **decisión** (HU, ADRs, contrato de datos). Según el caso, la
solución se construye por uno de tres caminos — la elección se hace con la skill
`elegir-arquitectura` y se documenta en un **ADR** de `arquitecto-infra`:

- **Camino A — n8n** (MVP rápido): `n8n-builder` → `workflows/<slug>.json`.
- **Camino B — custom** (control/escala; el diagrama "Captura y Gestión de Evidencias de
  Calidad"): builders por capa, cada uno en su carpeta:
  - `backend-builder` → `services/backend/` (webhook FastAPI, orquestación, cola, workers).
  - `vision-builder` → `services/vision/` (visión IA/OCR, extracción, confianza, fallback).
  - `data-builder` → `db/` + `bi/` (esquema Postgres, migraciones, dedup, datasets BI).
  - `frontend-builder` → `apps/dashboard/` (dashboard operativo + bandeja de revisión manual).
  - `devops-sre` → `deploy/` (contenedores, CI/CD, secretos, observabilidad, alertas).
- **Híbrido** (recomendado como MVP escalable): n8n orquesta y los builders custom resuelven las
  cajas que n8n no cubre bien (p. ej. procesamiento de imagen pesado).

Todos los builders comparten el **contrato de datos** (skill `contrato-datos-vision`, plantilla
`docs/plantillas/contrato-datos.md`) como fuente de verdad, para encajar sin reinterpretar. La
arquitectura de referencia del camino custom está en `docs/arquitectura/README.md`.

> **Ingesta de WhatsApp (⚠️ transversal):** Meta no ofrece una "Groups API" oficial para leer
> mensajes de grupos. Resolver la vía de ingesta de los 183 grupos en un ADR antes de construir.

---

## Convenciones

- **Least-privilege:** cada subagente escribe solo en su carpeta asignada.
- **Trazabilidad:** todo artefacto se versiona en su carpeta; cada criterio de aceptación
  debe poder mapearse a un nodo del flujo o a una decisión (ADR).
- **`slug`:** kebab-case del proceso (p. ej. `calidad-lata`). Se reutiliza en HU, diagramas
  y workflow del mismo caso.
- **context7 obligatorio** antes de afirmar APIs, versiones o parámetros de cualquier
  librería/servicio. Usar WebSearch para novedades del ecosistema.
- **Plantillas:** usar siempre `docs/plantillas/` (HU, ADR, checklist-n8n) para salida
  consistente.

---

## MCP disponibles

- **n8n-mcp** (`.mcp.json`): conocimiento del schema real de n8n, templates, validación y
  deploy. Funciona en **modo doc-only** mientras `N8N_API_URL`/`N8N_API_KEY` estén vacíos.
- **drawio** (`.mcp.json`): generación de diagramas `.drawio` (BPMN, arquitectura, secuencia).
- **context7** (provisto globalmente por el plugin): documentación actualizada de librerías.

> Tras instalar los MCP, verificar con `/mcp`. Los nombres exactos de las tools MCP
> (`mcp__n8n-mcp__*`, `mcp__drawio__*`) pueden requerir ajuste en el frontmatter `tools:`
> de los subagentes una vez que los servidores estén conectados.

---

## Arquitectura de 4 capas

- **L1 — `CLAUDE.md`:** este contrato (pipeline, convenciones, glosario). Se carga siempre.
- **L2 — Skills** (auto-invocadas por lenguaje natural):
  - **Oficiales de n8n** (`n8n-io/skills`, instalar por plugin — ver README): fuente de
    verdad de la **mecánica de n8n** (`n8n-workflow-lifecycle`, `n8n-node-configuration`,
    `n8n-expressions`, `n8n-code-nodes`, `n8n-error-handling`, `n8n-binary-and-data` para
    imágenes/visión, `n8n-agents`, etc.). `n8n-builder` debe apoyarse en ellas.
  - **De este repo** (`.claude/skills/*/SKILL.md`) — complementan el **proceso**, no la
    mecánica de n8n:
    - `revisar-hu` — criterios de aceptación testeables y trazables.
    - `generar-diagrama-drawio` — convenciones BPMN/arquitectura/secuencia con draw.io MCP.
    - `validar-flujo-n8n` — gate de checklist + trazabilidad antes de desplegar.
    - `elegir-arquitectura` — decidir el camino de build (n8n / custom / híbrido).
    - `contrato-datos-vision` — contrato de datos compartido evidencia → estructura.
    - `validar-servicio` — gate de checklist + trazabilidad para servicios del camino custom.
    - `estandares-observabilidad` — convenciones de logs/trazas/métricas/alertas end-to-end.
- **L3 — Hooks** (`.claude/settings.json`): `guard-secrets.sh` (PreToolUse/Bash) bloquea
  exponer `.mcp.json`, `.env` o la API key por shell. `deny` de `.env` y `sudo`.
- **L4 — Agents** (`.claude/agents/*.md`): los subagentes especialistas — 4 del pipeline base
  (analista, infra, dev, `n8n-builder`) + 5 builders del camino custom (`backend-builder`,
  `vision-builder`, `data-builder`, `frontend-builder`, `devops-sre`).

> Seguridad: `.mcp.json` está en `.gitignore` porque contiene `N8N_API_KEY`. Para compartir
> config usá `.env.example`. No imprimas secretos por shell (el hook lo bloquea).

## Glosario de dominio (Sudamericana Bebidas)

- **Calidad de Lata:** primer proceso MVP; control de calidad de envases de lata.
- **Contador:** valor numérico en imágenes que la IA debe extraer.
- **Defecto visual:** impresión, centrado, inclinación, deformación, etiqueta, contraetiqueta.
- **OK / No OK:** clasificación automática de cada imagen según criterios de Calidad.
- **Fallback:** cuando la IA no supera el umbral de confianza, se deriva a revisión manual.
- **Desvío:** medición fuera de parámetros; dispara alerta con evidencia y timestamp.
- **Evidencia:** imagen original conservada para auditoría y reclamos.
- **Procesos futuros:** Calidad PET, Trazabilidad, Arranques de Línea, Cambios de Producto,
  Paradas No Planificadas, CO₂ (la arquitectura debe escalar a ellos sin cambios estructurales).
