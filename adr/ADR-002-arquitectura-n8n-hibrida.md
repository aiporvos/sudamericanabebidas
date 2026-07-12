# ADR-002: Arquitectura de build — n8n, custom o híbrido

> estado: `aceptada` · autor: `infra` · fecha: `2026-07-04`
> caso: `calidad-lata`

## Contexto
Hay que elegir cómo se construye la solución de captura y gestión de evidencias. El negocio necesita un
MVP rápido pero que escale a los procesos futuros sin rehacerse. Impacta todos los criterios de aceptación.

## Opciones evaluadas
### Opción A — n8n (orquestador visual)
- Pros: time-to-MVP en días; menos que operar (cola/reintentos/errores los da n8n); reglas modificables
  sin re-deploy; nodos nativos (Telegram, S3, Postgres, RabbitMQ, Redis, HTTP visión).
- Contras: techo de rendimiento en procesamiento de imagen pesado; lógica muy compleja incómoda; obs. menos fina.
- Costo / esfuerzo operativo: bajo.

### Opción B — Custom (microservicios: FastAPI + workers + cola + front)
- Pros: máximo control, escala y observabilidad.
- Contras: semanas/meses de desarrollo; requiere equipo dev+devops fijo; sobredimensionado para el MVP.
- Costo / esfuerzo operativo: alto y continuo.

### Opción C — Híbrido (n8n orquesta + servicios custom para lo pesado)
- Pros: arranca rápido en n8n y extrae a custom solo el camino caliente (visión) cuando el volumen lo pida.
- Contras: dos tecnologías conviviendo; límite n8n↔custom a definir por caso.

## Decisión
**Opción C — Híbrido, arrancando 100% en n8n.** El MVP se implementa en n8n (ya construido: 3 workflows
con Telegram + RabbitMQ + Redis + S3 + Postgres + visión IA). Si el volumen o la latencia lo exigen, se
extrae el **procesamiento de visión** a un servicio custom (`vision-builder`) sin cambiar el resto. Se
descarta B como punto de partida (costo/plazo) y A "puro" porque el camino caliente puede necesitar escala.

## Consecuencias
- MVP entregable rápido; ruta de escalado clara hacia el diagrama custom (`docs/arquitectura/README.md`).
- Almacenamiento (S3, Postgres), APIs de visión y BI quedan externos a n8n en ambos caminos.
- Criterios de aceptación afectados: `todos`.
