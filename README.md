# fiction-vault

Estructura base para arrancar un proyecto de escritura con [opencode](https://opencode.ai).

Compatible con [Obsidian](https://obsidian.md) — todo el contenido son archivos Markdown con wikilinks `[[enlaces]]`.
Los capítulos, fichas de personaje, ubicaciones y lore se editan en Obsidian; las tools python
trabajan directamente sobre los `.md`.

## Qué incluye

- **Obsidian-ready**: bóveda list para arrastrar a Obsidian. Wikilinks, YAML metadata, todo Markdown.
- **Tools de escritura**: scanner de prosa, carta editorial, insights avanzados, verificador de consistencia, resumen de sesión, publicador EPUB/HTML/PDF, etc.
- **MCP server** (9 tools base + 8 de diagnóstico + 5 estructurales): personajes, lore, continuidad, foreshadowing, voz, emociones, escenas, hooks, show/tell, ritmo, arco narrativo, Save the Cat, Chekhov.
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

## Trabajar con la IA: tu editor de viaje

Esta herramienta no es un chatbot al que le pides cosas sueltas. Es un **editor** que se sienta a tu lado durante todo el proceso de escribir: desde el primer borrador hasta la versión final. Conoce tu manuscrito, entiende tu mundo, y te ayuda a tomar decisiones.

No tienes que explicarle quién es cada personaje ni qué pasó en el capítulo anterior — lo sabe. No tienes que recordar comandos ni flags — se anticipa a lo que necesitas.

### Cómo empieza cada sesión

Abres la bóveda y el editor ya está al día:

- Ejecuta `session_check.py` — ve qué cambió desde la última vez
- Lee los pendientes — sabe en qué te quedaste
- Consulta el estado del manuscrito — tiene los scores frescos

Y está listo. No hay ritual de puesta al día.

### Qué puedes pedirle

| Quieres… | Le dices… |
|---|---|
| Una foto general de la novela | «Dame la carta editorial» |
| Revisar un capítulo a fondo | «Revisa el capítulo 7, céntrate en diálogo» |
| Saber si hay problemas de ritmo | «¿Cómo va el ritmo? ¿Hay capítulos que lastran?» |
| Verificar que un personaje suena auténtico | «Comprueba la voz de Gandalf en el capítulo 5» |
| Detectar telling emocional | «Busca tellings en el capítulo 3» |
| Saber qué hilos dejaste abiertos | «¿Qué foreshadowing queda sin pagar?» |
| Comprobar si dos escenas se contradicen | «Verifica consistencia entre los capítulos 2 y 6» |

No necesitas saber qué tool hay detrás. El editor decide cómo obtener lo que pides.

### Su equipo de especialistas

El editor tiene colegas con enfoques distintos a los que puede llamar según lo que necesites:

- **`@writer`** — para generar prosa, diálogo, descripciones. Le dices el tono y lo que buscas; él escribe.

  > ⚠️ *Advertencia de salud narrativa: el que escribe eres tú. Usa a @writer como un compañero de lluvia de ideas, no como un sustituto. Pídele borradores, versiones alternativas, desbloqueos cuando estés atascado. Pero no dejes que te robe el placer de poner tus propias palabras. Si sientes que ya no escribes tú, estás usando la herramienta al revés. Que sea tu ayudante, no tu relevo.*
- **`@critico`** — ojo de guionista, sin piedad. Busca agujeros, clichés, reglas rotas. Úsalo cuando quieras que alguien le pegue una patada honesta a tu manuscrito.
- **`@lector`** — lee como si no supiera nada del mundo ni de tus intenciones. Ideal para saber si lo que escribiste se entiende por sí solo.
- **`@structurer`** — para problemas de estructura, ritmo, arco narrativo. Él diseña; el crítico revisa su diseño.

Puedes pedir combinaciones: «Pasa el capítulo 7 por @critico y luego por @lector». O dejar que el editor coordine él solo cuando el problema es complejo — llama a los especialistas que hagan falta, les pasa el contexto, recoge sus informes y te devuelve una síntesis.

### Cómo se trabaja con él

```
Tú: Revisa el capítulo 4
→ El editor ejecuta get_chapter_context(4), check_consistency(4),
  check_voice_consistency(4, Frodo), scan_prose()…
  Te devuelve un diagnóstico con problemas encontrados.
Tú: La escena de Mordor no termina de funcionar. Pásala por @critico.
→ El editor llama al @critico con el contexto de la escena.
  @critico: señala que el Anillo habla demasiado, pierde misterio.
Tú: @writer, reescribe ese fragmento con menos intervención del Anillo.
→ El editor llama a @writer con las objeciones del crítico.
  @writer: propone una versión más contenida.
Tú: Aplica el cambio.
→ El editor edita el archivo, re-ejecuta scan_prose() para
  confirmar que mejora, actualiza los scores.
  «Aplicado. La densidad de patrones bajó de 1.8 a 0.9 en ese capítulo.»
```

### Cómo empiezas

1. Instalas opencode
2. Clonas este repo
3. Escribes en Obsidian (o en cualquier editor de texto)

El editor se encarga del resto.

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

## Tools

### `prose_scanner.py` — Escáner de patrones de prosa

Examina cada párrafo contra una batería de patrones (`Estilo/patrones.json`) y reporta
matches agrupados por categoría: huellas IA, estructuras frágiles, muletillas de voz, etc.

```bash
python tools/prose_scanner.py                      # resumen global de todos los capítulos
python tools/prose_scanner.py --cap 07             # detalle de un capítulo concreto
python tools/prose_scanner.py --cap 07 --context full  # incluye párrafos completos
python tools/prose_scanner.py --json               # salida JSON (para análisis programático)
python tools/prose_scanner.py --review             # modo interactivo: confirma/rechaza cada match
python tools/prose_scanner.py --estilo             # estadísticas de estructura (párrafos, diálogo vs narrativa)
python tools/prose_scanner.py --ritmo              # longitud de frases, variación
python tools/prose_scanner.py --king               # análisis Stephen King (adverbios, voz pasiva, subestimado)
python tools/prose_scanner.py --sanderson          # análisis Sanderson (coste de magia, proactividad, escalación)
python tools/prose_scanner.py --validate           # detecta overlaps entre patrones
python tools/prose_scanner.py --update-estado      # actualiza scores en Estado.md
python tools/prose_scanner.py --door closed        # modo puerta cerrada (solo crítico, sin nitpicks)
```

### `editorial_letter.py` — Carta editorial automatizada

Genera un informe narrativo completo: estructura, función de escenas, arco emocional,
inmersión sensorial, foreshadowing, show vs tell, hooks de apertura/cierre, y un
plan de revisión priorizado.

```bash
python tools/editorial_letter.py                   # carta editorial completa (todos los análisis)
python tools/editorial_letter.py --beta            # informe profesional sintético
python tools/editorial_letter.py --cap 07          # análisis detallado de un capítulo
python tools/editorial_letter.py --resumen         # solo tabla de prioridades
python tools/editorial_letter.py --plan            # plan de revisión faseado
python tools/editorial_letter.py --insights        # análisis avanzados (estilo, diálogo, Save the Cat…)
python tools/editorial_letter.py --json            # salida JSON
python tools/editorial_letter.py --compare old/ new/  # diff entre dos versiones del manuscrito
```

### `editorial_insights.py` — Análisis avanzados

Analiza aspectos concretos del manuscrito: estilo, calidad del diálogo, Save the Cat
beats, Chekhov's Gun, backstory dumps, ratio escena/resumen, arco Vonnegut, etc.

```bash
python tools/editorial_insights.py                          # todos los módulos
python tools/editorial_insights.py --module style            # solo diagnóstico de estilo
python tools/editorial_insights.py --module dialogue         # solo calidad de diálogo
python tools/editorial_insights.py --module save_cat         # solo beats de Save the Cat
python tools/editorial_insights.py --module chekhov          # solo Chekhov's Gun
python tools/editorial_insights.py --module first_pages      # test de primeras 10 páginas
python tools/editorial_insights.py --module backstory        # info-dumps de backstory
python tools/editorial_insights.py --module scene_summary    # ratio escena vs resumen
python tools/editorial_insights.py --module arc              # arco narrativo (Vonnegut)
python tools/editorial_insights.py --module hotspots         # hotspots de revisión
python tools/editorial_insights.py --json                    # salida JSON
```

### `consistency_check.py` — Verificador de consistencia

Lee `.fiction/consistency.json` y compara contra el texto de los capítulos para
detectar contradicciones en objetos, tiempo, clima, atributos de personajes y ubicaciones.

```bash
python tools/consistency_check.py               # verificación global
python tools/consistency_check.py --cap 07      # solo un capítulo
python tools/consistency_check.py --cap 14-18   # rango de capítulos
python tools/consistency_check.py --json        # salida JSON
```

### `session_check.py` — Resumen de cambios entre sesiones

Al empezar una sesión de edición, muestra qué archivos cambiaron, actualiza
los scores de prosa y resume los pendientes activos.

```bash
python tools/session_check.py          # diff + scores
python tools/session_check.py --quick  # solo diff, sin escáner
python tools/session_check.py --full   # incluye Estado.md y checklist del ritual
python tools/session_check.py --json   # salida JSON
```

### `new_chapter.py` — Creador de capítulos

Crea un nuevo capítulo desde plantilla, lo registra en `Escritura/manifiesto.json`
y genera el archivo `.md` en la ubicación correcta.

```bash
python tools/new_chapter.py "Título del capítulo"      # al final del manuscrito
python tools/new_chapter.py "Título" -p 5              # insertar después del capítulo 5
python tools/new_chapter.py "Título" --pov Frodo       # con POV predefinido
python tools/new_chapter.py --list                     # listar capítulos existentes
```

### `sync_manifiesto.py` — Sincronización YAML

Lee `Escritura/manifiesto.json` y sincroniza el orden y metadatos en los
frontmatter YAML de cada capítulo.

```bash
python tools/sync_manifiesto.py          # sincronizar
python tools/sync_manifiesto.py --dry    # simular sin escribir
```

### `publish.py` — Publicación (EPUB / HTML / PDF)

Compila todos los capítulos en un libro listo para compartir. Los tres formatos
se generan desde la misma fuente Markdown.

```bash
python tools/publish.py                         # EPUB → output/
python tools/publish.py --format all            # EPUB + HTML + PDF
python tools/publish.py --format html           # solo HTML
python tools/publish.py --format pdf            # solo PDF (necesita weasyprint)
python tools/publish.py --beta                  # HTML para beta readers (con nº de línea)
python tools/publish.py -o ../mi-libro          # ruta de salida personalizada
python tools/publish.py --title "Mi Libro" --author "Yo"  # metadatos
```

### `fiction_mcp.py` — MCP server (automático)

Provee contexto narrativo al asistente de opencode: perfiles de personaje,
ubicaciones, lore, continuidad, foreshadowing, y escaneo de prosa. Se inicia solo
— no hay que ejecutarlo manualmente. Registrado en `opencode.json`.
