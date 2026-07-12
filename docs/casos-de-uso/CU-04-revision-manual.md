# CU-04 — Resolver revisión manual (fallback)

> Actor principal: **Supervisor / operador de calidad** · Disparador: alerta de baja confianza
> Implementación: **WF4 Bandeja de revisión** (`Zcir83zzovfCLQrF`, formulario web)
> Criterios HU: `6, 7`

## Contexto (minuta)
"Cuando la IA no pueda interpretar correctamente una imagen, el sistema registre ese
evento para su posterior análisis" — el fallback no inventa resultados: deriva a una persona.

## Precondiciones
- Una evidencia quedó en estado `revision_manual` (confianza < 0.85, CU-02).
- El supervisor recibió la alerta con el `evidence_id` (CU-05).

## Flujo principal
1. El supervisor recibe la alerta "🔍 Revisión manual (baja confianza)" con el
   `evidence_id`, la referencia a la imagen y lo que la IA alcanzó a leer.
2. Abre el **formulario de revisión** (WF4).
3. Ingresa: `evidence_id`, **Resultado** (OK / No OK / Rechazado), su **nombre** y un
   comentario opcional.
4. El sistema actualiza `resultados`: estado `revisado` (o `rechazado`), resultado final,
   **autor** y **timestamp** de la revisión (criterio 7 — trazabilidad de la decisión).

## Flujos alternativos
- **A1 — Rechazado** (la foto no sirve como evidencia): queda registrado el evento; el
  operario puede reenviar una foto nueva (nuevo `evidence_id`).

## Postcondición
Ninguna evidencia queda sin resolución: o la clasificó la IA con confianza, o la
resolvió una persona con firma y hora.
