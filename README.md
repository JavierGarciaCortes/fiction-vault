# fiction-vault

Estructura base para arrancar un proyecto de escritura con [opencode](https://opencode.ai).

## Qué incluye

- **Tools de escritura**: scanner de prosa, carta editorial, verificador de consistencia, generador EPUB, etc.
- **MCP server**: contexto de personajes, lore, continuidad y foreshadowing para el asistente AI.
- **Configuración data-driven**: perfiles de voz, acts, POV, todo en JSON.
- **Plantillas**: fichas de personaje, ubicaciones, lore, capítulos.

Sin dependencias externas — solo Python 3.11+ (stdlib).

## Cómo usar

```bash
git clone https://github.com/quinwacca/fiction-vault.git mi-libro
cd mi-libro
# Abrir con opencode
```

El MCP server se registra automáticamente desde `opencode.json`.

## Windows

Cambiar `python3` por `python` en `opencode.json`:

```json
"command": ["python", "tools/fiction_mcp.py"]
```

## Personalización

1. Editar `.fiction/config.json` — título, autor, acts, POV map
2. Editar `.fiction/voice_profiles.json` — perfiles de voz de personajes
3. Rellenar `Mundo/Personajes/`, `Mundo/Lugares/`, `Mundo/Historia/`
4. Referencias/Outliner.md para planificar el manuscrito

## Tools principales

```bash
python tools/prose_scanner.py          # escanear prosa
python tools/editorial_letter.py       # carta editorial
python tools/consistency_check.py      # verificar consistencia
python tools/publish.py                # generar EPUB
python tools/session_check.py          # resumen de cambios
python tools/new_chapter.py "Título"   # nuevo capítulo
```
