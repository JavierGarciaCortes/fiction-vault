# fiction-vault

Estructura base para arrancar un proyecto de escritura con [opencode](https://opencode.ai).

Compatible con **Obsidian** — todo el contenido son archivos Markdown con wikilinks `[[enlaces]]`.
Los capítulos, fichas de personaje, ubicaciones y lore se editan en Obsidian; las tools python
trabajan directamente sobre los `.md`.

## Qué incluye

- **Obsidian-ready**: bóveda list para arrastrar a Obsidian. Wikilinks, YAML metadata, todo Markdown.
- **Tools de escritura**: scanner de prosa, carta editorial, verificador de consistencia, publicador EPUB/HTML/PDF, etc.
- **MCP server**: contexto de personajes, lore, continuidad y foreshadowing para el asistente AI.
- **Configuración data-driven**: perfiles de voz, acts, POV, todo en JSON.
- **Plantillas**: fichas de personaje, ubicaciones, lore, capítulos.

Sin dependencias externas — solo Python 3.11+ (stdlib).

## Cómo usar

```bash
git clone https://github.com/quinwacca/fiction-vault.git mi-libro
cd mi-libro
# Abrir con opencode, o arrastrar a Obsidian
```

El MCP server se registra automáticamente desde `opencode.json`.

## Publicación

```bash
python tools/publish.py                      # EPUB → output/
python tools/publish.py --format all         # EPUB + HTML + PDF
python tools/publish.py --format pdf         # solo PDF (necesita weasyprint)
python tools/publish.py --beta               # HTML con números de línea (beta)
```

## Windows

Cambiar `python3` por `python` en `opencode.json`:

```json
"command": ["python", "tools/fiction_mcp.py"]
```

## Personalización

1. Editar `.fiction/config.json` — título, autor, acts, POV map
2. Editar `.fiction/voice_profiles.json` — perfiles de voz de personajes
3. Rellenar `Mundo/Personajes/`, `Mundo/Lugares/`, `Mundo/Historia/`
4. Usar `Referencias/Outliner.md` para planificar el manuscrito

## Tools principales

```bash
python tools/prose_scanner.py          # escanear prosa (detección de patrones)
python tools/editorial_letter.py       # carta editorial automatizada
python tools/editorial_letter.py --beta # informe profesional completo
python tools/consistency_check.py      # verificar consistencia (objetos, clima, atributos)
python tools/publish.py                # publicar EPUB/HTML/PDF
python tools/session_check.py          # resumen de cambios entre sesiones
python tools/new_chapter.py "Título"   # crear nuevo capítulo
python tools/new_chapter.py "Título" -p 5  # insertar en posición 5
```
