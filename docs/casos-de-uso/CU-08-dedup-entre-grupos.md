# CU-08 — Detectar la misma foto enviada a varios grupos

> Actor principal: **Sistema** (WF1) · Disparador: llega una foto cuya imagen ya se procesó
> Implementación: **WF1 v3** — nodos "Hash imagen" → "¿Duplicada en otro grupo?" → "¿Encolar?"
> Criterios HU: `19` · Minuta: "Mucha información duplicada — la misma información termina
> apareciendo en distintos grupos"

## Precondiciones
- Migración v3 aplicada (`imagen_hash` en `evidencias`, parámetro `dedup_ventana_horas` en `config`).

## Flujo principal
1. Al recibir una foto, el sistema calcula su **hash SHA-256** (huella digital del archivo).
2. Busca si **la misma huella** ya ingresó por cualquier grupo dentro de la ventana
   configurada (default 24 h).
3. **No hay coincidencia** → la evidencia sigue su curso normal (estado `recibido`, se encola
   para la IA).

## Flujos alternativos
- **A1 — Ya existe la misma imagen**: la evidencia se registra con estado **`duplicada`**
  (con referencia a la original en `duplicada_de`) y **no se encola**: no gasta IA, no
  duplica datos, no genera alertas repetidas.

## Notas
- La ventana se ajusta en `config.dedup_ventana_horas` sin tocar el flujo.
- El dedup **por mensaje** (reintentos de Telegram) sigue existiendo aparte (PK `evidence_id`).
- ⚠️ En demos: reenviar la misma foto de prueba dentro de la ventana la marca duplicada
  (comportamiento correcto); usar fotos distintas o bajar la ventana para re-probar.

## Postcondición
Una evidencia = un procesamiento, aunque la operativa la comparta en varios grupos.
