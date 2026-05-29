# Estado del proyecto — [Nombre del libro]

> **Última actualización:** [fecha]

## Qué es esto

[Género, extensión estimada, estructura. 2-3 líneas.]

## Estado actual por capítulo

| Cap | Título | Palabras | Scanner | Notas |
|-----|--------|----------|---------|-------|
| 01 | [título] | 0 | — | — |
| 02 | [título] | 0 | — | — |
| 03 | [título] | 0 | — | — |

## Reglas de estilo clave (resumen rápido)

- **Rayas**: solo en diálogo (`—`)
- **POV**: un personaje por capítulo. Cambio = capítulo nuevo
- **Elipsis temporal**: nunca a mitad de capítulo

## Decisions cerradas <!-- PROYECTO -->

- **Final**: [decidir o dejar como TBD]

## Pendientes

1. [Pendiente 1]
2. [Pendiente 2]

## Herramientas

### Scanner de prosa
- `python tools/prose_scanner.py` — scan global
- `python tools/prose_scanner.py --cap XX --context full` — detalle con párrafos
- `python tools/prose_scanner.py --json` — salida JSON
- `python tools/prose_scanner.py --review` — modo interactivo
- `python tools/prose_scanner.py --ritmo` — variación de longitud de frases
- `python tools/prose_scanner.py --validate` — detectar overlaps entre patrones

### MCP (X tools)
- `check_chapter(chapter)` — meta-tool: ejecuta todos los análisis de una vez
- `check_pacing(chapter?)` — desviación estándar de longitud de frases
- `scan_prose(chapter?)` — patrones de prosa
- `editorial_letter(...)` — carta editorial completa
- + herramientas de voz, estructura, consistencia, foreshadowing

### Publicación
- `python tools/publish.py` — EPUB
- `python tools/publish.py --format html` — HTML único
- `python tools/publish.py --beta` — HTML con números de línea para beta readers
- `python tools/publish.py --format pdf` — PDF (requiere weasyprint)
