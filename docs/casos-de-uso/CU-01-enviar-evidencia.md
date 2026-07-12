# CU-01 — Enviar y registrar evidencia fotográfica

> Actor principal: **Operario de planta** · Frecuencia: **cada hora, por línea** (>1.000 fotos/día)
> Implementación: **WF1 Ingesta** (`grKAt4YQr6SutRI3`) · Criterios HU: `1, 2, 8`

## Disparador
El operario realiza el control horario de calidad de lata (tapa, impresión del fondo,
pantalla del contador, frente — minuta, "Controles actuales/Latas").

## Precondiciones
- El bot `sudamericana_bot` está en el grupo Telegram de la línea.
- WF1 activo; MinIO, Postgres y RabbitMQ operativos.

## Flujo principal
1. El operario fotografía la evidencia con su celular.
2. Envía la foto al **grupo Telegram de su línea** (no cambia su operativa actual).
3. El sistema recibe el mensaje y descarga la imagen.
4. Normaliza la evidencia: identifica la **línea** (por grupo), genera el `evidence_id`
   y registra la **hora de envío**.
5. Guarda la **imagen original** en MinIO (`calidad-lata/...`) — evidencia inmutable para
   auditoría y reclamos.
6. Registra la evidencia en Postgres (`evidencias`).
7. Publica la tarea de procesamiento en la cola RabbitMQ (`calidad.lata.procesar`).

## Flujos alternativos
- **A1 — Mensaje sin foto** (texto, sticker, audio): se descarta sin procesar.
- **A2 — Evidencia duplicada** (reenvío): la clave primaria `evidence_id` rechaza el
  duplicado y se ignora (criterio 8 — sin duplicación).

## Excepciones
- **E1 — Fallo de infraestructura** (MinIO/Postgres/cola caídos): WF3 avisa por Telegram
  a operaciones con nodo, error y hora.

## Postcondición
La evidencia queda conservada (imagen + registro) y encolada para interpretación (CU-02).
