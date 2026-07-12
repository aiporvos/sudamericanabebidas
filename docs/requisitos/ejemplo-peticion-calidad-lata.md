# Petición de entrada (ejemplo) — Calidad de Lata

> Este es un **input de ejemplo** para probar el pipeline. El `analista-funcional` lo toma
> como petición en lenguaje natural y produce `docs/requisitos/HU-calidad-lata.md` +
> diagramas. Sirve como caso de verificación end-to-end del equipo de agentes.

## Petición (lenguaje natural del cliente)

Como responsable de Calidad y Producción, quiero una solución que automatice la captura,
interpretación y gestión de las evidencias de calidad mediante Inteligencia Artificial, para
reducir el trabajo manual de los operadores, centralizar la información, mejorar la
trazabilidad y detectar desvíos en tiempo real.

Hoy el control de calidad se hace manual usando **183 grupos de WhatsApp** donde los
operadores comparten fotos de contadores, controles de calidad y evidencias de producción.
Cada hora toman fotos, las mandan a distintos grupos y completan planillas a mano; luego
otros reprocesan lo mismo para consolidar datos, generar indicadores y responder reclamos.
Esto genera duplicación, alto esfuerzo, errores de transcripción, dificultad para localizar
evidencias históricas y baja reacción ante desvíos.

Se quiere un sistema que reciba las imágenes, use IA de visión para interpretar su contenido
y lo transforme en datos estructurados, automatizando el control y generando alertas ante
anomalías. **Primer MVP: Calidad de Lata**, dejando preparada la solución para incorporar
después Calidad PET, Trazabilidad, Arranques de Línea, Cambios de Producto, Paradas No
Planificadas y CO₂.

## Puntos clave esperados en la interpretación
- Recepción de fotos con fecha/hora y conservación de la imagen original.
- IA que extrae valores de contadores y detecta defectos visuales (impresión, centrado,
  inclinación, deformaciones, etiquetas, contraetiquetas).
- Clasificación OK / No OK; fallback a revisión manual bajo umbral de confianza.
- DB única y estructurada, sin duplicación; consulta histórica por fecha/línea/equipo/proceso.
- Alertas ante desvíos, con evidencia y timestamp.
- Arquitectura escalable a los procesos futuros sin cambios estructurales.
- Prioridad: **Alta**.
