# Equipo de agentes "NL → n8n" — Sudamericana Bebidas

Transforma peticiones en **lenguaje natural** (historias de usuario) en soluciones
automatizadas sobre **n8n**, con documentación funcional, diagramas, decisiones de
infraestructura y un flujo n8n validado e importable — todo trazable.

## Cómo funciona

Un **orquestador** (el hilo principal de Claude Code) descompone la petición y delega en
cuatro subagentes especialistas que colaboran en pipeline:

| # | Subagente | Hace | Escribe en |
|---|---|---|---|
| 1 | `analista-funcional` | HU estructurada + diagramas (BPMN, arquitectura, secuencia) | `docs/` |
| 2 | `arquitecto-infra` | Hosting, storage, DB, ingesta, visión IA, escalado (ADRs) | `adr/` |
| 3 | `dev-tech-lead` | Stack (Python/React/Node) + componentes custom | `adr/` + snippets |
| 4 | `n8n-builder` | Flujo n8n real, validado e importable | `workflows/` |

Detalle del pipeline, handoffs y glosario de dominio en [`CLAUDE.md`](./CLAUDE.md).

### Dos caminos de build

Además de generar flujos n8n, el equipo puede construir la **solución custom completa**
(microservicios: FastAPI + cola + workers de visión, Postgres/S3, dashboard Next.js, BI y
observabilidad). La elección n8n / custom / híbrido se decide con la skill `elegir-arquitectura` y
se documenta en un ADR. Cinco builders adicionales cubren el camino custom:

| Builder | Hace | Escribe en |
|---|---|---|
| `backend-builder` | Webhook FastAPI, orquestación, cola, workers | `services/backend/` |
| `vision-builder` | Visión IA/OCR, extracción, confianza, fallback | `services/vision/` |
| `data-builder` | Esquema Postgres, migraciones, dedup, datasets BI | `db/`, `bi/` |
| `frontend-builder` | Dashboard operativo + bandeja de revisión manual | `apps/dashboard/` |
| `devops-sre` | Contenedores, CI/CD, secretos, observabilidad | `deploy/` |

Arquitectura de referencia y contrato de datos compartido en
[`docs/arquitectura/README.md`](./docs/arquitectura/README.md).

## Requisitos previos

- **Claude Code** con los MCP de [`.mcp.json`](./.mcp.json): `n8n-mcp` y `drawio`
  (`npx` los descarga solo). **context7** ya viene provisto por el plugin.
- **Node.js** (para `npx`).
- Para deploy real de flujos (opcional): una instancia de n8n y sus credenciales →
  completar `N8N_API_URL` y `N8N_API_KEY` en `.mcp.json`. Sin eso, `n8n-mcp` corre en
  **modo doc-only** (conoce el schema y valida, pero no despliega).

Verificá los MCP con `/mcp`. Tras conectarlos, puede que necesites ajustar la línea
`tools:` de cada subagente con los nombres reales de las tools MCP
(`mcp__n8n-mcp__*`, `mcp__drawio__*`).

### Skills oficiales de n8n (recomendado)

Para que `n8n-builder` construya flujos con conocimiento profundo de nodos, expresiones,
code nodes, binario/visión y manejo de errores, instalá las **13 skills oficiales de n8n**
([`n8n-io/skills`](https://github.com/n8n-io/skills)) — se auto-invocan por lenguaje natural:

```
/plugin marketplace add n8n-io/skills
/plugin install n8n-skills@n8n-io
```

Reiniciá Claude Code después. Cubren: `n8n-workflow-lifecycle`, `n8n-node-configuration`,
`n8n-expressions`, `n8n-code-nodes`, `n8n-loops`, `n8n-agents`, `n8n-error-handling`,
`n8n-credentials-and-security`, **`n8n-binary-and-data`** (imágenes/visión — clave para
Calidad de Lata), `n8n-data-tables`, `n8n-subworkflows`, `n8n-extending-mcp`, `n8n-debugging`.
Las skills de este repo (`.claude/skills/`) son **complementarias**: cubren el proceso
(revisar HU, diagramas, gate de validación/trazabilidad), no la mecánica de n8n.

## Uso

Pasale al orquestador una petición en lenguaje natural. Ejemplo listo para probar en
[`docs/requisitos/ejemplo-peticion-calidad-lata.md`](./docs/requisitos/ejemplo-peticion-calidad-lata.md):

```
Tomá la petición de docs/requisitos/ejemplo-peticion-calidad-lata.md y corré el pipeline
completo: analista-funcional → arquitecto-infra ⇄ dev-tech-lead → n8n-builder.
```

El equipo produce: `docs/requisitos/HU-calidad-lata.md`, diagramas en `docs/diagramas/`,
ADRs en `adr/` y `workflows/calidad-lata.json`.

## Estructura

```
.mcp.json            MCP servers (n8n-mcp, drawio)  ·  en .gitignore (tiene la API key)
.env.example         Plantilla de credenciales (SÍ se versiona)
.gitignore
CLAUDE.md            Contrato del equipo: pipeline, handoffs, glosario, 4 capas
.claude/
├── settings.json    Permisos (allow/deny) + hook de seguridad
├── agents/          9 subagentes: 4 del pipeline base + 5 builders del camino custom
├── skills/          Skills de proceso (revisar-hu, diagramas, validar-flujo,
│                    elegir-arquitectura, contrato-datos-vision, validar-servicio, observabilidad)
└── hooks/           guard-secrets.sh (bloquea exponer secretos por shell)
docs/requisitos/     HU + minuta del cliente (fuente de verdad) + petición de ejemplo
docs/casos-de-uso/   Casos de uso CU-01..CU-06 (trazados a criterios y workflows)
docs/casos-de-prueba/ CP-01..CP-10 con las imágenes del kit (demo con cliente)
docs/sudamericana_photos/  Kit de fotos de prueba (tableros + latas)
docs/diagramas/      Diagramas .drawio  ·  png/ = exportados a imagen
docs/plantillas/     HU.md, ADR.md, checklist-n8n.md, checklist-servicio.md, contrato-datos.md, runbook.md
docs/arquitectura/   Arquitectura de referencia del camino custom
adr/                 Decisiones de arquitectura (infra + dev)
workflows/           Flujos n8n exportados (.json)          ← camino n8n
db/                  migracion-v3.sql + vistas-bi.sql (tablas config/lineas_grupos + BI)
services/            Backend (FastAPI, cola, workers) + visión IA   ← camino custom
apps/                Frontend (dashboard Next.js + revisión manual) ← camino custom
db/                  Esquema Postgres + migraciones                 ← camino custom
bi/                  Datasets / marts para BI                       ← camino custom
deploy/              Contenedores, CI/CD, observabilidad            ← camino custom
```
