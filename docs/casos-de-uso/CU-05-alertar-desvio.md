# CU-05 — Alertar desvío en tiempo real

> Actor principal: **Sistema** → grupo Telegram de supervisión · Implementación: **WF2**
> nodo "Alertar (desvío/revisión)" + **WF3** para errores de plataforma · Criterios HU: `10`

## Contexto (minuta)
"Hoy sólo pueden actuar cuando alguien revisa la información. El objetivo es pasar a un
sistema que detecte desvíos automáticamente, genere alertas y permita actuar en tiempo real."

## Disparadores (cualquiera)
- Resultado **No OK** (defectos detectados).
- **Baja confianza** → revisión manual (CU-04).
- **Calidad de impresión mala** (aunque el dato sea correcto).
- **Incoherencia** impresión ↔ pantalla (CU-03).

## Flujo principal
1. El sistema arma la alerta (formato HTML con negritas) e incluye:
   tipo de foto, línea, equipo, **textos leídos**, hora en pantalla, calidad de
   impresión, defectos, **motivo**, confianza (%), `evidence_id`, referencia a la
   **imagen original** (evidencia) y **timestamp** (criterio 10).
2. La envía al grupo Telegram de supervisión (`-1003908341093`).
3. El supervisor actúa (parar línea, recalibrar, revisar — o CU-04 si es revisión).

## Flujos alternativos
- **A1 — Todo OK**: **no se alerta** (con >1.000 fotos/día, el silencio es información:
  solo llegan los desvíos).
- **A2 — Error de plataforma** (falla un workflow): WF3 avisa a operaciones con nodo,
  mensaje de error y hora.

## Postcondición
El desvío se conoce en minutos (no cuando alguien revisa planillas), con evidencia y
motivo para actuar.
