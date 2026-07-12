# Pendientes que dependen del CLIENTE — Calidad de Lata

> Todo lo técnico de la minuta 25/06 está construido y probado. Esta es la lista **completa**
> de lo que solo el cliente puede aportar para pasar de piloto a producción.
> (Referencia: minuta, sección "Próximos pasos / Jesús".)

## 1. Criterios de calidad reales (Jesús) — ⭐ el más importante
- Parámetros de calidad ya documentados.
- **Criterios de aceptación/rechazo** por tipo de control (qué es OK y qué No OK, con tolerancias).
- **Ejemplos de fotografías correctas e incorrectas** (mínimo 10–20 por tipo de foto).
- *Para qué:* hoy la IA juzga con criterio genérico. Con esto se afina el prompt (y la
  confianza deja de ser una estimación genérica). Sin esto, el piloto funciona pero el
  veredicto OK/No OK no es el del cliente.

## 2. Mapeo de los grupos reales (183 → 3 líneas)
- Lista de grupos de Telegram con su **chat_id → línea, equipo, proceso**.
- *Para qué:* se cargan como filas en la tabla `lineas_grupos` (sin tocar ningún flujo):
```sql
INSERT INTO lineas_grupos (chat_id, linea, equipo, proceso) VALUES ('-100XXXX', 'linea-1', 'llenadora', 'calidad-lata');
```

## 3. Validación de parámetros operativos (tabla `config`, editable en caliente)
| Parámetro | Valor actual (supuesto nuestro) | El cliente confirma |
|---|---|---|
| `umbral_confianza` | 0.85 | ¿% mínimo para no ir a revisión manual? |
| `ventana_comparacion_min` | 90 min | ¿Cuánto puede diferir la hora impresa de la pantalla? |
| `dedup_ventana_horas` | 24 h | ¿Ventana para considerar una foto repetida? |

## 4. Alertas y reportes
- ¿A qué **grupo/chat** van las alertas y el reporte diario? (hoy: el grupo de prueba)
- ¿**Horario** del reporte? (hoy: 07:00) ¿Por turno además de diario?
- ¿Quiénes usan la **bandeja de revisión** (URL del formulario)?

## 5. Retención de evidencias
- ¿Cuánto tiempo se conservan las **imágenes originales** (MinIO) y los datos? (auditoría/reclamos)

## 6. Canal de ingesta
- Confirmar **Telegram** como canal definitivo (ADR-001: WhatsApp no tiene API de grupos).
  Implica plan de adopción con los operarios.

## 7. Próximo piloto
- Decidir cuál sigue tras Calidad de Lata (la minuta lista: PET, Trazabilidad, Arranques,
  Cambios de producto, Paradas no planificadas, CO₂ — "el más simple").

## 8. Minuta completa
- Si el documento del Drive difiere del texto pegado el 11/07, bajarlo al repo para re-auditar.
